function		h = gimbal(M,A,H0)
%
%		h = gimbal(M,A,H0)
%

if nargin==2,
   H0 = 0 ;
end

[pitch roll] = pr(A,1) ;
h = heading(M,pitch,roll,H0,1) ;
