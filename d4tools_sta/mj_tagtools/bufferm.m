function    X = bufferm(x,n,m)
%
%    X = bufferm(x,n,m)
%     Apply buffer with settings n and m to the columns of matrix x.
%     The result is a three dimensional matrix with a column for each
%     extracted signal.
%     If x is r x c, X will be n x floor(r/(n-m)) x c.

[xx,z]=buffer(x(:,1),n,m,'nodelay');
X = zeros([size(xx,1),size(xx,2),size(x,2)]) ;

if size(x,2)==1,
   X = xx ;
   return
end

X(:,:,1) = xx ;

for k=2:size(x,2),
   [X(:,:,k),z]=buffer(x(:,k),n,m,'nodelay');
end
