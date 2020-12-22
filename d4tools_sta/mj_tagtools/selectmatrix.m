function    M = selectmatrix(N,BIN)
%
%    M = selectmatrix(N)
%

if nargin==1 | BIN==0,
   N = N-min(N) ;
   k = unique(N) ;
   M = [ones(length(N),1),zeros(length(N),length(k)-1)] ;
   for k=1:length(N),
      M(k,:) = circ(M(k,:),N(k)) ;
   end
else
   nb = ceil(log(max(N))/log(2))+1 ;
   M = zeros(size(N,1),nb) ;
   k = find(N<0) ;
   M(k,1)=1 ;
   k = find(N>0) ;
   for kk=k',
      M(kk,:) = unpack(N(kk),nb)' ;
   end
end
