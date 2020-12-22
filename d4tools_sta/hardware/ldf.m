function    fname = ldf(path,suffix)
%
%    fname = ldf(path,suffix)
%

if nargin == 0 || isempty(path),
   path = '/tag/temp/' ;
end

[fname pname] = uigetfile([path '*.dtg'],'Pick a file') ;
if fname == 0,
   fname = [] ;
   commandwindow
   return
end
fname = [pname fname(1:find(fname=='.')-1)] ;

% catch case that there is a new dtg file with the same name as a previously
% unpacked one
if exist([fname '.xml'],'file') && exist([fname '.dtg'],'file')
	dxml = dir([fname '.xml']) ;
	ddtg = dir([fname '.dtg']) ;
   if dxml.datenum < ddtg.datenum,
      delete([fname '.xml']) ;
   end
end

% unpack file if needed
if ~exist([fname '.xml'],'file')
   system(['/tag/projects/d4/host/d4host_dev/d4read.exe ' fname]);
end

if nargin==2 && ~isempty(suffix),
   fname = [fname '.' suffix] ;
end

commandwindow
