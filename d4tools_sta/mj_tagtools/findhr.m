function    H = findhr(x,fs,TH,H)
%
%    H = findhr(x,fs,TH,H)
%    Tool to add clicks to a click list based upon gaps in the ICI.
%    C is either a click list from findclicks or the output of a previous
%    call to findmissedclicks. FBP is a bandpass filter frequency
%    specification FBP=[fl,fh]. TH=[ts,fd] or TH=ts, where ts is the
%    shortest gap in the ICI to consider and fd is the minimum fractional 
%    change in ICI to consider as a gap. Default values are TH=[0.4 0.5].
%    If cue is specified, only gaps after cue will be checked.
%
%    Valid on-screen instructions are:
%     a - zoom out to see all the waveform
%     b - go to last gap
%     B - go to previous 10s interval
%     d - open a selection window. In the new window position the cursor
%           on the beat and press the left button to accept. Press any key
%           to reject.
%     f - go to next gap
%     F - go to next 10s interval
%     q - quit
%     r - delete all beats in interval
%     s - select the nearest single beat
%     t - select all beats in the interval with level above the cursor
%     v - add a null beat to indicate a noisy segment
%     x - delete nearest beat
%     z - zoom in
%     Z - zoom out
%     + - increase vertical gain
%     - - decrease vertical gain
%     left-button click - center the signal at the cursor
%     right-button click - center the signal at the cursor and zoom to +/- 5s
%
%    Returns vector H of heartbeat cues. The second column is the peak
%    level. A peak level of -1 indicates a null beat, i.e., an indication
%    that there is noise at that point that prevents beat detection. This
%    can be used to break heart-rate plots.
%
%    markjohnson@st-andrews.ac.uk
%    last modified: June 2014
%

if nargin<2,
   help findhr
   return
end

THDEF = [0.25 0.2] ;    % default thresholds
MAXHR = 15 ;            % maximum hr interval to display in seconds
MAXSHOW = 5 ;           % maximum gap to show
BLNK = 0.25 ;           % blanking time after a detect
SWIN = 0.05 ;           % relative window over which to find beat with 's' command
DWIN = 0.2 ;            % window over which to find beat with 'd' command
RECFILE = 'RECOVER_findhr' ;

if nargin<3 || isempty(TH),
   TH = THDEF ;
end

if nargin<4,
   H = [] ;
end

H = sortH(H) ;
t = (0:length(x)-1)/fs ;
figure(1), clf
subplot(212)
h2 = plot(-100,0,'r.-'); grid
set(h2,'MarkerSize',10)
axis([0 max(t) 0 MAXHR]) ;
ax2 = gca ;
subplot(211), plot(t,x); grid
hold on
h1 = plot(-100,0,'go') ;
set(h1,'LineWidth',1.5)
h1n = plot(-100,0,'ro') ;
set(h1n,'LineWidth',1.5)
ax1 = gca ;
st = min(t) ; ed = max(t) ;
k = 1 ;
FORCE = 0 ;
gaps = [] ;

