function    [delay,dop,snr,DD] = fft_search(x,SV,FD)
%
%     [delay,dop,snr,D] = fft_search(x,SV,FD)
%     Search in code and Doppler space for satellite sv.
%     x is the base-band signal vector at a nominal
%     sampling rate of 2.046 MHz derived from gps_decimate. 
%     sv is the space vehicle number 1..30.
%     FD=[fd_low fd_hi] is the Doppler shift search range in Hz.
%
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


DD = []; delay = []; dop = []; snr=[] ;    % in case of early return

CF = 2 ;
FC = 1575.42e6 ;           % GPS L1 carrier frequency
PB = 16368 ;               % pass-band samples per ms
FB = 1024e3*CF ;              % resampled base-band sampling rate in Hz
FS = 1023e3*CF ;           % chip rate in Hz
Nfft = CF*1024 ;           % FFT length to use
GUARD = -4:4 ;             % guard band around peak to exclude for noise calculations
fstep = 300 ;              % Doppler step in Hz

% doppler filters
DV = FD(1):fstep:FD(2) ;   % doppler test frequencies in Hz
dv = DV/FB ;               % doppler test frequencies relative to FB
mdopshft = round(Nfft*mean(FD)/FB) ;        % frequency shift to correct mean doppler in the matched filter
dopshft = round(Nfft*dv) ;     % additional frequency shift to correct each doppler in the matched filter
incr = PB*mean(FD)/FC ;
h=sinc(repmat((Nfft*dv-dopshft)',1,41)+repmat((-20:20),length(dv),1)) ;
h=h.*repmat(hamming(41)'.*((-1).^(0:40)),length(dv),1);
DFILT=h(:,5:end-4)';
%dopshft = dopshft-mdopshft;

x = resample(x,1024,1023) ;
nblks = floor(length(x)/2048) ;
%X = reshape(x(1:nblks*2048),2048,[]) ;
dopdel = mean(FD/FC)*Nfft*(0:nblks-1)' ;
incr = floor(dopdel) ;
X = zeros(Nfft,nblks) ;
for k=1:nblks,
   ks = (k-1)*Nfft+incr(k)+(1:Nfft)' ;
   X(:,k) = x(ks) ;     % stack adjacent baseband data frames
end
Fin = fft(X,Nfft) ;
%wc = 0*2*pi/Nfft*(dopdel-incr) ;
%for k=2:nblks,
%   Fin(:,k) = Fin(:,k).*exp(-j*wc(k)*(0:Nfft-1)') ;
%end

% brute-force search for each sv
for ks=1:length(SV),
   % make matched filter
   %g = reshape(repmat(2*ca_code(SV(ks))-1,1,16)',[],1) ;      % interpolate C/A code by factor of 16 without filtering
   %g = g(end:-1:1) ;                     % reverse code order for matched filtering
   %g = fft_resample([g(end+(-nh/2+1:0));g;g(1:nh/2)],h) ;        % code now at 2.048 MHz
   g = interp(2*ca_code(SV(ks))-1,CF) ;      % C/A code
   g = g(end:-1:1) ;              % reverse code order for matched filtering
   g = resample(g,1024,1023) ;        % code now at 2.048 MHz
   Fmf = fft(g,Nfft) ;                   % fft of mf
   %Fmf = circ(Fmf,mdopshft) ;            % rotate for mean doppler
   pk = zeros(length(DV),2) ;

   for kd=1:length(DV),
      %fmf = circ(Fmf,dopshft(kd)) ;            % rotate for doppler
      %fmf = conv(DFILT(:,kd),fmf(32:end,1)) ;
      mf = g.*exp(-j*(0:Nfft-1)'*2*pi*dv(kd)) ;  % C/A codes with different dopplers
      fmf = fft(mf,Nfft) ;                   % fft of mf
      D = zeros(Nfft,1) ;
      for kb=1:nblks,
         dd = ifft(Fin(:,kb).*fmf,Nfft) ;
         D = D+abs(dd).^2 ;               % incoherent average over frames
      end
      [m km] = max(D) ;
      pk(kd,:) = [m km] ;
   end
   % find peak doppler
   [m km] = max(pk(:,1)) ;
   if km>1 && km<size(pk,1),
      p = pk(km+(-1:1)) ;
      km = km+(p(1)-p(3))/2/(p(1)+p(3)-2*p(2)) ;
   end
   km
   dp = interp1((1:length(dv))',dv,km);
   mf = g.*exp(-j*(0:Nfft-1)'*2*pi*dp) ;  % C/A codes with different dopplers
   fmf = fft(mf,Nfft) ;                   % fft of mf
   DD = zeros(Nfft,nblks) ;
   %dopdel = round(mean(FD/FC)*Nfft*(0:nblks-1)') ;
   for kb=1:nblks,
      %wc = 2*pi/2048*(dopdel-incr) ;
      %fin = Fin(:,kb).*exp(j*wc(k)*(0:Nfft-1)') ;
      %dd = ifft(fin.*fmf,Nfft) ;
      dd = ifft(Fin(:,kb).*fmf,Nfft) ; % need to correct the phase of each block for coherent averaging
      DD(:,kb) = dd ;
   end
end
delay=pk;
% here on needs fixing
return
% Calculate the quality of peaks
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

return


function y = fft_resample(x,h)
%  Decimate x by 8*1023/1024 using FIR filter h
%  Produce 2048 output samples.
%  Process: take nh samples of x and apply filter
%           skip 8 samples
%           every 128 times through, skip back 1 sample
nh = length(h) ;
y = zeros(2048,1) ;
ks = 0 ;
for k=1:2048,
   y(k) = h*x(ks+(1:nh)) ;
   ks = ks+8-(rem(k,128)==0) ;
end
return


function pks=find_peaks(D,DV)
%
%

[m ndel] = max(D) ;                    % find maximum in code and doppler
[mpk dop] = max(m) ;
delay = ndel(dop) ;
kcode = 1+mod(delay-1+(-2:2),length(D)) ;              % interpolate around code peak
dop(2) = interp1(1:length(DV),DV,dop) ;

DD = D([1:kcode-3 kcode+3:size(D,1)],:) ;
DD = DD(:) ;
return


function  y=circ(x,n)
%
if n>0,
   y = x([n+1:end 1:n]) ;
elseif n<0,
   y = x([end+(n+1:0) 1:end+n]) ;
else
   y = x ;
end
return
