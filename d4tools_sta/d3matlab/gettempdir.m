function    d=gettempdir

%    d=gettempdir

d = [fileparts(which('makecuefile')) '/temp/'] ;
if ~exist(d,'dir'),
   mkdir(d) ;
end
