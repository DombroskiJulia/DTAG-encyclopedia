function    [X,del,dop] = gps_fftcorrelator(b,sv,CF,FD,Nfft,dly)
%
%    [X,del,dop] = gps_fftcorrelator(b,sv,CF,FD,Nfft)
%     % gives identical output to gps_correlator when Nfft=CF*1023

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

g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of CF
%g = reshape(repmat(2*ca_code(sv)-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
ng = length(g) ;
if Nfft>CF*1023,
   g = [g(1:1023);0;g(1024:end);0] ;
   %g = resample(g,Nfft,CF*1023) ;
end
G = conj(fft(circ(g,dly),Nfft)) ;
%G = 128*(round(real(G)*8/max(abs(G)))/8 + j*round(imag(G)*8/max(abs(G)))/8) ;

X = zeros(Nfft,length(wd)) ;
B = b(1:ng) ;
if Nfft>CF*1023,
   B = [B(1:1023);0;B(1024:end);0] ;
   %B = resample(B,Nfft,CF*1023) ;
end

for k=1:length(wd),
   cc = B.*exp(j*(0:length(B)-1)'*wd(k)) ;  % doppler shift received signal
                                        % sign chosen to match fdoppsearchi_oa
   S = fft(cc,Nfft) ;
   %S = 128*(round(real(S)*8/max(abs(S)))/8 + j*round(imag(S)*8/max(abs(S)))/8) ;
   X(:,k) = ifft(S.*G,Nfft) ;
end

gpsperf(X,sv,1,wd*FS/2/pi) ;

