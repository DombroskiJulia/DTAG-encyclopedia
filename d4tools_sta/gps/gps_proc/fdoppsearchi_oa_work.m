function    [delay,dop,mpk,snr,D,wd,CCC] = fdoppsearchi_oa_work(x,SV,FD)
%
%     [delay,dop,mpk,snr,D,wd,CCC] = doppsearchi_oa_work(x,SV,FD)
%     Search in code and Doppler space for satellite sv.
%     x is the IF signal vector, a packed binary vector at a nominal
%     sampling rate of 16.368 MHz/bit. SV is the space vehicle
%     number 1..32. FD=[fd_low fd_hi] is the Doppler shift
%     search range in Hz. 
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


D = []; delay = []; dop = []; snr=[] ;    % in case of early return

CF = 2 ;
FC = 1575.42e6 ;           % GPS L1 carrier frequency
PB = 16368 ;               % pass-band samples per ms
FB = 2048e3 ;              % resampled base-band sampling rate in Hz
FS = 1023e3*CF ;           % chip rate in Hz
Nfft = CF*1024 ;           % FFT length to use
GUARD = -4:4 ;             % guard band around peak to exclude for noise calculations

% doppler filters
fstep = 300/FB ;           % Doppler step
DV = FD(1)/FB:fstep:FD(2)/FB ;     % doppler test frequencies relative to FB
mdopshft = round(Nfft*mean(FD)/FB) ;        % frequency shift to correct mean doppler in the matched filter
dopshft = round(Nfft*DV) ;       % additional frequency shift to correct each doppler in the matched filter
incr = PB*mean(FD)/FC ;
h=sinc(repmat((Nfft*DV-dopshft)',1,40)+repmat((-20:19),length(DV),1)) ;
h=h.*repmat(hamming(40)'.*((-1).^(0:39)),length(DV),1);
DFILT=h(:,5:end-4);
dopshft = dopshft-mdopshft;
% make decimating filter
h = fir1(47,0.8/8) ;
nh = length(h) ;

% Demodulate, decimate, interpolate and FFT the input signal
% adjusting for the average Doppler
b = 2*unpack(x,16)-1 ;                 % convert packed binary samples to +/-1
b = b.*exp(-j*pi/2*(1:length(b))') ;   % form base-band signal with complex demodulation
nblks = floor(length(b)/PB) ;
dfix = (0:nblks-1)*incr ;
Fin = zeros(Nfft,nblks) ;
ks = 0 ;
dfix = 0 ;
for k=1:nblks,
   Fin(:,k) = fft_resample(b(ks+(1:PB+nh)),h) ;
   ks = ks+PB ;
   dfix = dfix+incr ;
   if(abs(dfix)>0.5),
      ks = ks+round(dfix) ;
      dfix = dfix-round(dfix) ;
   end
end
Fin = fft(Fin,Nfft) ;

% brute-force search for each sv
for ks=1:length(SV),
   % make matched filter
   g = reshape(repmat(2*ca_code(SV(ks))-1,1,16)',[],1) ;      % interpolate C/A code by factor of 16 without filtering
   g = g(end:-1:1) ;                     % reverse code order for matched filtering
   g = fft_resample([g(end+(-nh/2+1:0));g;g(1:nh/2)],h) ;        % code now at 2.048 MHz
   Fmf = fft(g,Nfft) ;                   % fft of mf
   Fmf = circ(Fmf,mdopshft) ;            % rotate for mean doppler
   pk = zeros(length(DV),3) ;

   for kd=1:length(DV),
      fmf = circ(Fmf,dopshft) ;            % rotate for mean doppler
      fmf=conv(DFILT(kd,:),fmf(32:end,1));
      D = zeros(Nfft,1) ;
      for kb=1:nblks,
         dd = ifft(Fin(:,kb).*fmf,Nfft) ;
         D = D+abs(dd).^2 ;               % incoherent average over frames
      end
      pk(kd,:) = find_peaks(D) ;
   end
end

% here on needs fixing

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

% Improve delay and doppler estimate by interpolating around the peak
[m ndel] = max(D) ;                    % find maximum in code and doppler
[mpk dop] = max(m) ;
delay = ndel(dop) ;
kcode = 1+mod(delay-1+(-2:2),length(D)) ;              % interpolate around code peak
dop(2) = interp1(1:length(DV),DV*FS/2/pi,dop) ;

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
