function    [f,q,r3]=sak_rc2fq(r1,r2,c1,c2,k)
%
%    [f,q,r3]=sak_rc2fq(r1,r2,c1,c2,k)
%     k is the gain of the filter. Default value is 1.
%     If k is less than one it is used to determine the value
%     of a resistor to ground at the input of the gain
%     stage. This is used to attenuate the signal. The resistor
%     value is returned as r3.


if nargin<5,
   k = 1 ;
end

if k<1,
   r3 = (r1+r2)*k/(1-k) ;
   K = k ;
   k = 1 ;
else
   r3 = Inf ;
   K = 1 ;
end

w = 1/sqrt(K*r1*r2*c1*c2) ;
f = w/(2*pi) ;

if K==1,
   q = 1/(w*(c2*(r1+r2)+c1*r1*(1-k))) ;
else
   q = 1/(w*K*(c2*(r1+r2)+c1*r1*r2/r3)) ;
end
