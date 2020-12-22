function    [y,h] = dmoncleanupblk(x,NOPOSTEMPH)
%
%    [y,h] = dmoncleanupblk(x,NOPOSTEMPH)
%

thrfact = 1.5 ;
%thrfact=5;
if nargin<1,
   dmoncleanupblk ;
end

N = 48 ;
FS = 96e3 ;

[b,a] = butter(1,[10e3 40e3]/(FS/2)) ;      % make an equalizing filter
f = [1 0.98 0.98^2] ;
b = b.*f ; a = a.*f ;               % move the poles and zeros inside the unit circle
                                    % so that the filter is invertible
xf = filter(b,a,x) ;
y = zeros(length(x),1) ;
bl = floor(length(x)/N) ;
R = hadamard(N) ;

% assemble the block least squares matrix and vector
% the solution is easy because the covariance matrix is the identity
% just have to make the cross-correlation vector
blk = (0:bl-1)*N ;
h = zeros(N,1) ;
xf = buffer(xf,N,0,'nodelay') ;
sx = std(xf) ;
thr = thrfact*prctile(sx,5) ;
k = find(sx<thr) ;
if isempty(k),
   y = x ;
   h = [] ;
   return ;
end

h = mean(xf(:,k)'*R,1)'/N ;

% calculate and save the prediction error
for k=1:bl,
   kk = blk(k)+(1:N) ;
   y(kk) = xf(:,k)-R*h ;
end

if nargin<2,
   y = filter(a/b(1),b/b(1),y) ;
end
