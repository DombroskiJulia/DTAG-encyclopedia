function    n = interpmin(x,y)
%
%    n = interpmin(x,y)
%

if isempty(y)
   n = [] ;
   return
end

x = x(:) ; y = y(:) ;
[m n] = min(y) ;
k = n+(-2:2) ;
k = k(find(k>0 & k<=length(x))) ;
pp = polyfit(x(k),y(k),2) ;
n = -pp(2)/(2*pp(1)) ;
