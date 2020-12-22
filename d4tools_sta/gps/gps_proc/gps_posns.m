function    [POS,N,gps] = gps_posns(Obs,pos,tc,THR,kproc)

%     [POS,N,gps] = gps_posns(Obs,pos,tc,[THR,kproc])
%     Search for the positions corresponding to pre-processed GPS grabs.
%     Obs is an observation structure or structure array returned 
%     by d3preprocgps.m or proc_gpsbinfile.m
%     pos = [latitude,longitude] is an estimate of the starting position 
%       of the animal (decimal degrees, -ve for south and west).
%     tc = [min_time max_time] specifies the range of time offsets 
%       in seconds between the tag-reported time and the actual GPS time
%       to search over.
%     THR is an optional power threshold allowing SVs with low SNR to be
%       excluded from the analysis.
%     kproc allows specification of a subset of the observations to
%       process. Default is to process all of the observations.
%     
%     Returns:
%        lat is the latitude for each grab in decimal degrees.
%        lon is the longitude for each grab in decimal degrees.
%        h is the altitude above the reference geoid for each grab in metres.
%        t is the Matlab datenum of each grab
%        N is a vector of SV and timing quality information for each grab.
%           Columns are: number of SVs
%                        mean snr
%                        estimated time offset in seconds
%                        RMS residual pseudorange in m
%
%     markjohnson@st-andrews.ac.uk
%     www.soundtags.org
%     20 January 2017

if nargin>=5 && ~isempty(kproc),
   kproc = kproc(kproc<=length(Obs)) ;
   Obs = Obs(kproc) ;
end

if nargin<4 || isempty(THR),
   THR = 150 ;
end

if length(tc)==1,
   tc = tc+[-20 20] ;
end

SRCH_THR = 100 ;      % threshold in RMS pseudo-range error (m) for re-search
EXCL_THR = 50 ;       % threshold in RMS pseudo-range to check excluding a SV
MIN_SV = 5 ;
MAX_SV = 10 ;

% get almanacs for the period +/- a buffer interval
T = vertcat(Obs.T) ;
T = datevec(datenum(T)+mean(tc)/(24*3600)) ;
[EPH,enum] = get_almanacs(T) ;
TC = mean(tc) ;
tc = tc-TC ;

lat = NaN*zeros(length(Obs),1) ;
lon = NaN*zeros(length(Obs),1) ;
h = NaN*zeros(length(Obs),1) ;
t = NaN*zeros(length(Obs),1) ;
N = NaN*zeros(length(Obs),4) ;
tt = [mean(tc) 1] ;
excl = [] ;
figure(1), clf, grid on, hh = [];

