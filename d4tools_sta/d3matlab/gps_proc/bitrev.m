function		y = bitrev(x,n)

%
%		y = bitrev(x,n)
%

nn = ceil(log10(n)/log10(2)) ;
X = reshape(unpack(x(:),nn),nn,[]) ;
bm = 2.^(0:(nn-1)) ;
y = (bm*X)' ;
