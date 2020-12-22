function    [r3,r4] = mfp_filter(f,Q,k,c1,c2)
%
%  [r3,r4] = mfp_filter(f,Q,k,c1,c2)
%
%          ----r3----        
%     -r1- -r2-  -c2-
%         c1      
%
%  k = r3/r1

w = 2*pi*f ;
g = k+1 ;
r3 = roots([1 -1/(g*Q*w*c2) 1/(g*w^2*c1*c2)]) ;
r4 = 1/(Q*w*c2)-g*r3 ;
