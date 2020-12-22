function [P,SNR,DEL,DOP] = fast_fdoppX(B,blk,findz,nb)
%
% [P,SNR,DEL,DOP] = fast_fdoppX(B,blk,findz,nb)
%
if ~iscell(B),
   if size(B,1)==1,
      B = {B(:)} ;
   else
      b = B ;
      B = {} ;
      for k=1:size(b,2),
         B{k} = b(:,k) ;
      end
   end
end

if nargin<2,
   blk = 1:length(B) ;
end

if nargin<3,
   findz = 1 ;
end

if nargin<4,
   nb = 1 ;
end

SNR = [] ;
DEL = zeros(32,length(B)) ;
DOP = DEL ;
h = [] ;
clf
plot(0,0),grid
axis([0.5 32.5 0 5000]) ;
xlabel('SV')
ylabel('snr')
hold on, grid on
drawnow
for k=1:length(B),
   fprintf(' Processing capture %d of %d\n',k,length(B)) ;
   x = B{k} ;
   if findz==1,
      kz = find((x(1:end-1)==0) & (x(2:end)==0)) ;
      x = x([kz(end)+2:end 1:kz(1)-2]) ;
   end
   [bb,fs] = bitgrab2bb(x,8,0,nb);
   [del,dop,snr] = gps_fftcorrelator1b(bb);
   if isempty(del),
      continue
   end
   DEL(:,k) = del ;
   DOP(:,k) = dop ;
   SNR(k).p = snr(:,1) ;
   SNR(k).dev = snr(:,2) ;
   SNR(k).m = snr(:,3) ;
   SNR(k).s = snr(:,4) ;
   if ~isempty(h),
      set(h,'Color',0.5*[1 1 1]) ;
   end
   ss = min(10.^(snr(:,2)/10),max(get(gca,'YLim'))) ;
   h = plot((1:32),ss,'r.') ;
   title(sprintf('Processed %d of %d\n',k,size(B,2))) ;
   drawnow
end

P=reshape(vertcat(SNR(:).dev),32,[])';
% delay is in units of 1/2048 th of a ms
% The following gives delay values that match fdoppX
DEL = DEL'*1023/2048 ;   % report code delay in chips at 1023 chips per millisecond
DOP = DOP' ;
