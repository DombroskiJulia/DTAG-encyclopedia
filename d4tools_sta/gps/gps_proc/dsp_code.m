function [snr,del,dop] = dsp_code(x)
%
% [snr,del,dop] = dsp_code(x)
%

% 0. initialize
FS = 1023e3*2 ;           % base-band sampling rate
wd = -2*pi*Fmax/FS ;       % starting doppler is -Fmax
Nfft = 2048 ;              % FFT size to use
nd = ceil(2*Fmax/1000) ;   % number of dopplers to test per pass
ndinc = 2 ;                % number of doppler tests per 1 kHz (use 2 or 3)
h=sinc(1/ndinc+(-20:19)').*((-1).^(0:39)');
hdopp=h(5:end-4);          % filter group delay of 16 will need to be removed
FD = -8e3+1000*reshape(repmat((0:nd-1)',1,ndinc)+repmat((0:ndinc-1)./ndinc,nd,1),[],1) ;
[FD,I] = sort(FD) ;     % reorder X for increasing doppler

% x is input data stream at 16.368 MHz
% 1. find the zero sentinel and read the full array starting after the sentinel
kz = find((x(1:end-1)==0) & (x(2:end)==0)) ;
x = x([kz(end)+2:end 1:kz(1)-2]) ;

% 2. demodulate and decimate to FS
b = 2*unpack(x,16)-1 ;     % convert to +/-1
bb = b.*repmat([-j;-1;j;1],length(b)/4,1) ;
bb = decimate(bb,8,32,'FIR') ;

% 3. group into 1ms chunks and resample to 2.048 MHz 
[B,z] = buffer(b,2046,0,'nodelay') ;
B = [B(1:1023,:);zeros(1,size(B,2));B(1024:end,:);zeros(1,size(B,2))] ;
% apply initial doppler and fft input
cc = B.*repmat(exp(-j*(0:length(B)-1)'*wd),1,size(B,2)) ;  % doppler shift received signal
S = fft(cc,Nfft) ;

% 4. do code-doppler search
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
   end

   [DEL(ksv),DOP(ksv),STATS(ksv,:)] = gpsperf(X(:,I),SV(ksv),size(S,2),-FD,0.001,0) ;
end

DEL = DEL*1023/2048 ;
