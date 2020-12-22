function    [az,el]=azel(X)
%
%    [az,el]=azel(X)
%

el = asin(X(:,3)./norm2(X)) ;
az = atan2(X(:,2),X(:,1)) ;