while 1,
   gaps = findgaps(H,TH) ;
   if FORCE==1 && ~isempty(H) && ~isempty(gaps),
      k = min(k,size(gaps,1));
      margin = min([3*gaps(k,2) MAXSHOW]) ;
      st = H(gaps(k),1)-margin-0.5*gaps(k,2) ;
      ed = H(gaps(k),1)+margin-0.5*gaps(k,2) ;
      FORCE = 0 ;
   end
   
   st = max(st,min(t)) ;
   ed = min(max(ed,st+0.2),max(t)) ;
   set(ax1,'XLim',[st ed])
   set(ax2,'XLim',[st ed])
   if ~isempty(H),
      yl = get(ax1,'YLim') ;
      kp = find(H(:,2)>=0) ;
      kn = find(H(:,2)<0) ;
      set(h1,'XData',H(kp,1),'YData',min(H(kp,2),yl(2))) ;
      set(h1n,'XData',H(kn,1),'YData',yl(1)*ones(length(kn),1)) ;
      ihi = diff(H(:,1)) ;
      h = H(1:end-1,1) ;
      ymax = min([MAXHR,max(ihi(h>st & h<ed))*1.25]) ;
      ihi = min(ihi,ymax) ;
      ihi(kn) = NaN ;
      set(h2,'XData',h,'YData',ihi) ;
      set(ax2,'YLim',[0 ymax]) ;
      save(RECFILE,'H') ;
   end
   ss = sprintf('Gap %d of %d',k,length(gaps)) ;
   title(ss) ;
   pause(0) ;        % to force a draw
   subplot(211)
   [gx gy button] = ginput(1) ;

   if button=='q' || button=='Q',
      return ;

   elseif button=='x' && gx>st && gx<ed,
      kkk = nearest(H(:,1),gx) ;
      H = H([1:kkk-1 kkk+1:end],:) ;

   elseif button=='r',
      kkk = find(H(:,1)<st | H(:,1)>ed) ;
      H = H(kkk,:) ;
         
   elseif button=='+',
      set(ax1,'YLim',0.5*get(gca,'YLim')) ;
         
   elseif button=='-',
      set(ax1,'YLim',2*get(gca,'YLim')) ;

   elseif button=='f',
      k = k+1 ;
      if k>length(gaps),
         return ;
      end
      FORCE = 1 ;
      
   elseif button=='F',
      st = ed-2 ;
      ed = ed+8 ;

   elseif button=='a',
      ed = max(t) ;
      st = 0 ;

   elseif button=='Z',
      edst = ed-st ;
      ed = ed+0.5*edst ;
      st = st-0.5*edst ;

   elseif button=='z',
      edst = ed-st ;
      ed = ed-0.25*edst ;
      st = st+0.25*edst ;

   elseif button=='b',
      k = max([1 k-1]) ;
      FORCE = 1 ;
      
   elseif button=='B',
      ed = st+2 ;
      st = st-8 ;
         
   elseif button=='a',
      ed = max(t) ;
      st = 0 ;

   elseif button=='v',
      if gx<st || gx>ed
         fprintf('Click inside the waveform plot to indicate a null beat\n') ;
      else
         H = sortH([H;[gx,-1]]) ;
      end

   elseif button=='s',
      if gy<0 || gx<st || gx>ed
         fprintf('Click inside the waveform plot to select a threshold\n') ;
      else
         len = (ed-st)*SWIN ;
         kkk = find(t>gx-len & t<gx+len) ;
         % find peak value in the window 
         [h,km] = max(x(kkk)) ;
         H = sortH([H;[t(kkk(km)) h]]) ;
      end

   elseif button=='t',
      if gy<0
         fprintf('Click inside the waveform plot to select a threshold\n') ;
      else
         kkk = find(t>st & t<ed) ;
         h = findpks(x(kkk),fs,gy,BLNK) ;
         h = h(h(:,2)<3*gy,:) ;
         h(:,1) = h(:,1)+t(kkk(1)) ;
         H = sortH([H;h]) ;
      end

   elseif button==1,
      if gx<st || gx>ed,
         fprintf('Click inside the waveform figure to select a new center point\n') ;
      else
         len = ed-st ;
         st = gx-len/2 ;
         ed = gx+len/2 ;
         if ~isempty(gaps),
            k = nearest(gaps(:,1),gx) ;
         end
      end

   elseif button==3,
      if gx<st || gx>ed,
         fprintf('Click inside the waveform figure to select a new center point\n') ;
      else
         if ~isempty(gaps),
            k = nearest(gaps(:,1),gx) ;
            gx = gaps(k,1) ;
         end
         st = gx-2.5 ;
         ed = gx+2.5 ;
      end

   elseif button=='d',
      if gx<st || gx>ed,
         fprintf('Click inside the waveform figure to select a new center point\n') ;
      else
         len = ed-st ;
         st = gx-len/2 ;
         ed = gx+len/2 ;
         kkk = find(t>gx-DWIN & t<gx+DWIN) ;
         figure(2),clf
         plot(t(kkk),x(kkk)),grid
         [gx,gy,button] = ginput(1) ;
         if button==1, 
            H = sortH([H;[gx x(round(fs*gx)+1)]]) ;
         end
         figure(1)
     end
      
   else
      fprintf('Invalid click: see help for commands\n')
   end   % if button
end         % while ~done
return


function h = findpks(x,fs,th,bl)
%
%
opts.protocol='max' ; opts.blanking=bl;
opts.fh=[]; opts.fl=[]; opts.env=1; opts.win=0.5 ;
[h,level] = getclickx(x,th,fs,opts);
h(:,2) = level ;
return


function gaps = findgaps(h,TH)
%
% make gap list
if isempty(h), gaps = [] ; return, end
dcl = diff([0;h(:,1);h(end,1)+1000]) ;
ddcl = abs(diff(dcl)) ;
mdcl = 0.5*(dcl(1:end-1)+dcl(2:end)) ;
mndcl = min([dcl(1:end-1) dcl(2:end)]')' ;
gaps = find(mdcl>TH(1) & ddcl>TH(2)*mndcl)  ;
gaps(:,2) = mndcl(gaps) ;
return

function H = sortH(H)
%
%
if ~isempty(H),
   [h,I] = sort(H(:,1)) ;
   H = H(I,:) ;
end
return
