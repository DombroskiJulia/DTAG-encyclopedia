function    [delay,dop,stats,D,wd,CCC] = fdoppsearchi_oa(bb,sv,FD,CF,SILENT)
%
%     [delay,dop,stats,D,wd,CCC] = doppsearchi_oa(bb,sv,FD,CF,SILENT)
%     Search in code and Doppler space for satellite number sv.
%     bb is the pseudo-base-band signal vector at a nominal
%     sampling rate of 2.046 MHz. sv is the space vehicle
%     number 1..30. FD=[fd_low fd_hi] is the Doppler shift
%     search range in Hz. CF is the optional over-sampling
%     rate with respect to 1.023MHz. Default is 2.
%     Returns:
%     delay is the code delay to the detection at the input
%     sampling rate.
%     dop is the doppler shift in Hz.
%     stats is a vector with:
%        1 probability that the peak is a real signal rather than noise
%        2 snr of peak
%        3 mean crosscorrelation output
%        4 rms of crosscorrelation output away from peak (i.e., noise level)
%        5 raw (non interpolated peak value
%     D is the detection power matrix.
%
%     markjohnson@st-andrews.ac.uk
%     Copyright 2006-2014
%     Last modified: March 2014


D = []; delay = []; dop = []; snr=[] ;    % in case of early return

if nargin<4 | isempty(CF),
   CF = 2 ;
end

if nargin<5,
   SILENT = 0 ;
end

FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
Nfft = 2*CF*1024 ;         % FFT length to use - has to span two times the code length
fstep = 300/FS ;           % Doppler step

% prepare matched filters - one for each doppler bin
g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of 2
mf = g(end:-1:1) ;                  % reverse code order for matched filtering
nmf = length(g) ;
if length(FD)==2,
   wd = 2*pi*(FD(1)/FS:fstep:FD(2)/FS) ;     % doppler test frequencies in rad/s
else
   wd = 2*pi*FD/FS ;
end
cc = repmat(mf,1,length(wd)).*exp(-j*(0:nmf-1)'*wd) ;  % C/A codes with different dopplers
Fmf = fft([cc;zeros(Nfft,length(wd))],Nfft) ;      % fft of the matched filters

% Divide the input signal into Nfft length blocks, nmf apart, 
% adjusting for the average Doppler
nblks = floor(length(bb)/nmf) ;
incr = round(mean(FD/FC)*nmf*(0:nblks-1)') ;
bb = [zeros(Nfft-2*nmf,1);bb(1:nmf);bb] ;
CB = zeros(Nfft,nblks) ;
for k=1:nblks,
   ks = (k-1)*nmf+incr(k)+(1:Nfft)' ;
   CB(:,k) = bb(ks) ;     % stack adjacent baseband data frames
end

CB = fft(CB,Nfft) ;        % take the fft of the input blocks

D = zeros(nmf,length(wd)) ;
CCC = zeros(nmf,size(CB,2),length(wd)) ;
kin = (1:nmf)+Nfft-nmf ;
for k=1:length(wd),
   CC = ifft(CB.*repmat(Fmf(:,k),1,size(CB,2)),Nfft) ;   % apply the matched filters and inverse fft
   CC = CC(kin,:) ;
   D(:,k) = sum(abs(CC).^2,2)/size(CC,2) ;       % incoherent average over frames
   CCC(:,:,k) = CC ;
end

if length(wd)==1,
   return
end

% Improve delay and doppler estimate by interpolating around the peak
[delay,dop,stats] = gpsperf(D,sv,size(CB,2),wd*FS/2/pi,0.01,SILENT) ;
