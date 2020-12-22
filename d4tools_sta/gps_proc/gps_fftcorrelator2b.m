function    [X,del,dop,stats] = gps_fftcorrelator2b(b,sv,Fmax)
%
%    [X,del,dop,stats] = gps_fftcorrelator2b(b,sv,Fmax)

CF = 2 ;
FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
wd = -2*pi*Fmax/FS ;       % starting doppler is -Fmax
Nfft = 4096 ;              % FFT size to use
nd = ceil(2*Fmax/500) ;    % number of dopplers to test per pass
ndinc = 2 ;                % number of doppler tests per 500 Hz (use 2 or 3)

% make fractional sample shift filter for implementing doppler shift directly
% on the spectrum
h=sinc(1/ndinc+(-20:19)').*((-1).^(0:39)');
hdopp=h(5:end-4);          % filter group delay of 16 will need to be removed

g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of CF
%g = reshape(repmat(2*ca_code(sv)-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
ng = length(g) ;
g = resample(g,1024,1023);
%g = [g(1:1023);0;g(1024:end);0] ;
G = conj(fft([g;g],Nfft)) ;

[B,z] = buffer(b,2*ng,0,'nodelay') ;
B = resample(B,1024,1023);
%B = [B(1:1023);0;B(1024:2046);0;B(2047:3069);0;B(3070:end);0] ;
cc = B.*repmat(exp(-j*(0:length(B)-1)'*wd),1,size(B,2)) ;  % doppler shift received signal
S = fft(cc,Nfft) ;

X = zeros(Nfft,ndinc*nd) ;
for kk=1:ndinc,
   for k=1:nd,
      XX = ifft(S.*repmat(G,1,size(S,2)),Nfft) ;
      X(:,k+(kk-1)*nd) = mean(abs(XX).^2,2) ;
      S = S([2:end,1],:) ;        % increase doppler shift by 1kHz
   end

   % apply fractional sample doppler shift
   for k=1:size(S,2),
      ss = conv(hdopp,circ(S(:,k),nd));
      S(:,k) = ss(16+(1:Nfft)) ;
   end
   % alternative direct method:
   %cc = cc.*repmat(exp(-j*(0:length(B)-1)'*2*pi/(ndinc*2048)),1,size(B,2)) ;  % doppler shift received signal
   %S = fft(cc,Nfft) ;
end

% analyse and report results
FD = -Fmax+500*reshape(repmat((0:nd-1)',1,ndinc)+repmat((0:ndinc-1)./ndinc,nd,1),[],1) ;
[FD,I] = sort(FD) ;     % reorder X for increasing doppler
X = X(:,I) ;
[del,dop,stats] = gpsperf(X,sv,size(S,2),-FD,1,0) ;
