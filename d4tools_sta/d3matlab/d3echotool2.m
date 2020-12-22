function    [DD,CL] = d3echotool2(recdir,prefix,cue,CL,EXTENT,DD)
%
%     DD=d3echotool2(recdir,prefix,cue,CL)
%     or
%     DD=d3echotool2(recdir,prefix,cue,CL,EXTENT)
%     or
%     DD=d3echotool2(recdir,prefix,cue,CL,EXTENT,DD)
%
%     Inputs:
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%     cue is the time in seconds-since-tag-on to start working from.
%        If cue = [start_cue end_cue], the length of that interval will
%        be used as the frame length instead of the default 20s.
%     CL is a vector of click cues in seconds.
%     EXTENT = [left right] are the times in seconds to display with
%        respect to each click. Default is [-0.0005 0.02].
%     DD is the data structure defined below. DD can be passed as an
%        input argument to allow multiple work sessions.
%
%  	Each matrix in the cell array DD contains the following columns:
%  	1  click_cue
%  	2  two_way_travel_time to selected echo, s
%  	3  echo envelope level, dB
%
%	  Valid commands in the figure window are:
%		left-button		select an echo
%     +  extend the two-way travel time extent
%     -  reduce the two-way travel time extent
%     >  move the two-way travel time extent to the right
%     <  move the two-way travel time extent to the left
%     l  increase lower color map limit
%     L  decrease lower color map limit
%     u  increase upper color map limit
%     U  decrease upper color map limit
%     a  accept the current echo sequence
%     e  edit the echo sequence closest to the crosshairs
%     f  move forward to the next block of clicks
%     b  move backward to the previous block of clicks
%		r  remove the current echo sequence
%     R  redraw the current echogram
%     x  remove the current click from the click list
%     y  lineup all clicks in the current plot to 0
%     1  lineup a single click to 0
%     m  move clicks to 0
%     o  force alignment of a single click
%		q  quit

%  markjohnson@st-andrews.ac.uk
%  Sept 2018
%

if nargin<4,
    help d3echotool2
    return
end

maxclicks = 1000 ;         % maximum number of clicks to display
nshow = 0.0015 ;           % length of waveform to display in detail figure
figs = [1 2] ;             % which figure windows to use
MAXICI = 1 ;               % draw a horizontal black line when ICI is more than this
SRCH = 0.0025 ;            % time window over which to search for z command
TH = 0.7 ;
DF = 8 ;
nCL = 50 ;                 % default is to read in 50 clicks at a time
ALIGN = 0.001 ;            % +/- time limits for alignment search 
CH = 1 ;
W = [] ;

% the parameters below are:
%   cax = display colour limits in dB
%   f_env_ls = envelope detector signal bandpass filter cut-off frequencies in Hz
%   f_env_hs = same as f_env_ls but these values are used if the sampling
%      rate is > 100kHz.

switch prefix(1:2),
   case 'zc',      % for ziphius use:
      cax = [-93 -35] ;         
      f_env_ls = [25000 45000] ;
      f_env_hs = [30000 65000] ;

   case 'mb',      % for mesoplodon use:
      cax = [-93 -35] ;       
      f_env_ls = 50000 ;
      f_env_hs = [50000 120000] ;

   case 'md',      % for mesoplodon use:
      cax = [-91 -35] ;       
      f_env_ls = [25000 45000] ;
      f_env_hs = [25000 65000] ;

   case {'pw','gm'}      % for pilot whale use:
      cax = [-95 -30] ;      
      f_env_ls = [20000 40000] ;
      f_env_hs = [30000 65000] ;

   case {'hp','pp'}      % for hartbour porpoise use:
      cax = [-103 -30] ;      
      f_env_ls = 40000 ;
      f_env_hs = [100000 230000] ;

   case 'by',
      cax = [-95 -10] ;
      f_env_ls = 20000 ;
      f_env_hs = [20000 55000] ; 
      
   case {'sw','pm'},      % for sperm whale use:
      cax = [-93 -15] ;
      f_env_vls = [2000 15000] ;
      f_env_ls = [2000 30000] ;
      f_env_hs = [5000 40000] ;

   otherwise,      % for others use:
      cax = [-95 -10] ;
      f_env_ls = [2000 35000] ;
      f_env_hs = [2000 35000] ;
