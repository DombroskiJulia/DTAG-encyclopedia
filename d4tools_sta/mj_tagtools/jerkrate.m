function    JR = jerkrate(Aw,fs,jt,tave)
%
%    JR = jerkrate(Aw,fs,jt,tave)
%     Compute large jerk event rate over intervals in tag data.
%     Aw is the animal-frame acceleration matrix.
%     fs is the sampling rate of Aw in Hz
%     jt is a vector of thresholds containing:
%        jt(1) = jerk threshold re 1m/s3 for detecting a jerk event
%        jt(2) = no-detect time after each event in seconds
%     tave is the averaging time to use in seconds.
%
%     Return:
%     JR contains the time of each interval (first column) and the
%        average jerk event rate per second in the interval (2nd column).
%
%     markjohnson@st-andrews.ac.uk
%     june 2016

if nargin<3 || isempty(jt),
   jt = [10,10] ;
end

if nargin<4,
   tave = 3600 ;
end

J = njerk(Aw,fs) ;
nave = floor(length(J)/(fs*tave)) ;
JR = zeros(nave,2) ;
ts = tave*(0:nave-1)' ;
JR(:,1) = ts+tave/2 ;

OPTS.protocol = 'raw' ;
OPTS.blanking = jt(2) ;
OPTS.env = 1 ;
TS = getclickx(J,jt(1),fs,OPTS) ;

for k=1:nave
   JR(k,2) = sum(TS>=ts(k,1) & TS<(ts(k,1)+tave)) ;
end

JR(:,2) = JR(:,2)/tave ;
