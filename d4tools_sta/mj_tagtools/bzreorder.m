function    kk = bzreorder(BZ,bz,scorefile)
%
%    kk = bzreorder(BZ,bz,scorefile)
%

[bb,I] = sort(bz(:,1)) ;
if I(1)~=1 | any(diff(I))~=1,
   fprintf('bz out of order in audit at cue %5.1f\n',bz(diff(I)~=1)) ;
   bz = bz(I,:) ;
end

if length(BZ.clicks)~=size(bz,1),
   fprintf('length mismatch in bz (%d) and BZ (%d)\n',size(bz,1),length(BZ.clicks)) ;
end

if length(BZ.clicks)<size(bz,1),
   [BZ.clicks{length(BZ.clicks)+1:size(bz,1)}] = deal([]) ;
end

% for each buzz, look for BZ.clicks that is most close
M = NaN*ones(size(bz,1),5) ;
for k=1:size(bz,1),
   N = zeros(length(BZ.clicks),1) ;
   for kk=1:length(BZ.clicks),
      if ~isempty(BZ.clicks{kk}),
         cl = BZ.clicks{kk}(:,1) ;
         N(kk) = sum((cl>=bz(k,1)-0.5) & (cl<=bz(k,1)+bz(k,2)+0.5)) ;
      end
   end
   [N,I] = sort(N) ;
   M(k,:) = [I(end) N(end) I(end-1) N(end-1) length(BZ.clicks{k})] ;
end

k = find(M(:,4)>0.15*M(:,2) & M(:,5)~=0) ;
if ~isempty(k),
   fprintf('Too many common clicks for bz %5.1f\n',bz(k,1)); 
   M(k,:)
end

kk = M(:,1) ;
if any(kk~=(1:size(bz,1))' & M(:,5)~=0),
   fprintf('BZ needs to be re-ordered\n') ;
end

if nargin<3, return, end

% read in score file
[X,fields]=readcsv(scorefile);
cue = str2num(strvcat(X(:).buzz)) ;
[kk,mind] = nearest(bz(:,1),cue) ;
if any(mind>1),
   fprintf('score file has buzz %d cue too far from bz (%5.1f vs %5.1f)\n',...
      kk(mind>1),cue(mind>1),bz(kk(mind>1),1)) ;
end

if any(isnan(kk))
   fprintf('score file has bad matches to bz cues at %5.1f\n',cue(isnan(kk))) ;
end

if size(bz,1)~=length(unique(kk)),
   fprintf('one or more bz does not appear in score file\n') ;
end
