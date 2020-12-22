function    v = e24(decade)
%
%    v = e24(decade)
%

v = [10  12  15  18  22  27  33  39  47  56  68  82 ...
     11  13  16  20  24  30  36  43  51  62  75  91] ;

v = sort(v)/10 ;
if nargin>=1,
   v = v*10^decade ;
end
