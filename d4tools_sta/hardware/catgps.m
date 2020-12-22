function    [BB,DV,POS] = catgps(B)
%
%    [BB,DV,POS] = catgps(B)
%     Concatenate and parse Gipsy5 data logged by a D4T soundtag
%

n = 0 ;
for k=1:length(B),
   n = max(length(B{k}),n) ;
end

BB = zeros(n,length(B)) ;
for k=1:length(B),
   BB(1:length(B{k}),k) = B{k} ;
end

BB = BB(1:20,:) ;
DV = BB([3 2 1 4 5 6],:)' ;
DV(:,1) = DV(:,1)+2000 ;
LAT = BB(7:11,:)' ;
LAT = LAT*[1 1/60 0.01/60 0.0001/60 0.00001/60]' ;
LAT = LAT .* ((BB(12,:)'==abs('N'))*2-1) ;
LONG = BB(13:17,:)' ;
LONG = LONG*[1 1/60 0.01/60 0.0001/60 0.00001/60]' ;
LONG = LONG .* ((BB(12,:)'==abs('W'))*2-1) ;
POS = [LAT LONG] ;
