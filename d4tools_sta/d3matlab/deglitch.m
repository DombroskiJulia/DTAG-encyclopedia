function    x = deglitch(x,m)
%
%    x = deglitch(x,m)
%

if nargin<2,
   m = 10 ;
end

for kk=1:4,
   xx=abs(diff(x));
   k=find(xx>nanmean(xx)*m);
   if isempty(k), break, end
   if k(1)==1,
      x(1:2) = NaN ;
      k = k(2:end) ;
      if isempty(k), break, end
   end
   x(k)=x(k-1);
end
