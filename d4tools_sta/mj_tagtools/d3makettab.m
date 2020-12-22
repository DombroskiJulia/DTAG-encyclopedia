function    [S,fn,id] = d3makettab(recdir,prefix,suffix)
%
%    [S,fn,id] = d3makettab(recdir,prefix,suffix)
%     Accumulate a timing table from the t-suffix
%     timing files associated with a D3 wav output stream.
%

S = [] ;
[fn,id,recn,recdir] = getrecfnames(recdir,prefix,1) ;
if isempty(fn),
   return
end

for k=1:length(fn),
   fname = [recdir,fn{k},'.',suffix,'t'] ;
   if ~exist(fname,'file'), continue, end
   s = str2double(csvproc(fname,[],[],1)) ;
   S(end+(1:size(s,1)),:) = [k*ones(size(s,1),1) s] ;
end

id = id(1) ;
