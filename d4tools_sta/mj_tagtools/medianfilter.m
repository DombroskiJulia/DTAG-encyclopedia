function    Y = medianfilter(X,n,noend)
%
%    Y = medianfilter(X,n)
%     computes the nth-order median filter on the columns
%     of X. The start and end values are computed with
%     decreasing order median filters.
%    Y = medianfilter(X,n,1)
%     Start and end values are taken directly from X without
%     short median filters.

if size(X,1)==1,
   X = X(:) ;
end

nd2 = floor(n/2) ;
if 2*nd2==n,
   n = n+1 ;
end

Y = repmat(NaN,size(X)) ;
if nargin==3 & noend,
   Y(1:nd2,:) = X(1:nd2,:) ;
   Y(end+(-nd2+1:0),:) = X(end+(-nd2+1:0),:) ;
else
   for k=1:nd2,
      Y(k,:) = nanmedian(X(1:k+nd2,:)) ;
   end
   for k=1:nd2,
      Y(end-nd2+k,:) = nanmedian(X(end-2*nd2+k:end,:)) ;
   end
end

for k=1:size(X,2),
   Z = buffer(X,n,n-1,'nodelay') ;
   Y(nd2+1:end-nd2,k) = nanmedian(Z)' ;
end

