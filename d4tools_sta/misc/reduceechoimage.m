function    R = reduceechoimage(R,icithr)
%
%    R = reduceechoimage(R,icithr)
%

cl = R{2} ;
RR = 10.^(R{3}/10) ;

while 1,
   k = find(diff(cl)<icithr,1) ;
   if isempty(k), break, end
   kk = find(cl(k+1:end)-cl(k)>icithr,1) ;
   if isempty(kk), kk=length(cl)-k ; end
   ka = k+(0:kk-1) ;
   cl = [cl(1:k);cl(k+kk:end)] ;
   %RR = [RR(:,1:k-1) max(RR(:,ka),[],2) RR(:,k+kk:end)] ;
   RR = [RR(:,1:k-1) mean(RR(:,ka),2) RR(:,k+kk:end)] ;
end

R{2} = cl ;
R{3} = 10*log10(RR) ;
