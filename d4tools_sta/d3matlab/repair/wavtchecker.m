function    [tdiff,F,fs] = wavtchecker(basedir,fbase,suffix)
%
%    [tdiff,F,fs] = wavtchecker(basedir,fbase,suffix)
%

if nargin<3 || isempty(suffix),
   suffix = 'wav' ;
end

if ~isempty(basedir) && ~ismember(basedir(end),{'\','/'}),
   basedir(end+1) = '\' ;
end

dirn = dir([basedir fbase '*.xml']) ;
xx = readd3xml([basedir dirn(1).name]) ;
fs = getfs(xx,suffix) ;
dirn = dir([basedir fbase '*.wavt']) ;
firsttime = -1 ;
F = [] ;
for k=1:length(dirn),
   [X,fields] = readcsv([basedir dirn(k).name]) ;
   suff = strcmp({X(:).SUFFIX},suffix)' ;
   kk = find(suff==1) ;
   rtime = str2num(strvcat(X(kk).RTIME)) ;
   mticks = str2num(strvcat(X(kk).MTICKS)) ;
   nsamps = str2num(strvcat(X(kk).NSAMPS)) ;
   stat = str2num(strvcat(X(kk).STATUS)) ;
   if firsttime == -1,
      firsttime = rtime(1) ;
   end
   t = (rtime-firsttime)+mticks/1e6 ;
   F = [F; k*ones(length(kk),1),t,nsamps/fs stat] ;
end

tdiff = [F(1:end-1,1) F(2:end,2)-(F(1:end-1,2)+F(1:end-1,3))]
return


function    [fs,fsne,k] = getfs(d3,suffix)
%
%
fs = [] ;
if ~isfield(d3,'CFG'),
   return
end

for k=1:length(d3.CFG),
   c = d3.CFG{k} ;
   if ~isfield(c,'FTYPE'), continue, end
   if ~strcmp(c.FTYPE,'wav'), continue, end
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strncmp(c.SUFFIX,suffix,length(suffix)), continue, end
   if ~isfield(c,'FS'), continue, end
   if isfield(c,'EXP'),
      c.EXP(c.EXP=='_') = '-' ;     % reverse the fix in readd3xml to overcome Matlab
                                    % field name restrictions
      expn = str2double(c.EXP) ;
   else
      expn = 0 ;
   end
   fsne = str2double(c.FS) ;
   fs = fsne * 10^expn ;
   break ;
end
return
