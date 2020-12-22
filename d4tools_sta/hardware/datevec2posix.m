function    t = datevec2posix(dv)

%    t = datevec2posix(dv)
%
%

if nargin==0,
   dv = clock ;
end

ref = [1970 1 1 0 0 0] ;
t = round(etime(dv,ref)) ;
