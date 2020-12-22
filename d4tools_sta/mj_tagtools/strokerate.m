function    [SR,flk] = strokerate(Aw,p,fs,thr,tave)
%
%    [SR,flk] = strokerate(Aw,p,fs,thr,tave)
%     Compute fluke stroke rate over intervals in tag data.
%     Strokes are detected by fluctuations in ax which works well for
%     low pitch angles - this tool is only reliable for shallow divers.
%     Aw is the animal-frame acceleration matrix.
%     p is the dive depth vector
%     fs is the sampling rate of Aw and p in Hz
%     thr is a vector of thresholds containing:
%        thr(1) = acceleration threshold re 1g for detecting a stroke
%        thr(2) = nominal fluke stroke rate in Hz
%        thr(3) = minimum depth of fluke strokes in m
%     tave is the averaging time to use in seconds.
%
%     Return:
%     SR contains the time of each interval (first column) and the
%        average stroking rate in the interval (strokes/second, 2nd column).
%     flk contains the time cue in seconds of each half fluke stroke found
%
%     markjohnson@st-andrews.ac.uk
%     june 2016

if nargin<4 || isempty(thr),
   thr = [0.05,0.15,2] ;
end

if nargin<5,
   tave = 3600 ;  % default is to average over an hour
end

fc = thr(2)*0.5 ;    % filter cutoff frequency is one half of stroking rate
Af = fir_nodelay(Aw,round(fs/fc*5),fc/(fs/2),'high');
K = findzc(Af(:,1),thr(1),round(fs/fc)) ;
F = (K(:,1)+K(:,2))/(2*fs) ;
F = F(p(round(fs*F))>thr(3)) ;

nave = floor(size(Aw,1)/(fs*tave)) ;
SR = zeros(nave,2) ;
ts = tave*(0:nave-1)' ;
SR(:,1) = ts+tave/2 ;

for k=1:nave    % count half strokes in each interval
   SR(k,2) = sum(F>=ts(k,1) & F<(ts(k,1)+tave)) ; 
end

SR(:,2) = SR(:,2)/tave/2 ;    % mean stroking rate over the interval
flk = F ;
