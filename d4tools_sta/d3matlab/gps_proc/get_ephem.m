function    EPH = get_ephem(T,silent)
%
%    EPH = get_ephem(T)
%     T is the 6-element UTC time vector
%

EPH = [] ;
if nargin<2,
   silent = 0 ;
end

% get almanacs for the period
[w,d,s]=gps_week(T) ;
fnum = w*10+d ;
fn = unique(fnum) ;
for k=1:length(fn),
   if silent==0,
      fprintf('Getting almanac %d of %d\n',k,length(fn)) ;
   end
   efname = get_almanac(floor(fn(k)/10),round(10*rem(fn(k)/10,1))) ;
   if round(rem(fn(k)/10,1)*10)==6,
      nn = fn(k)+4 ; % go to day 0 of next week
   else
      nn = fn(k)+1 ;
   end
   efname1 = get_almanac(floor(nn/10),round(10*rem(nn/10,1))) ;
   if ~isempty(efname),
      sp3 = read_sp3(efname) ;
      if ~isempty(efname1),
         sp3a = read_sp3(efname1) ;
         sp3.data = [sp3.data;sp3a.data] ;
      end
      EPH{k} = interp_ephem(sp3) ;
   else
      disp(sprintf('Unable to find ephemeris file for week-day %05d\n',fn(k))) ;
   end
end
