function    [R,c1] = mfp_filter1(f,Q,h,c2)
%
%  [R,c1] = mfp_filter1(f,Q,h,c2)
%
%          ----R(3)----        
%     -R(1)- -R(2)-  -c2-
%           c1      
%

k = 2*pi*f*c2 ;
c1 = 4*Q^2*(h+1)*c2 ;
R(1) = 1./(2*Q*h*k) ;
R(2) = 1./(2*Q*(h+1)*k) ;
R(3) = 1./(2*k*Q) ;
