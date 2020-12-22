function    [r1,r2]=sak_c2r(f,q,c1,c2,k)
%
%    [r1,r2]=sak_c2r(f,q,c1,c2,k)
%

if nargin<5,
   k = 1 ;
end

w = 2*pi*f ;
a = (c2+c1*(1-k))/(w^2*c1*c2^2) ;
b = 1/(w*c2*q) ;
r2 = roots([1 -b a]) ;
r1 = 1./(r2*c1*c2*w^2) ;
