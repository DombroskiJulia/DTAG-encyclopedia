function    b = unpack(x,n)
%
%   b = unpack(x,n)
%

V = abs(dec2bin(x,n))'>48 ;
b = V(:) ;
