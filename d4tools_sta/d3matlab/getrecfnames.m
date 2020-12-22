function    [fn,did,recn,recdir] = getrecfnames(recdir,prefix,silent)
%    [fn,devid,recn,recdir] = getrecfnames(recdir,prefix,silent)
%     Get the file names, tag id numbers and recording numbers
%     of a set of recordings in a directory with path recdir
%
%     mark johnson
%     31 Oct. 2009
%     bug fix: FHJ 8 april 2014

fn = {} ; did = [] ; recn = [] ;

if nargin<1,
   help getrecfnames
   recdir = [] ;
   return
end

if nargin<3,
   silent = 0 ;
end

if ~exist(recdir,'dir'),
   if ~silent,
      fprintf(' No directory %s\n', recdir) ;
   end
   return
end

if length(recdir)>1 & ismember(recdir(end),['/','\']),
   recdir = recdir(1:end-1) ;
end

recdir = [recdir,'/'] ;       % use / for MAC compatibility
recdir(recdir=='\') = '/' ;

% check if a dir file is already made
tempdir = gettempdir ;
dirfname = [tempdir,'_' prefix,'dir.mat'] ;

if exist(dirfname,'file'),
   load(dirfname) ;
   if vers==d3toolvers,
      return
   end
end

ff = dir([recdir,prefix,'*.xml']) ;

for k=1:length(ff),
   nm = ff(k).name ;
   fn{end+1} = strtok(nm,'.') ;
end

if isempty(fn),
   if ~silent,
      fprintf(' No recordings starting with %s found in directory %s\n', prefix, recdir) ;
   end
   return
end

if nargout == 1,
   return
end

fprintf(' Looking for valid recordings... ') ;
did = zeros(length(fn),1) ;
recn = did ;
fprintf('Reading file...    ') ;
for k=1:length(fn),
   nn = str2double(fn{k}(end+(-2:0))) ;
   if isnan(nn), continue, end
   fprintf('\b\b\b%03d',k) ;
   recn(k) = nn ;
   fnm = [recdir fn{k}] ;
   id = getxmldevid(fnm) ;
   if ~isempty(id),
      did(k) = id ;
   end
end

kk = find(did~=0) ;
recn = recn(kk) ;
did = did(kk) ;
fn = {fn{kk}} ;
fprintf('\n %d recordings found\n',length(kk)) ;

vers = d3toolvers ;
save(dirfname,'fn','recn','did','vers') ;
