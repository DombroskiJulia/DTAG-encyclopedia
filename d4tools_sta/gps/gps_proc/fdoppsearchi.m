function    [delay,dop,mpk,snr,D,wd,CCC] = fdoppsearchi(bb,sv,FD,CF,SILENT)
%
%     [delay,dop,mm,snr,D] = doppsearchi(bb,sv,FD,CF,SILENT)
%     Search in code and Doppler space for satellite sv.
%     bb is the pseudo-base-band signal vector at a nominal
%     sampling rate of 2.046 MHz. sv is the space vehicle
%     number 1..30. FD=[fd_low fd_hi] is the Doppler shift
%     search range in Hz. CF is the optional over-sampling
%     rate with respect to 1.023MHz. Default is 2.
%     Returns:
%     delay is the code delay to the detection at the input
%     sampling rate.
%     dop is the doppler shift in Hz.
%     mm is the peak power corresponding to the detection
%     snr is the peak to noise power ratio
%     D is the detection power matrix.
%
%     mark johnson
%     majohnson@whoi.edu
%     Last modified: 27 May 2006


D = []; delay = []; dop = []; snr=[] ;    % in case of early return

if nargin<4 | isempty(CF),
   CF = 2 ;
end

FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
Nfft = CF*1024 ;           % FFT length to use
FU = 1e3*Nfft ;            % interpolated base-band sampling rate
fstep = 300/FS ;           % Doppler step
GUARD = -4:4 ;  % guard band around peak to exclude for noise calculations

g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of 2
mf = g(end:-1:1) ;                  % reverse code order for matched filtering
nmf = length(g) ;
if nmf~=Nfft,
   ki = linspace(0,nmf-1,Nfft)' ;
   mf = interp1((0:nmf-1)',mf,ki) ;
end
if length(FD)==2,
   wd = 2*pi*(FD(1)/FU:fstep:FD(2)/FU) ;     % doppler test frequencies in rad/s
else
   wd = 2*pi*FD/FU ;
end
cc = repmat(mf,1,length(wd)).*exp(-j*(1:Nfft)'*wd) ;  % C/A codes with different dopplers
Fmf = fft(cc,Nfft) ;

tsc = mean(FD)/FC ;
if abs(tsc)*length(bb)>0.5,
   bb = interp1((0:length(bb)+10)',[bb(end);bb;bb(1:10)],(1:length(bb))'*(1+tsc)) ;
end

[CB,z] = buffer(bb,nmf,0,'nodelay') ;     % stack adjacent baseband data frames
if nmf~=Nfft,
   CB = interp1((0:nmf-1)',CB,ki) ;     % interpolate baseband data frames to Nfft length
end
CB = fft(CB,Nfft) ;

D = zeros(Nfft,length(wd)) ;
CCC = zeros(Nfft,size(CB,2),length(wd)) ;
for k=1:length(wd),
   CC = ifft(CB.*repmat(Fmf(:,k),1,size(CB,2)),Nfft) ;
   D(:,k) = sum(abs(CC).^2,2)/size(CC,2) ;       % incoherent average over frames
   CCC(:,:,k) = CC ;
end

% Improve delay and doppler estimate by interpolating around the peak
[m ndel] = max(D) ;                    % find maximum in code and doppler
[mpk dop] = max(m) ;
delay = ndel(dop) ;
kcode = 1+mod(delay-1+(-2:2),nmf) ;              % interpolate around code peak
dop(2) = interp1(1:length(wd),wd*FS/2/pi,dop) ;

% Calculate the quality of the peak
DD = D([1:kcode-3 kcode+3:size(D,1)],:) ;
DD = DD(:) ;
mD = mean(DD) ;
sD = std(DD) ;
%snr = 10*log10((mpk-mD)/sD) ;        % and compute an snr
mpk = mpk*64/mD ;       % why am i using 64 here? it is correct, but what is the reason?
sD = sD*64/mD ;
p = (1-chi2cdf(mpk,64))*length(DD) ;
dev = mpk-64 ;
snr = [p dev mD sD] ;

if nargin<5,
   SILENT = 0 ;
end

if ~SILENT | p<0.05,
fprintf(' SV %d: Peak of magnitude %4.0f, n=%1.4f (mean %4.0f, ssd %2.1f), code delay %4.2f, Doppler %5.0f Hz\n', ...
   sv,dev,p,mD,sD,delay,dop(2)) ;
end
