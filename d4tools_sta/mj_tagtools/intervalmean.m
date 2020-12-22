function    E = intervalmean(x,fs,T,keepout)
%
%    E = intervalmean(x,fs,T,keepout)
%

if nargin<4,
   keepout = [0,0] ;
end

if length(keepout)==1,
   keepout(2) = keepout ;
end

T(:,1) = T(:,1)+keepout(1) ;
T(:,2) = T(:,2)-keepout(2) ;

E = zeros(size(T,1),1) ;
for k=1:size(T,1),
   kk = round(T(k,1)*fs):round(T(k,2)*fs) ;
   E(k) = mean(x(kk)) ;
end
