function    [X,del,dop] = gps_fftcorrelator2d(b,sv,FD,dly)
%
%    [X,del,dop] = gps_fftcorrelator2d(b,sv,FD,dly)
%     % gives identical output to gps_correlator when Nfft=CF*1023

CF = 2 ;
FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
Nfft = 4096 ;
wd = 2*pi*FD/FS ;

g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of CF
%g = reshape(repmat(2*ca_code(sv)-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
ng = length(g) ;
g = [g(1:1023);0;g(1024:end);0] ;
g = [g;g] ;
G = conj(fft(circ(g,dly),Nfft)) ;

B = b(1:2*ng) ;
B = [B(1:1023);0;B(1024:2046);0;B(2047:3069);0;B(3070:end);0] ;

nd = length(wd) ;
X = zeros(Nfft,nd) ;
for k=1:nd,
   cc = B.*exp(-j*(0:length(B)-1)'*wd(k)) ;  % doppler shift received signal
   S = fft(cc,Nfft) ;
   X(:,k) = ifft(S.*G,Nfft) ;
end

gpsperf(X,sv,1,wd*FS/2/pi) ;
