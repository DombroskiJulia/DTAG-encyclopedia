function    [X,del,dop] = gps_fftblock(b,sv,CF,FD,Nfft)
%
%    [X,del,dop] = gps_fftblock(b,sv,CF,FD,Nfft)

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

g = reshape(repmat(2*ca_code(sv)-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
ng = length(g) ;
if Nfft>CF*1023;
   g = resample(g,Nfft,CF*1023) ;
end
G = conj(fft(g,Nfft)) ;

X = zeros(Nfft,length(wd)) ;
if Nfft>CF*1023;
   b = resample(b,Nfft,CF*1023) ;
end

for k=1:length(wd),
   cc = b.*exp(-j*(0:length(b)-1)'*wd(k)) ;  % doppler shift received signal
   [C,z] = buffer(cc,Nfft,0,'nodelay') ;
   S = fft(C,Nfft) ;
   X(:,k) = mean(abs(ifft(S.*repmat(G,1,size(S,2)),Nfft)).^2,2) ;
end

gpsperf(X,size(C,2),wd*FS/2/pi) ;

