function    [DEL,DOP,STATS,X] = gps_fftcorrelator1b(b,SV,Fmax)
%
%    [DEL,DOP,STATS,X] = gps_fftcorrelator1b(b,SV,Fmax)
%

DEL=[];DOP=[];STATS=[];X=[];

if nargin<2 || isempty(SV),
   SV = 1:32 ;
end

if nargin<3,
   Fmax = 8e3 ;
end

if length(b)<2046,
   return
end

CF = 2 ;
FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
wd = -2*pi*Fmax/FS ;       % starting doppler is -Fmax
Nfft = 2048 ;              % FFT size to use
nd = ceil(2*Fmax/1000) ;   % number of dopplers to test per pass
ndinc = 2 ;                % number of doppler tests per 1 kHz (use 2 or 3)

% make fractional sample shift filter for implementing doppler shift directly
% on the spectrum
h=sinc(1/ndinc+(-20:19)').*((-1).^(0:39)');
hdopp=h(5:end-4);          % filter group delay of 16 will need to be removed

G = sv_spectrum(SV) ;
[B,z] = buffer(b,2046,0,'nodelay') ;
B = [B(1:1023,:);zeros(1,size(B,2));B(1024:end,:);zeros(1,size(B,2))] ;
cc = B.*repmat(exp(-j*(0:length(B)-1)'*wd),1,size(B,2)) ;  % doppler shift received signal
S = fft(cc,Nfft) ;

DEL = zeros(length(SV),1) ;
DOP = zeros(length(SV),1) ;
STATS = zeros(length(SV),5) ;

for ksv=1:length(SV),
   X = zeros(Nfft,ndinc*nd) ;
   SS = S ;
   for kk=1:ndinc,
      for k=1:nd,
         XX = ifft(SS.*repmat(G(:,ksv),1,size(S,2)),Nfft) ;
         X(:,k+(kk-1)*nd) = mean(abs(XX).^2,2) ;
         SS = SS([2:end,1],:) ;        % increase doppler shift by 1kHz
      end

      % apply fractional sample doppler shift
      for k=1:size(S,2),
         ss = conv(hdopp,circ(SS(:,k),nd));
         SS(:,k) = ss(16+(1:Nfft)) ;
      end
      % alternative direct method:
      %cc = cc.*repmat(exp(-j*(0:length(B)-1)'*2*pi/(ndinc*2048)),1,size(B,2)) ;  % doppler shift received signal
      %SS = fft(cc,Nfft) ;
   end

   % analyse and report results
   FD = -Fmax+1000*reshape(repmat((0:nd-1)',1,ndinc)+repmat((0:ndinc-1)./ndinc,nd,1),[],1) ;
   [FD,I] = sort(FD) ;     % reorder X for increasing doppler
   X = X(:,I) ;
   [DEL(ksv),DOP(ksv),STATS(ksv,:)] = gpsperf(X,SV(ksv),size(S,2),-FD,0.001,0) ;
end
