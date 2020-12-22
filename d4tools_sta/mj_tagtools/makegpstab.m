function       Q = makegpstab(tag,NOSAVE)
%
%   Q = makegpstab(tag,NOSAVE)
%

Q = [] ;
if nargin<1,
   help makegpstab
   return
end

fs = 96e3 ;
PINTVL = 10 ;
gpsdir = '/tag/tag2/metadata/gps' ;
if isletter(tag(end)),
   tag = tag(1:end-1) ;
end
N = gettagnames(tag) ;
M = NaN*zeros(size(N,1),2) ;
P = cell(1,size(N,1)) ;

for k=1:size(N,1),
   p = readgtx(N(k,:)) ;
   if ~isempty(p) & isstruct(p),
      [ppmci,TD,P{k}] = clockanal(p,fs) ;
      M(k,:) = [min(P{k}.gpstime) max(P{k}.gpstime)] ;
      loadcal(N(k,:),'CUETAB') ;
      P{k}.cuetime = P{k}.cuetime + CUETAB(1,2) ;
   end
end

% make cue-utc lookup table
Q = (nanmin(M(:,1)):PINTVL:nanmax(M(:,2)))' ;
Q(:,2:length(P)+3) = NaN ;

for k=1:length(P),
   if ~isempty(P{k}),
      kk = nearest(Q(:,1),P{k}.gpstime,0.001) ;
      kkk = find(~isnan(kk)) ;
      Q(kk(kkk),2) = P{k}.latitude(kkk) ;
      Q(kk(kkk),3) = P{k}.longitude(kkk) ;
      Q(kk(kkk),3+k) = P{k}.cuetime(kkk) ;
   end
end

if nargin<2 | isempty(NOSAVE),
   fn = [gpsdir,'/',tag,'gtx'] ;
   save(fn,'Q','N') ;
end
