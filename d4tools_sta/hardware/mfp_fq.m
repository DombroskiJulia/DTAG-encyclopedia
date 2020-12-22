function    [f,Q] = mfp_fq(r2,r3,k,c1,c2)
%
%  [f,Q] = mfp_fq(r2,r3,k,c1,c2)
%
%          ----r3----        
%     -r1- -r2-  -c2-
%         c1      
%
%  k = r3/r1

g = k+1 ;
f = 1./sqrt(r2.*r3*c1*c2)/2/pi ;
Q = 1/(2*pi*f*c2*(r3+g*r2)) ;
