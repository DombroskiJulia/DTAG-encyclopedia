function    [tc,err,N] = gps_timesearch(Obs,pos,tc,THR,excl,silent)
%
%    [tc,err,N] = gps_timesearch(Obs,pos,tc,[THR])
%     Search for the coarse time offset between the tag-reported times and
%     the true GPS time.
%     Obs is an observation structure or structure array returned 
%     by d3preprocgps.m. If Obs is a structure array, the first 
%     observation with at least 6 SVs with SNR above threshold will be
%     analysed.
%     pos = [latitude,longitude] is an estimate of the position of the
%     animal associated with the GPS observations.
%     tc = [min_time max_time] specifies the range of time offsets 
%     in seconds to search over.
%     THR is an optional power threshold allowing SVs with low SNR to be
%     excluded from the analysis.
%     
%     Returns:
%        tc is the time offset (seconds) in the search range that minimizes the RMS
%         pseudo-range error.
%        err is the corresponding RMS pseudo-range error (metres).
%        N = [pseudo-range_error,time] is the results for all times in
%         search.
%
%     markjohnson@st-andrews.ac.uk
%     www.soundtags.org
%     20 January 2017

intvl = 3 ;    % number of seconds between trials in the search
tc = min(tc):intvl:max(tc) ;
N = NaN*zeros(length(tc),7) ;

if nargin<4 || isempty(THR),
   THR = 150 ;
end

if nargin<6,
   silent = 0 ;
end

for k=1:length(Obs),
   nsv = sum(Obs(k).snr>10*log10(THR)) ;
   if nsv>=6, break, end
end
if silent==0,
   if nsv<6,
      fprintf('No observation found with 6 or more SVs - lower THR\n') ;
   else
      fprintf('Processing observation %d with %d SVs\n',k,nsv) ;
   end
end

Obs = Obs(k) ;
T = datevec(datenum(Obs.T)+[min(tc)-3000;max(tc)+3000]/(24*3600)) ;
EPH = get_ephem(T,1) ;
if isempty(EPH), 
   tc = [] ;
   err = [] ;
   return
end
EPH = EPH{1} ;

if nargin>=5,
   % if any SVs are to be excluded, give them an artificial low snr
   Obs.snr(excl) = 10 ;
end

p = [Obs.sv, 10.^(Obs.snr/10), Obs.del] ;
ksv = find(p(:,2)>THR) ;
if silent==0,
   figure(1),clf
   subplot(212),hold on,set(gca,'XLim',[min(tc),max(tc)]),grid
   xlabel('Coarse time offset (s)')
   ylabel('log RMS prange error (log-m)')
   subplot(211),hold on
   xlabel('Fine time offset (s)')
   ylabel('RMS prange error (m)')
end

for k=1:length(tc),
   pp = proc_posn(p,pos,Obs.T,EPH,tc(k)) ;
   if ~isempty(pp),
      N(k,:) = pp ;
      if silent==0,
         subplot(212)
         plot(tc(k),log10(pp(end-2)),'.'),hold on
         subplot(211)
         drawnow
      end
   end
end

[err,k] = nanmin(N(:,5)) ;
tc = N(k,6) ;