end

% handle variable arguments
if nargin<5 || isempty(EXTENT),
   EXTENT = [-0.0005 0.02] ;
end
if length(EXTENT)==1,
   EXTENT = [-0.0005 EXTENT] ;
end

if nargin<6,
   DD = {} ;       % initialize cell array of echo sequences
end

if isempty(cue),
   cue = CL(1)-0.1 ;
end

if length(cue)==2,
   len = min(len,diff(cue)) ;
   nCL = [] ;
   cue = cue(1) ;
else
	len = [] ;
end

cue = max(CL(1,1),cue) ;
CL = CL(:,1) ;

% find sampling rate
[x fs] = d3wavread(cue+[0 0.1],recdir,prefix,'wav') ;
if isempty(x), return, end
if isempty(len),
	len = 10e6/fs ;
end
overlap = 0.05*len ;  % 5% overlap between frames

% make analysis filter
if fs<50e3,
   if exist(f_env_vls,'var'),
      [b a] = butter(4,f_env_vls/(fs/2)) ;
   else
      [b a] = butter(4,f_env_ls(1)/(fs/2),'high') ;
   end
elseif fs<100e3,
   if length(f_env_ls)==1,
      [b a] = butter(4,f_env_ls/(fs/2),'high') ;
   else
      [b a] = butter(4,f_env_ls/(fs/2)) ;
   end
else
   [b a] = butter(4,f_env_hs/(fs/2)) ;
end

% initialize
fs = fs/DF ;
currentseq = length(DD)+1 ;
seqplot = NaN*ones(length(DD),1) ;
figure(figs(1))
clf
next = 1 ; 
off_frame = [] ;
MODES = {'BOTTOM','TARGET'} ;
MODE = 1 ;
cleanh = [] ;

