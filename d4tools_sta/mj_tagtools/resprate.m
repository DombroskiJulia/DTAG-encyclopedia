function    AR = resprate(p,fs,pt,tave)
%
%    AR = resprate(p,fs,pt,tave)
%     Compute respiration rate over intervals in tag data.
%     Warning: respirations are only inferred from the dive profile using
%     a hysteretic detector. This is only good for animals that do not log.
%     p is the dive depth vector.
%     fs is the sampling rate of p in Hz
%     pt is a vector of thresholds containing:
%        pt(1) = depth that the animal must approach the surface to start a
%        respiration.
%        pt(2) = depth that the animal must dive to finish a
%        respiration. pt(2) > pt(1).
%     tave is the averaging time to use in seconds.
%
%     Return:
%     AR contains the time of each interval (first column) and the
%        average respiration rate per second in the interval (2nd column).
%
%     markjohnson@st-andrews.ac.uk
%     june 2016

if nargin<3 || isempty(pt),
   pt = [0.8,1.2] ;
end

if nargin<4,
   tave = 3600 ;
end

TS = finddives(p,fs,pt(2),pt(1)) ;
nave = floor(length(p)/(fs*tave)) ;
AR = zeros(nave,2) ;
ts = tave*(0:nave-1)' ;
AR(:,1) = ts+tave/2 ;

for k=1:nave
   AR(k,2) = sum(TS(:,2)>=ts(k,1) & TS(:,2)<(ts(k,1)+tave)) ;
end

AR(:,2) = AR(:,2)/tave ;
