function    [scl,RR] = d3timeindexedechoes(recdir,prefix,cue,CL,intervl,df,tz,noedit)
%
%     [scl,RR] = d3timeindexedechoes(recdir,prefix,cue,CL,intervl,df,tz,noedit)
%     Display echogram with a time axis rather than a click axis.
%     tag is the tag deployment string e.g., 'sw03_207a'
%     CL is a vector of click cues
%     intervl = [left right] are the times in seconds to display with
%        respect to each click. Default is [-0.001 0.025].
%     df is the decimation factor (integer>=1) to use in the range-axis
%     tz is an optional zero-cue (i.e., the reference time for the y-axis)
%     noedit is an optional flag to bypass point selection if noedit=1.
%
%     To select points, draw boxes around point with the left mouse button.
%     Toggle 'add' and 'remove' modes using the x key.
%     Type any other key to end
%     Returns: the cue and the TWTT of selected points.
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  December 2006
%

if nargin<5,
    help d3timeindexedechoes
    return
end

if nargin<6 | isempty(df),
   df = 1 ;
end

if nargin<7 | isempty(tz),
   tz = 0 ;
end

if nargin<8 | isempty(noedit),
   noedit = 0 ;
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

   case {'pw','gm'},      % for pilot whale use:
      cax = [-105 -30] ;      
      f_env_ls = [20000 40000] ;
      f_env_hs = [40000 80000] ;
   
   case 'gg',      % for Risso's dolphin use:
      cax = [-105 -30] ;      
      f_env_ls = [20000 40000] ;
      f_env_hs = [40000 80000] ;

   case {'sw','pm'}      % for sperm whale use:
      cax = [-95 -5] ;
      f_env_ls = [5000 40000] ;
      f_env_hs = [5000 40000] ;
      
   case 'tt',      % for bottlenose dolphin use:
      cax = [-105 -30] ;      
      f_env_ls = [20000 40000] ;
      f_env_hs = [50000 90000] ;

    case {'hp','pp'}, %for harbour porpoise use:
      cax = [-95 -35] ;         
      f_env_ls = [20000 40000] ;
      f_env_hs = [120000 160000] ;
      
   otherwise,      % for sperm whales and others use:
      cax = [-95 -10] ;
      f_env_ls = [2000 35000] ;
      f_env_hs = [2000 35000] ;
end

if isempty(cue),
   cue = min(CL(:,1))-0.1 ;
   len = max(CL(:,1))-cue ;
elseif length(cue)==2,
   len = diff(cue) ;
   cue = cue(1) ;
else
   len = 20 ;        % default length of segment to analyze in seconds
end

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
   scl = [] ; RR = [] ;
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

if noedit~=1,
   figure(1),clf
end
if nargout==2,
   RR = {} ;
   noedit = 1 ;
end
k = [0;find(diff(tcl)>MAXICI);length(tcl)]' ;
dist = dk*DSC ;
for kk=1:length(k)-1,
   ind = k(kk)+1:k(kk+1) ;
   if length(ind)>1,
      RdB = 20*log10(R(:,ind)) ;
      if nargout==2,
         RR{length(RR)+1} = {dist,tcl(ind)-tz,RdB} ;
      else
         imageirreg(dist,tcl(ind)-tz,RdB,1);
      end
   end
   hold on
end

if nargout<2,
   hold off
   grid on
   colormap(jet) ;
   caxis(cax)
end

if noedit~=1,
   scl = pickpoints(dk*DSC,tcl(ind)-tz,R) ;
   if ~isempty(scl),
      scl(:,2) = scl(:,2)/DSC ;
   end
else
   scl = [] ;
end
return


function    s = pickpoints(x,y,R)
%
%
done = 0 ;
s = [] ;
hold on
h = plot(-10,0,'k.') ;        % dummy plot to make a handle
set(h,'MarkerSize',5) ;
MODE = 1 ;
MODES = {'Mode = Add','Mode = Remove'} ;
title(MODES{MODE}) ;
while ~done,
   if(~waitforbuttonpress),
      pt1 = get(gca,'CurrentPoint') ;        % button down detected
      finalRect = rbbox ;                    % return figure units
      pt2 = get(gca,'CurrentPoint') ;        % button up detected
      q = sort([pt1(1,1:2);pt2(1,1:2)]) ;    % extract x and y
      if MODE==1,
         xind = find(x>q(1,1) & x<q(2,1)) ;
         yind = find(y>q(1,2) & y<q(2,2)) ;
         if length(yind)>0 & length(xind)>0,
            [mm,nn] = max(R(xind,yind)) ;
            s = [s;y(yind),x(xind(nn))] ;
         end
      else
         k = find(~(s(:,1)>q(1,2) & s(:,1)<q(2,2) & s(:,2)>q(1,1) & s(:,2)<q(2,1))) ;
         s = s(k,:) ;
      end  
      [ss,I] = unique(s(:,1)) ;
      s = s(I,:) ;
      set(h,'XData',s(:,2),'YData',s(:,1)) ;
   else
      butt = get(gcf,'CurrentCharacter') ;
      switch butt,
         case 'x', MODE = rem(MODE,2)+1 ;
                   title(MODES{MODE}) ;
         otherwise,
               done = 1 ;
      end
   end
end

return
