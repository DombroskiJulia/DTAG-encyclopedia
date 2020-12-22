function [P,SNR,DEL,DOP] = d4gpsproc(B,blk,findz,nb)
%
% [P,SNR,DEL,DOP] = fdoppX(B,blk,findz,nb)
%
if iscell(B),
   if nargin<2,
      blk = 1:size(B) ;
   end   
   B = horzcat(B{blk}) ;
end

if nargin<3,
   findz = 0 ;
end

if nargin<4,
   nb = 1 ;
end

df = 8 ;
SNR = [] ;
DEL = [] ;
DOP = [] ;
for kk=1:size(B,2),
   fprintf(' Processing capture %d of %d\n',kk,size(B,2)) ;
   x = B(:,kk) ;
   if findz==1,
      kz = find((x(1:end-1)==0) & (x(2:end)==0)) ;
      %x = x([kz(end)+2:end 1:kz(1)-2]) ;
      x = x(4:kz(1)-2) ;
   end
   [bb,fs] = bitgrab2bb(x,df,0,nb);
   for k=1:32,
      %[delay,dop,snr] = fdoppsearchi_oa(bb,k,[-8 8]*1e3,16/df);
      [delay,dop,snr] = fdoppsearchi_oa_work(x,k,[-8 8]*1e3);
      SNR(kk,k).p = snr(1) ;
      SNR(kk,k).dev = snr(2) ;
      SNR(kk,k).m = snr(3) ;
      SNR(kk,k).s = snr(4) ;
      DEL(kk,k) = delay ;
      DOP(kk,k) = dop(2) ;
   end
   
end
P=reshape([SNR.dev],[],32);
DEL = DEL*df/16 ;   % report code delay in microseconds
