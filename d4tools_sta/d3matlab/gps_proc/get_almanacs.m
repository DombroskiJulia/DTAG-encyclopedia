function    [EPH,enum] = get_almanacs(T)
%
%    [EPH,enum] = get_almanacs(T)
%     Get GPS satellite almanacs covering UTC times in matrix T.
%     Each row of T is a 6-digit date vector [yr mon day hr min sec].
%     EPH is a cell array of ephemeri.
%     enum is the number of ephemeris corresponding to each time in T
%
%     markjohnson@st-andrews.ac.uk
%     www.soundtags.org
%     20 January 2017

EPH = [] ;
if size(T,2)==1,
   T = T(:)' ;    % make sure T is a row vector if only one time vector
end

% Get almanacs that cover at least up to 3000s before each grab to
% allow interpolator to function well over required interval. 
% We will also read in the following almanacs in case they are needed.
T(:,6) = T(:,6)-3000 ;  
[w,d,s]=gps_week(T) ;
fnum = w*10+d ;
fn = unique(fnum) ;
for k=1:length(fn),
   ff = fn(k); 
   fprintf('Getting almanac %d of %d\n',k,length(fn)) ;
   efname = get_almanac(floor(ff/10),round(10*rem(ff/10,1))) ;
   if ~isempty(efname),
      sp3 = read_sp3(efname) ;
      % read in the following ephemeris file and append some sets
      % of SV positions to allow interpolation across file boundaries.
      ff = ff+1 ;
      if round(10*rem(ff/10,1))>6,
         ff = ff+3 ;
      end
      efname = get_almanac(floor(ff/10),round(10*rem(ff/10,1))) ;
      if ~isempty(efname),
         sp3p = read_sp3(efname) ;
         kk = find(diff(sp3p.data(:,2))) ;
         sp3.data(end+(1:kk(7)),:) = sp3p.data(1:kk(7),:) ;
      end
      EPH{k} = interp_ephem(sp3) ;
      %round(EPH{k}{1}([1 end],1)')
   else
      fprintf('Unable to find ephemeris file for week-day %05d\n',fn(k)) ;
   end
end

enum = zeros(size(T,1),1) ;
for k=1:size(T,1),
   enum(k) = find(fn==fnum(k)) ;
end