while next<2,
   while next==1,
      fprintf('reading at %d  ', cue) ;
      CL = CL(~isnan(CL)) ;
      if ~isempty(nCL),
         k = find(CL>=cue,nCL) ;
         len = min(CL(k(end))-CL(k(1))+1,60) 
      end
      x = d3wavread(cue+[0 len+EXTENT(2)+0.01],recdir,prefix,'wav') ;
      if isempty(x), return; end

      kc = find(CL>=cue-EXTENT(1) & CL<(cue+len+EXTENT(2)),maxclicks) ;
      if ~isempty(kc),
         cl = CL(kc) ;
         fprintf('%d clicks\n', length(cl)) ;       
      else
         cl = [] ;
      end
      
      if length(cl)>3,
         x = hilbenv(filter(b,a,x(:,CH)));
         xe = mean(buffer(x.^2,2*DF,DF,'nodelay'));
         R = extract_cues(xe,fs,cl(:,1)-cue+EXTENT(1),diff(EXTENT));
         hold off, zoom off
         tk = (0:size(R,1)-1)/fs+EXTENT(1) ;
         imagesc(tk,1:length(cl),adjust2Axis(10*log10(R)'),cax); grid
         hold on
         colormap(jet) ;
         kk = find(diff(cl)>MAXICI) ;     % plot horizontal bars where ICI is large
         for kkk=kk',
            plot(EXTENT,(kkk+0.5)*[1;1],'k')
         end
         next = 0 ; 
      else
         cue = cue + len ;
         clf, plot(0,0); title('No clicks in block') ;
         drawnow ; 
         fprintf('Goto next block or quit (q=quit)? ')
         [gx gy button] = ginput(1) ;
         fprintf('\n') ;
         if button=='q',
            return ;
         end
      end
   end

   % plot old sequences in this block
   % find points already selected in this block
   for k=1:length(DD),
      ddd = DD{k} ;
      if ~isempty(ddd) & any(ddd(:,1)>=cue & ddd(:,1)<(cue+len+1)),
         kbot = nearest(cl,ddd(:,1),0.001) ;
         kk = find(~isnan(kbot)) ;
         seqplot(k) = plot(ddd(kk,2),kbot(kk),'k.-') ;
      end
   end
   
   dd = NaN*ones(length(cl),2) ;
   hd = plot(dd(:,1),1:size(dd,1),'k*') ;
   title(sprintf('%d to %d, caxis %d to %d dB',cue,cue+len,cax(1),cax(2))) ;

   while next==0,
      accept = 0 ;
      [xr yr button] = ginput(1) ;
      if isempty(button),continue,end
      switch button
      case 'a',               % type 'a' to accept the current sequence
         accept = 1 ;
      case 'l',
         cax(1) = cax(1)-3 ;
         caxis(cax) ;
         title(sprintf('%d to %d, caxis %d to %d dB',cue,cue+len,cax(1),cax(2))) ;
      case 'L',
         cax(1) = cax(1)+3 ;
         caxis(cax) ;
         title(sprintf('%d to %d, caxis %d to %d dB',cue,cue+len,cax(1),cax(2))) ;
      case 'u',
         cax(2) = cax(2)-3 ;
         caxis(cax) ;
         title(sprintf('%d to %d, caxis %d to %d dB',cue,cue+len,cax(1),cax(2))) ;
      case 'U',
         cax(2) = cax(2)+3 ;
         caxis(cax) ;
         title(sprintf('%d to %d, caxis %d to %d dB',cue,cue+len,cax(1),cax(2))) ;         
      case 'q',           % type 'q' to end session
         accept = 1 ;
         next = 2 ;
         if nargout==2,
            W.R = R ;
            W.cl = cl ;
            W.t = tk ;
         end
      case 'b',           % type 'b' to go to previous frame
         accept = 1 ;
         next = 1 ;
         cue = cue-len+overlap ;    % advance time cursor
      case 'f',           % type 'f' to go to next frame
         accept = 1 ;
         next = 1 ;
         cue = cue+len-overlap ;    % advance time cursor
      case 'r',           % type 'r' to clear all currently selected points
         dd = NaN*dd ;
         set(hd,'XData',dd(:,1)) ;
      case '+',
         EXTENT(2) = EXTENT(1)+min(400/750,diff(EXTENT)*2) ;
         accept = 1 ;
         next = 1 ;
      case '-',
         EXTENT(2) = EXTENT(1)+max(2/750,diff(EXTENT)/2) ;
         accept = 1 ;
         next = 1 ;
      case 'x',
         yr = round(max(min(yr,length(kc)),1)) ;
         CL(kc(yr)) = NaN ;
         cl(yr) = NaN ;
         set(plot(EXTENT,yr*[1 1],'w-'),'LineWidth',2)
      case 'R',
         accept = 1 ;
         next = 1 ;
      case '>',
         EXTENT = EXTENT+diff(EXTENT)/3 ;
         accept = 1 ;
         next = 1 ;
      case '<',
         EXTENT = EXTENT-diff(EXTENT)/3 ;
         accept = 1 ;
         next = 1 ;
      case 'y',
         if xr>EXTENT(1) && xr<EXTENT(2),
            kr = round(interp1(EXTENT(:),[1;size(R,1)],xr)) ;
            alim = round(ALIGN*fs) ;
            RR = [zeros(alim,size(R,2));R;zeros(alim,size(R,2))] ;
            CL(kc) = cl-alignclicks(RR(kr:kr+2*alim,:))/fs+xr ;
            accept = 1 ;
            next = 1 ;
         end         
      case '1',
         if yr>0.5 && yr<length(cl)+0.5 && xr>EXTENT(1) && xr<EXTENT(2),
            kcl = round(yr) ;
            kr = round(interp1(EXTENT(:),[1;size(R,1)],xr)) ;
            alim = round(ALIGN*fs) ;
            RR = [zeros(alim,1);R(:,kcl);zeros(alim,1)] ;
            CL(kc(kcl)) = cl(kcl)-alignclicks(RR(kr:kr+2*alim))/fs+xr ;
            accept = 1 ;
            next = 1 ;
         end         
      case 'o',
         if yr>0.5 && yr<length(cl)+0.5 && xr>EXTENT(1) && xr<EXTENT(2),
            kcl = round(yr) ;
            CL(kc(kcl)) = cl(kcl)+xr ;
            set(plot(xr,kcl,'w.'),'MarkerSize',6)
         end         
      case 'm',
         if xr>EXTENT(1) && xr<EXTENT(2),
            CL(kc) = cl+xr ;
            accept = 1 ;
            next = 1 ;
         end         
      case 'e',           % type 'e' to edit a sequence
         % look for nearest sequence to crosshairs
         yr = round(max([1 min([length(dd) yr])])) ;
         arat = abs(diff(EXTENT)/(cl(end)-cl(1))) ;
         ddist = NaN*ones(length(DD),1) ;
         for k=1:length(DD),
            ddd = DD{k} ;
            if ~isempty(ddd) && any(ddd(:,1)>=cue && ddd(:,1)<(cue+len+1)),
               ddist(k) = min(arat*abs(ddd(:,1)-cl(yr))+abs(ddd(:,2)-xr)) ;
            end
         end
         [m currentseq] = min(ddist) ;
         ddd = DD{currentseq} ;
         kbot = nearest(cl,ddd(:,1),1e-3) ;
         kk = find(~isnan(kbot)) ;
         dd(kbot(kk),:) = ddd(kk,2:end) ;
         set(seqplot(currentseq),'XData',NaN*kk) ;
         set(hd,'XData',dd(:,1)) ;
         kk = find(ddd(:,1)<cl(1)-1e-3 | ddd(:,1)>cl(end)+1e-3) ;
         off_frame = ddd(kk,:) ;

      case 1 
         if yr>0.5 && yr<length(cl)+0.5 && xr>EXTENT(1) && xr<EXTENT(2),
            kcl = round(yr) ;
            figure(figs(2)), clf
            dd(kcl,:) = showpiece(R(:,kcl),tk,xr,nshow*fs,fs) ;
            figure(figs(1))
            set(hd,'XData',dd(:,1)) ;
            newseq = 0 ;
         end
      end
      
      if accept,           % finish sequence and store in DD
         kcl = find(~isnan(dd(:,1))) ;
         if ~isempty(kcl),
            seqplot(currentseq) = plot(dd(kcl,1),kcl,'k.-') ;
            V = [off_frame;cl(kcl) dd(kcl,:)] ;
            [mm I] = sort(V(:,1)) ;
            DD{currentseq} = V(I,:) ;
            off_frame = [] ;
         end
         save echotool_Recover DD
         dd = NaN*dd ;
         currentseq = length(DD)+1 ;
         set(hd,'XData',dd(:,1)) ;
         newseq = 0 ;
      end
   end
end


function   X = showpiece(r,tk,xr,nshow,fs)
%
%
kns = round(nshow) ;
kkx = find(tk>xr,1)+(-kns:kns) ;
kkx = kkx(find(kkx>0 & kkx<length(tk))) ;
tk = tk(kkx) ;
r = 10*log10(r(kkx)) ;
plot(tk,r),grid
hold on

% plot default peak selection
[xpk m] = max(r) ;
hb = plot([1;1]*tk(m),get(gca,'YLim')'*[1 1],'k-') ;
[xr yr button] = ginput(1) ;

if button=='x'         
   X = NaN*[1 1] ;
   return
end

if button=='s' & xr>=tk(1) & xr<=tk(end)
   m = round(interp1(tk,(1:length(tk))',xr)) ;
   set(hb(1),'XData',[1;1]*tk(m)) ;
   xpk = r(m) ;
   pause(0.5)
end
   
X = [tk(m) xpk] ;
return


function    cl = alignclicks(R)
%
%
cl = zeros(size(R,2),1) ;
for k=1:size(R,2),
   RR = R(:,k) ;
   thr = 0.3*max(RR) ;
   [m,p] = findpeaks(RR,'MINPEAKHEIGHT',thr) ;
   if ~isempty(p),
      cl(k) = round(size(R,1)/2-p(1)) ;
      if cl(k)>0,
         R(:,k) = [zeros(cl(k),1);RR(1:end-cl(k))] ;
      else
         R(:,k) = [RR(-cl(k)+1:end);zeros(-cl(k),1)] ;
      end
   end
end
return
