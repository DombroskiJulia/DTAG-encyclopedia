function    [S,fn,id] = d3makettab(recdir,prefix,suffix)
%
%    [S,fn,id] = d3makettab(recdir,prefix,suffix)
%     Accumulate a timing table from the t-suffix
%     timing files associated with a D3 wav output stream.
%
%     markjohnson@st-andrews.ac.uk
%     2/09/14 Edited for new wavt format.

S = [] ;
[fn,id,recn,recdir] = getrecfnames(recdir,prefix,1) ;
if isempty(fn),
   return
end

if nargin<3,
   suffix = 'wav' ;
end

% first check if there are '.wavt' files in the new format
for k=1:length(fn),
   fname = [recdir,fn{k},'.wavt'] ;
   if ~exist(fname,'file'), continue, end
   c = csvproc(fname,[],[],1) ;
   ks = strmatch(suffix,{c{:,1}}) ;
   for kk=1:length(ks),
      s = str2double({c{ks(kk),2:end}}) ;
      S(end+1,:) = [k s] ;
   end
end

% if not, check for the old format
if isempty(S),
   for k=1:length(fn),
      fname = [recdir,fn{k},'.',suffix,'t'] ;
      if ~exist(fname,'file'), continue, end
      s = str2double(csvproc(fname,[],[],1)) ;
      S(end+(1:size(s,1)),:) = [k*ones(size(s,1),1) s] ;
   end
end

id = id(1) ;