for k=1:length(Obs),  % estimate a position for each grab
   p = [Obs(k).sv, 10.^(Obs(k).snr/10), Obs(k).del] ;
   eph = EPH{enum(k)} ;
   nsv = sum(p(:,2)>THR) ;
   if nsv<MIN_SV,
      continue
   end
   
   %tgps = utc2gps(T(k,:)) ;		% just for debugging
   %round(tgps)
   %round(eph{1}([1 end],1)')

   fprintf('Processing observation %d of %d (#SV=%d)...',k,length(Obs),nsv) ;
   if nsv>MAX_SV,
      [mm,I] = sort(p(:,2)) ;
		p(I(1:32-MAX_SV),2) = 1 ;
		nsv = MAX_SV ;
   end
   
   if tt(2)==1,  % if no good time offset, search for it
      pp = searchtc(p,T(k,:),eph,pos,tc,THR) ;
   else
      pp = proc_posn(p,pos,T(k,:),eph,tt(1),THR,1) ;
   end
   
   if nsv>MIN_SV && ~isempty(pp) && pp(end-2)>EXCL_THR,
      if ~isempty(excl) && p(excl,2)>THR,
         px1 = p ;
         px1(excl,2) = 0 ;
         if tt(2)==1,  % if no good time offset, search for it
            pp = searchtc(px1,T(k,:),eph,pos,tc,THR) ;
         else
            pp = proc_posn(px1,pos,T(k,:),eph,tt(1),THR,1) ;
         end
      end
   end
   
   if nsv>MIN_SV && isempty(pp),
      [pp,excl] = searchall(p,T(k,:),eph,pos,tc,THR) ;
   end
      
   if isempty(pp), 
      fprintf(' no position\n') ;
      continue
   end
   
   % if RMS error is large and no time search performed, do a time search
   if pp(end-2)>SRCH_THR && tt(2)==0,
      pp = searchtc(p,T(k,:),eph,pos,tc,THR) ;
   end
   
   % if RMS error is still large redo search excluding one SV
   if (isempty(pp) || pp(end-2)>SRCH_THR) && nsv>MIN_SV && isempty(excl),
      [pp,excl] = searchall(p,T(k,:),eph,pos,tc,THR) ;
   end
   
   % if RMS error is still large, increase threshold and redo search excluding one SV
   if (isempty(pp) || pp(end-2)>SRCH_THR) && (nsv>MIN_SV+1),
      [ss,I] = sort(p(:,2)) ;
      ks = find(ss>THR,1) ;
      p(I(ks),2) = 0 ;
      [pp,excl] = searchall(p,T(k,:),eph,pos,tc,THR) ;
   end
   
   if isempty(pp), 
      fprintf(' no position\n') ;
      continue
   end
   
   % convert ECEF positions to lat-long-altitude
   lla = ecef2lla(pp(1:end-3));
   lat(k) = lla(:,1)*180/pi ;   % latitude in degrees
   lon(k) = lla(:,2)*180/pi ;   % longitude in degrees
   if lon(k)>180,
      lon(k) = lon(k)-360 ;
   end
   h(k) = lla(3);             % altitude above the geoid
   N(k,:) = [nsv mean(p(p(:,2)>THR,2)) pp(end-1)+TC pp(end-2)] ;
   T(k,6) = T(k,6)+pp(end-1) ;
   t(k) = datenum(T(k,:)) ;

	if ~isempty(hh),
		set(hh,'Color','b','MarkerSize',6)
	end
   hh = plot(lon(k),lat(k),'r.');hold on,drawnow
   set(hh,'MarkerSize',20)
	
   if isempty(excl),
      fprintf(' prange residual %d m\n',round(pp(end-2))) ;
   else
      fprintf(' excl SV%02d, prange residual %d m\n',excl,round(pp(end-2))) ;
   end
   
   if pp(end-2)<SRCH_THR && pp(end-2)>1 && abs(h(k))<200,    % if positional accuracy is good update time offset
      if tt(2)==1,      % if last time was bad, just adopt new time
         tt = [pp(end-1) 0] ;
      else              % otherwise adjust to mean
         tt = [mean([tt(1) pp(end-1)]) 0] ;     % update time offset
      end
		tc = tt(1)+diff(tc)/2*[-1 1];
      pos = [lat(k) lon(k)] ;
      fprintf(' Adjusting time offset to %3.2f\n',TC+tt(1));
         
   else  % otherwise flag to search for time offset on next obs
      tt(2) = 1 ;
   end
   
   if rem(k,10)==0,
		[POSS,NN,gps] = convposns(lat,lon,h,t,N) ;
      save _gpsposn_part.mat gps
   end
end

[POS,N,gps] = convposns(lat,lon,h,t,N) ;
return


function		[POS,N,gps] = convposns(lat,lon,h,t,N)
%
gps.lat = lat ;
gps.lon = lon ;
gps.T = t ;
gps.h = h ;
gps.n = N ;
k=find(h>-100 & h<200 & N(:,4)<200);
gps.k = k ;

POS.T = t(k) ;
POS.lat = lat(k) ;
POS.lon = lon(k) ;
POS.h = h(k) ;
N = N(k,:) ;
return


function    pp = searchtc(p,T,eph,pos,tc,THR)
%
intvl = 3 ;    % number of seconds between trials in the search
tc = min(tc):intvl:max(tc) ;
N = NaN*zeros(length(tc),7) ;
for k=1:length(tc),
   pp = proc_posn(p,pos,T,eph,tc(k),THR,1) ;
   if ~isempty(pp),
      N(k,:) = pp ;
   end
end
[err,k] = nanmin(N(:,5)) ;
if isnan(err),
   pp = [] ;
else
   pp = N(k,:) ;
end
return


function    [pp,excl] = searchall(p,T,eph,pos,tc,THR)
%
ksv = find(p(:,2)>THR) ;
N = NaN*zeros(length(ksv),7) ;
for k=1:length(ksv),
   %fprintf('excluding %d\n',ksv(k));
   px1 = p ;
   px1(ksv(k),2) = 0 ;
   pp = searchtc(px1,T,eph,pos,tc,THR) ;
   if ~isempty(pp),
      N(k,:) = pp ;
   end
end

[err,k] = nanmin(N(:,5)) ;
if isnan(err),
   pp = [] ;
else
   pp = N(k,:) ;
end
excl = ksv(k) ;
return

