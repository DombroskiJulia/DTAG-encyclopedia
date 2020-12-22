function [S,f] = grab_Spec(B,blk,findz,nb)
%
% [P,SNR,DEL,DOP] = fast_fdoppX(B,blk,findz,nb)
%

if iscell(B),
   if nargin<2 | isempty(blk),
      blk = 1:size(B) ;
   end   
   B = horzcat(B{blk}) ;
end

if nargin<3,
   findz = 1 ;
end

if nargin<4,
   nb = 1 ;
end

bb = [] ;

for k=1:size(B,2),
   x = B(:,k) ;
   if findz==1,
      kz = find((x(1:end-1)==0) & (x(2:end)==0)) ;
      x = x([kz(end)+2:end 1:kz(1)-2]) ;
   end
   if nb==1,
      bu = 2*unpack(x,16)-1 ;     % convert to +/-1
sum(bu>0)/length(bu)
      if length(bu)<size(bb,1),
         bu(end+(1:size(bb,1)-length(bu))) = 0 ;
      elseif length(bu)>size(bb,1),
         bb(end+(1:length(bu)-size(bb,1)),:) = 0 ;
      end
      bb(:,k) = bu ;     % convert to +/-1
   else
      b = unpack(x,16) ;
      bm = b(1:2:end) ;          % magnitude bits
      bs = b(2:2:end) ;          % sign bits
      bb(:,k) = (2*bs-1).*(0.707*bm+0.707) ;
   end
end

fs = 16.368 ;
nfft = 4096 ;
nov = 2048 ;
P = zeros(nfft,size(x,2)) ;
for k=1:size(bb,2),
   [X,z] = buffer(bb(:,k),nfft,nov,'nodelay') ;
   F = abs(fft(X,nfft)).^2 ;
   P(:,k) = sum(F,2) ;
end

S = 10*log10(P)-10*log10(size(X,2)) ;
f = (0:nfft-1)/nfft*fs ;

figure,clf
plot(f(1:nfft/2),S(1:nfft/2,:)),grid
xlabel('Frequency (MHz)')
ylabel('Level (dB)')
set(gca,'XLim',[0 8])
