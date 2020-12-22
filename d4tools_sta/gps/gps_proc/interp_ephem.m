function    POS = interp_ephem(s)
%    POS = interp_ephem(s)
%  Interpolate the satellite positions in an ephemeris to
%  1 minute intervals.
%  s is an ephemeris structure from a SP3 file. Use read_sp3.m
%  to read the file.
%  The columns of s.data are: 
%     [GPS_week GPS_TOW PRN x y z clk_err]
%     GPS_TOW (time of week) is in seconds
%  POS has a cell for each satellite with columns:
%     [TOW x y z clk_err]
%
%  markjohnson@st-andrews.ac.uk
%  15 October 2012

NSV = max(s.data(:,3)) ;
T0 = min(s.data(:,2)) ;
W0 = min(s.data(:,1)) ;
POS = cell(1,NSV) ;
n = [] ;
for sv=1:NSV,
   k = find(s.data(:,3)==sv);
   if isempty(k), continue, end
   pos = s.data(k,4:6) ;
   t = s.data(k,2)+7*24*3600*(s.data(k,1)-W0) ;
   tintv = mean(diff(t)) ;
   intf = round(tintv/10) ;   % interpolation factor for 10s samples
   ts = linspace(min(t),max(t),intf*length(t))' ;
   % fft method - ought to work well but doesn't - why not?
   %f = fft(pos) ;
   %nm = length(k) ;
   %ff = intf*[f(1:nm/2,:);zeros(size(f,1)*(intf-1),3);f(nm/2+1:end,:)] ;
   %posi = real(ifft(ff)) ;

   % simple interp works well but only with a spline, not a cubic
   posi = interp1(t,pos,ts,'spline') ;
   ce = interp1(t,s.data(k,7),ts,'spline') ;
   POS{sv} = [ts posi ce] ;			
end
