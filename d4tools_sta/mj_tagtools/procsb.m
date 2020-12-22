function    [T,DTAB] = procsb(stag,rtag,SStab,CL,Dd,Ds)
%
%    [T,DTAB] = procsb(stag,rtag,SStab,CL,Dd,Ds)
%
% example:
% load /tag/matlab/data/md08_289asoundspeed
% load /tag/tag2/metadata/clicks/md08_289acl_dive3
% load /tag/tag2/metadata/clicks/md08_289abuoy
% T=procsb('md08_289a','by08_289a',SStab,CL,Da,Dsa);
%
% makes the delay table with columns:
% T = [CL slant_range_direct_interpolated slant_range_from_surface_bounce
%      horizontal_distance_estimate clock_offset_estimate clock_offset_raw]
% CL is in source time, the delays are in rx-srce time

% DTAB has columns [CL,direct_path_delay,surface_bounce_delay]
DTAB = delaytab(CL,Dd,Ds) ;
k = find(~isnan(DTAB(:,2))) ;
DTAB = DTAB(k,:) ;

% get the depth and temperature of the source tag at the clicking times
loadprh(stag,0,'p','tempr','fs') ;
sk = round(fs*DTAB(:,1)) ;
ps = p(sk) ;
ti = cumsum(tempr)/fs ;
tempr = ti(sk) ;

% get the depth of the receiver for each direct arrival
clear p
loadprh(rtag,0,'p','fs') ;
pr = p(round(fs*(DTAB(:,1)+DTAB(:,2)))) ;

% work out the path integrated sound speed for the direct and surface paths
cd = pathintspeed(SStab,ps,pr) ;
cs = pathintspeed(SStab,ps,-pr) ;

% find when there is both a direct arrival and surface bounce
k = find(all(~isnan(DTAB(:,2:3))')') ;
size(k)

% get the surface-direct TDOA - this is in rx time units
tau = DTAB(k,3)-DTAB(k,2) ;
% estimate the sound production time relative to the direct arrival
cs2 = cs(k).^2 ;
rho = (cs2-cd(k).^2)./cs2 ;
pp = 2*ps(k).*pr(k)./(cs2.*tau) ;
t0 = zeros(length(rho),1) ;
V = [rho/2./tau -ones(length(rho),1) tau/2-pp] ;

for kjk=1:size(V,1),
   rr = roots(V(kjk,:)) ;
   t0(kjk) = min(rr) ;
end

% DTAB(k,2) is the time delay between rx (in rx time) and srce (in srce time) 
% so DTAB(k,2)+t0 is the time delay between srce (rx time - srce time)
% i.e., an estimate of the clock offset between srce and receiver
tsr = DTAB(k,2)+t0 ;

% first order + temperature fit of the clock offset from source to receiver
% assume the receiver is at a constant temperature
% regressor comprises a DC offset, the source click times, the temperature
% deviation from 25 degrees Celsius
R = [ones(size(DTAB,1),1) DTAB(:,1) tempr] ;

% perform the fit when there is a direct and surface bounce
[bb,bint,rr,rrint,stats] = regress(tsr,R(k,:)) ;
stats
std(rr)

% estimate the source time of all clicks in terms of rx clock
tsrhat = R*bb ;
figure(5),clf
plot(DTAB(k,1),tsr,'.'),grid
hold on
plot(DTAB(:,1),tsrhat,'r')

% estimated time of flight for the direct paths from srce to rx is
% DTAB(:,2)-tsrhat. Range estimate is time of flight x path integrated
% sound speed
r = cd.*(DTAB(:,2)-tsrhat) ;

% range estimates for the direct-surface pairs
r(:,2) = NaN ;
r(k,2) = -cd(k).*t0 ;

% convert to horizontal distance
h = sqrt(r(:,1).^2-(ps-pr).^2) ;
tsrhat(:,2) = NaN ;
tsrhat(k,2) = tsr ;
T = [DTAB(:,1) r h tsrhat] ;
