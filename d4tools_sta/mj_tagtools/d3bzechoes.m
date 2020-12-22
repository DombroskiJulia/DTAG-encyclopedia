function    RR = d3bzechoes(recdir,prefix,CL,intervl,df,tz)
%
%     RR = d3timeindexedechoes(recdir,prefix,CL,intervl,df,tz)
%     Display echogram with a time axis rather than a click axis.
%     tag is the tag deployment string e.g., 'sw03_207a'
%     CL is a vector of click cues
%     intervl = [left right] are the times in seconds to display with
%        respect to each click. Default is [-0.001 0.025].
%     df is the decimation factor (integer>=1) to use in the range-axis
%     tz is an optional zero-cue (i.e., the reference time for the y-axis)
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  December 2006
%

if nargin<5,
    help d3bzechoes
    return
end

if nargin<5 | isempty(df),
   df = 1 ;
end

if nargin<6 | isempty(tz),
   tz = 0 ;
end

MAXICI = 1 ;               % draw a horizontal black line when ICI is more than this
CH = 0 ;                   % which audio channel to analyse
DSC = 1497/2 ;

% the parameters below are:
%   cax = display colour limits in dB
%   f_env_ls = envelope detector signal bandpass filter cut-off frequencies in Hz
%   f_env_hs = same as f_env_ls but these values are used if the sampling
%      rate is > 100kHz.

switch prefix(1:2),
   case 'zc',      % for ziphius use:
      cax = [-95 -35] ;         
      f_env_ls = [25000 45000] ;
      f_env_hs = [27000 65000] ;

   case 'md',      % for mesoplodon use:
      cax = [-96 -35] ;       
      f_env_ls = [25000 45000] ;
      f_env_hs = [27000 80000] ;

   case 'pw',      % for pilot whale use:
      cax = [-105 -30] ;      
      f_env_ls = [20000 40000] ;
      f_env_hs = [40000 80000] ;

   case 'sw',      % for sperm whale use:
      cax = [-95 -5] ;
      f_env_ls = [5000 35000] ;
      f_env_hs = [5000 35000] ;

   otherwise,      % for sperm whales and others use:
      cax = [-95 -10] ;
      f_env_ls = [2000 35000] ;
      f_env_hs = [2000 35000] ;
end

cue = min(CL(:,1))-0.1 ;
len = max(CL(:,1))-cue ;
CL = CL(:,1) ;

% find sampling rate
[x,fs] = d3wavread(cue+[0 0.01],recdir,prefix) ;

% make analysis filter
if fs<100e3,   
   [b a] = butter(6,f_env_ls/(fs/2)) ;
else
   [b a] = butter(6,f_env_hs/(fs/2)) ;
end

x = d3wavread(cue+[0 len+1+intervl(2)],recdir,prefix) ;
if isempty(x), return; end

k = find(CL>=cue+0.05 & CL<(cue+len+1)) ;
if ~isempty(k),
   cl = round(fs*(CL(k)-cue)) ;
   kgood = find(round(cl+fs*intervl(1))>0 & round(cl+fs*intervl(2))<length(x)) ;
   cl = sort(cl(kgood)) ;
   tcl = cl/fs+cue ;
   ncl = length(cl) ;
   fprintf('%d clicks\n', ncl) ;       
else
   ncl = 0 ;
end

if ncl<3,
   RR = [] ;
   return
end

if CH==0 & size(x,2)>1,
   scf = 1/size(x,2) ;
   for k=2:size(x,2),
      x(:,1) = x(:,1)+x(:,k) ;
   end
   x = scf*x ;
   CH = 1 ;
end

if size(x,2)==1,
   CH = 1 ;
end

xf = filter(b,a,x(:,CH)) ;
displ = round(fs*intervl) ;

% make selection indices - add extra points to make length divisible by df
if abs(df)>1,
   nex = mod(abs(df)-mod(displ(2)-displ(1)+1,abs(df)),abs(df)) ;
else
   nex = 0 ;
end
ki = displ(1):(displ(2)+nex) ;
kki = ki(1):ki(end)+500 ;
dk = ki(1:abs(df):end)'/fs ;
R = zeros(length(dk),ncl) ;

if abs(df)>1,
   for k=1:ncl,
      r = abs(hilbert(xf(cl(k)+kki))) ;
      if df>0,
         R(:,k) = max(reshape(r(1:df*length(dk)),df,length(dk)))' ;
      else
         R(:,k) = sqrt(mean(reshape(r(1:abs(df)*length(dk)).^2,abs(df),length(dk))))' ;
      end
   end
else
   for k=1:ncl,
      R(:,k) = abs(hilbert(xf(cl(k)+ki))) ;
   end
end

figure(1),clf
RR = {} ;
k = [0;find(diff(tcl)>MAXICI);length(tcl)]' ;
dist = dk*DSC ;
for kk=1:length(k)-1,
   ind = k(kk)+1:k(kk+1) ;
   if length(ind)>1,
      RdB = 20*log10(R(:,ind)) ;
      if nargout==1,
         RR{length(RR)+1} = {dist,tcl(ind)-tz,RdB} ;
      end
      imageirreg(tcl(ind)-tz,dist,RdB');
   end
   hold on
end

hold off
grid on
colormap(jet) ;
caxis(cax)
return
