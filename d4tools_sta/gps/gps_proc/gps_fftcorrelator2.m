function    [X,del,dop] = gps_fftcorrelator2(b,sv,FL,dly)
%
%    [X,del,dop] = gps_fftcorrelator2(b,sv,CF,FD,Nfft)
%     % gives identical output to gps_correlator when Nfft=CF*1023

CF = 2 ;
FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
wd = 2*pi*FL/FS ;
Nfft = 4096 ;

g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of CF
%g = reshape(repmat(2*ca_code(sv)-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
ng = length(g) ;
g = [g(1:1023);0;g(1024:end);0] ;
g = [g;g] ;
G = conj(fft(circ(g,dly),Nfft)) ;

B = b(1:2*ng) ;
B = [B(1:1023);0;B(1024:2046);0;B(2047:3069);0;B(3070:end);0] ;
cc = B.*exp(-j*(0:length(B)-1)'*wd) ;  % doppler shift received signal
S = fft(cc,Nfft) ;

nd = ceil(2*abs(FL)/500) ;
X = zeros(Nfft,2*nd) ;
for k=1:nd,
   X(:,k) = ifft(S.*G,Nfft) ;
   S = circ(S,-1) ;        % increase doppler shift by 500 Hz
end

h=sinc(0.5+(-20:19)').*((-1).^(0:39)');
hdopp=h(5:end-4);    % delay of 16
ss = conv(hdopp,circ(S,nd));
S = ss(16+(1:Nfft)) ;
%cc = cc.*exp(-j*(0:length(B)-1)'*2*pi*0.5/4096) ;  % doppler shift received signal
%S = fft(cc,Nfft) ;
for k=nd+1:2*nd,
   X(:,k) = ifft(S.*G,Nfft) ;
   S = circ(S,-1) ;        % increase doppler shift by 500 Hz
end

gpsperf(X,sv,1,FL+[(0:nd-1)*500 250+(0:nd-1)*500]) ;
