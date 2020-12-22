function    n = interppk(x,y)
%
%    n = interppk(x,y)
%

x = x(:) ; y = y(:) ;
[m n] = max(y) ;
k = n+(-2:2) ;
k = k(find(k>0 & k<=length(x))) ;
pp = polyfit(x(k),y(k),2) ;
n = -pp(2)/(2*pp(1)) ;
