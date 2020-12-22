function    dtgfiletype(fname)
%
%    dtgfiletype(fname)
%

if nargin<1,
   [fname,dirr] = uigetfile('*.dtg') ;
   fname =  fullfile(dirr,fname) ;
end

f = fopen(fname) ;
s = fread(f,8,'uchar') ;
fclose(f) ;
fprintf('File type = %s\n',s)
