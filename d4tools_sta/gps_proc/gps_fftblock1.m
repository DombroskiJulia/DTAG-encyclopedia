function    [X,del,dop] = gps_fftblock(b,SVL,CF,FD,Nfft)
%
%    [X,del,dop] = gps_fftblock(b,SVL,CF,FD,Nfft)

FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
if length(FD)==2,
   fstep = 300/FS ;           % Doppler step
   wd = 2*pi*(FD(1)/FS:fstep:FD(2)/FS) ;     % doppler test frequencies in rad/s
else
   wd = 2*pi*FD/FS ;
end

if nargin<5,
   Nfft = CF*1023 ;
end

G = zeros(Nfft,length(SVL)) ;
for k=1:length(SVL),
   g = reshape(repmat(2*ca_code(SVL(k))-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
   if Nfft>CF*1023;
      g = resample(g,Nfft,CF*1023) ;
   end
   G(:,k) = conj(fft(g,Nfft)) ;
end

X = zeros(Nfft,length(wd),length(SVL)) ;
if Nfft>CF*1023;
   b = resample(b,Nfft,CF*1023) ;
end

for k=1:length(wd),
   cc = b.*exp(-j*(0:length(b)-1)'*wd(k)) ;  % doppler shift received signal
   [C,z] = buffer(cc,Nfft,0,'nodelay') ;
   S = fft(C,Nfft) ;
   for kk=1:length(SVL),
      X(:,k,kk) = mean(abs(ifft(S.*repmat(G(:,kk),1,size(S,2)),Nfft)).^2,2) ;
   end
end

for k=1:length(SVL),
   fprintf(' SV %d: ',SVL(k)) ;
   gpsperf(squeeze(X(:,:,k)),size(C,2),wd*FS/2/pi) ;
end

