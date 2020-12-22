function  d = majvote(D,n)
%
%  d = majvote(D,n)
%

if nargin<2,
   n = 8 ;
end

d = zeros(size(D,1),1) ;
for k=1:size(D,1),
   b = unpack(D(k,:),n) ;
   b = reshape(b,n,[]) ;
   b = sum(b,2)>size(D,2)/2 ;
   d(k) = 2.^(n-1:-1:0)*b;
end
