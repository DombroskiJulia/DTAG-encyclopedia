function    v = e12(decade)
%
%    v = e12(decade)
%

v = [10  12  15  18  22  27  33  39  47  56  68  82] ;

v = sort(v)/10 ;
if nargin>=1,
   v = v*10^decade ;
end
