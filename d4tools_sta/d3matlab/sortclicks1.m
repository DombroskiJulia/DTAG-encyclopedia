function    [cl,x,fs] = sortclicks1(x,varargin)
%
%     [cl,x,fs] = sortclicks(fname)
%        Read in audio data from wav file and generate a click list 
%			and then allow interactive sorting
%     cl = sortclicks(fname,cl)
%        Sort an existing click list
%     cl = sortclicks(x,fs)
%        Work directly with audio data
%     cl = sortclicks(x,fs,cl)
%        Work directly with audio data
%
%	  Valid commands in the figure window are:
%		z  zoom in at the cursor
%     x  zoom out at the cursor
%     a  zoom completely out
%		d	delete the nearest click
%     t  add clicks in the current segment by placing a threshold in the
%        lower plot (requires a second click in the lower plot)
%     s  select the click at the cursor
%		left-button-drag-box		delete all clicks in the drawn box
%     right button click   add clicks between existing clicks
%     +  increase relative threshold by 0.1
%     -  decrease relative threshold by 0.1
%     ^  double echogram range limit
%     v  halve echogram range limit
%     u  undo last click delete
%     F  move forward keeping same zoom level
%     B  move backward at same zoom level
%     f  go to next ICI step change
%     b  go to previous ICI step change
%		q  quit
%

OPTS.sw.fh = [5e3 40e3] ;
OPTS.sw.blank = 5e-3 ;
OPTS.md.fh = [5e3 20e3] ;
OPTS.pw.fh = [10e3 65e3] ;
OPTS.pp.fh = [100e3 230e3] ;  % for harbour porpoise
OPTS.pp.blank = 1e-3 ;
OPTS.hp.fh = [100e3 230e3] ;  % for harbour porpoise
OPTS.hp.blank = 0.3e-3 ;
OPTS.mb.fh = [60e3 120e3] ;  % for Sowerby's
OPTS.mb.blank = 2e-3 ;
OPTS.def.fh = [20e3 70e3] ;
OPTS.def.blank = 3e-3 ;
OPTS.def.df = 8 ;

RTHR = 0.5 ;            	% initial relative threshold for click detection
PICI_THR = [0.1 0.25] ;
PICI_SWITCH = 0.02 ;
ECHOGRAM_EXTENT = 0.01 ;
FIGN = 2 ;						% which figure number to use
CAX_MIN = -94 ;

INOPTS = struct ;
cl = [] ;

if ischar(x),
	INOPTS = x(1:2) ;
   [x,fs]=audioread(x);
	nxt = 1 ;
else
	if nargin<2,
		help sortclicks
		return
	end
	fs = varargin{1} ;
	nxt = 2 ;
end

if nargin>=nxt,
	cl = varargin{nxt} ;
end

if nargin>=nxt+1,
	INOPTS = varargin{nxt+1} ;
end

if ischar(INOPTS),
	OPTS = resolveopts(INOPTS,OPTS) ;
else
	if ~isstruct(INOPTS) & ~isempty(INOPTS),
		INOPTS = setfield([],'fh',INOPTS) ;
	end
	OPTS = resolveopts(OPTS,INOPTS) ;
end

[x,fs]=preproc(x,fs,OPTS) ;

if isempty(cl),
   cl = getclicks(x,fs,OPTS) ;
end

if size(cl,2)<2,
   [X,cl] = extract_cues(x,fs,cl-0.0005,OPTS.blank) ;
   cl(:,2) = max(X)' ;
end

if size(cl,2)<3,
   cl(:,3) = 0 ;
end

opts.blanking = OPTS.blank ;
opts.fh=[] ; 
opts.env = 1 ;
L = 20*log10(cl(:,2)) ;
CAX = max(L)+[-60 0] ;
done = 0 ;

figure(FIGN),clf
h2 = subplot(313); grid on, hold off
plot((1:length(x))'/fs,x,'k');
hold on
d2 = plot(cl(:,1),cl(:,2),'r.') ;
h1 = subplot(312) ;
xlim = [0 length(x)/fs] ;
picik = 0 ;
h0 = subplot(311) ;

while(done<2),
   xlim = [max(0,xlim(1)) min((length(x)-1)/fs,xlim(2))] ;
   k = find(cl(:,3)==0) ;
   ici = diff(cl(k,1));
   ici(end+1) = ici(end) ;
   rici = abs(diff(ici))./ici(1:end-1) ;
   rthr = PICI_THR(1+(ici(1:end-1)>PICI_SWITCH))' ;
   pici_list = k(find(rici>rthr)) ;
   L = 20*log10(cl(k,2)) ;
   
   subplot(311),hold off
   [X,cc]=extractcues(x,cl(k,1)*fs,round(fs*[-0.0005 ECHOGRAM_EXTENT]));
   imageirreg(cc/fs,(1:size(X(:,2)))'*750/fs-0.0005*750,20*log10(X)',1),axis xy
   caxim = caxis ;
   caxim(1) = max(caxim(1),CAX_MIN) ;
   caxis(caxim) ;
   
   subplot(312),hold off
   scatter(cl(k,1),ici,18,L,'filled'),grid
   caxis(CAX) ;
   hold on
   plot(cl(k,1),ici,'ko')
   title(sprintf('Relative threshold %1.1f\n',RTHR)) ;
   
   set(d2,'XData',cl(k,1),'YData',cl(k,2)) ;
   set(h0,'XLim',xlim) ;
   set(h1,'XLim',xlim) ;
   set(h2,'XLim',xlim) ;
   kc = find(cl(k,1)>xlim(1) & cl(k,1)<=xlim(2)) ;
   if ~isempty(kc),
      set(h1,'YLim',[0 max(ici(kc))*1.05]) ;
   end
   kx = round(xlim(1)*fs)+1:round(xlim(2)*fs) ;
   set(h2,'YLim',[0 max(x(kx))*1.05]) ;
   done = 0 ;
   while ~done,
      [gx gy button]=ginput(1) ;
      switch button,
         case '+',
            RTHR = min(RTHR+0.1,1) ;
            done = 1 ;
         case '-',
            RTHR = max(RTHR-0.1,0.1) ;
            done = 1 ;
         case 'z',
            xlim = diff(xlim)/5*[-1 1]+gx ;
            done = 1 ;
         case 'F',
            xlim = xlim + diff(xlim)*0.95 ;
            if xlim(2)>length(x)/fs,
               xlim = length(x)/fs+[-diff(xlim) 0] ;
            end
            done = 1 ;
         case 'B',
            xlim = xlim - diff(xlim)*0.95 ;
            if xlim(1)<0,
               xlim = [0 diff(xlim)] ;
            end
            done = 1 ;
         case 'f',
            picik = min(picik+1,length(pici_list)) ;
            kcl = max(min(pici_list(picik),length(cl)-5),6) ;
            xlim = cl(kcl+5*[-1 1]) ;
            done = 1 ;
         case 'b',
            picik = max(picik-1,1) ;
            kcl = max(min(pici_list(picik),length(cl)-5),6) ;
            xlim = cl(kcl+5*[-1 1]) ;
            done = 1 ;
         case 'x',
            xlim = diff(xlim)*2.5*[-1 1]+gx ;
            done = 1 ;
         case 'a',
            xlim = [0 length(x)/fs] ;    
            done = 1 ;
         case '^',
            ECHOGRAM_EXTENT = min(200/750,ECHOGRAM_EXTENT*2) ;
            done = 1 ;
         case 'v',
            ECHOGRAM_EXTENT = max(2/750,ECHOGRAM_EXTENT/2) ;
            done = 1 ;
         case 's',
            ksx = round(gx*fs)+(-5:5) ;
            [lev kp] = max(x(ksx)) ;
            cl(end+1,1:2) = [ksx(kp)/fs lev] ;
            [cc I] = sort(cl(:,1)) ;
            cl = cl(I,:) ;
            done = 1 ;
         case 't',
            subplot(212)
            [gx gy button]=ginput(1) ;
            subplot(211)
            if button==1,
               cl(kc,3) = max(cl(:,3))+1 ;
               % find all clicks in segment that are above gy
               opts.protocol = 'first';
               cc = getclickx(x(kx),gy,fs,opts) ;
               opts.protocol = 'max';
               [cm,lev] = getclickx(x(kx),gy,fs,opts) ;
               cl(end+(1:length(cc)),1:2) = [cc+kx(1)/fs lev] ;
               [cc I] = sort(cl(:,1)) ;
               cl = cl(I,:) ;
               done = 1 ;
            end
         case 'd'
            ax = axis ;
            SC = diff(ax(3:4))/diff(ax(1:2)) ;
            [mm ks] = min(abs(cl(k,1)*SC+j*ici-(gx*SC+j*gy))) ;
            cl(k(ks),3) = max(cl(:,3))+1 ;
            done = 1 ;
         case 1      % left button
            p1 = get(gca,'CurrentPoint');
            rbbox ;
            p2 = get(gca,'CurrentPoint');
            px = sort([p1(1,1) p2(1,1)]);
            py = sort([p1(1,2) p2(1,2)]);
            cc = cl(k,1) ;
            ks = find(cc>px(1) & ici>py(1) & cc<px(2) & ici<py(2)) ;
            if ~isempty(ks),
               cl(k(ks),3) = max(cl(:,3))+1 ;
               done = 1 ;     
            end
         case 3      % right button
            kl = find(cl(:,1)<gx & cl(:,3)==0,1,'last') ;
            ku = find(cl(:,1)>gx & cl(:,3)==0,1) ;
            thr = RTHR*mean(cl([kl ku],2)) ;
            kxx = max(1,round(fs*(cl(kl,1)+OPTS.blank))):min(round(fs*cl(ku,1)),length(x)) ;
            xx = x(kxx) ;        
            % find all clicks in segment that are above gy
            opts.protocol = 'first';
            cc = getclickx(xx,thr*0.99,fs,opts) ;
            opts.protocol = 'max';
            [cm,lev] = getclickx(xx,thr,fs,opts) ;
            if length(lev)>length(cc),
               lev = lev(1:length(cc)) ;
            elseif length(lev)<length(cc),
               cc = cc(1:length(lev)) ;
            end
            try
            cl(end+(1:length(cc)),1:2) = [cc+kxx(1)/fs lev] ;
            catch
               keyboard 
            end
            [cc I] = sort(cl(:,1)) ;
            cl = cl(I,:) ;
            done = 1 ;     
         case 'u'
            l = max(1,max(cl(:,3))) ;
            cl(cl(:,3)>=l,3) = 0 ;
            done = 1 ;
         case 'q',
            done = 2 ;
      end      % switch
   end         % while ~done
   save _temp.mat cl
end            % while done<2

cl = cl(cl(:,3)==0,1:2) ;
return


function    [x,fs]=preproc(x,fs,opts)

[b,a]=butter(4,opts.fh/(fs/2));      % was 6
x=hilbenv(filter(b,a,x(:,1)));
%x=buffer(x,df,0,'nodelay');
%x=max(x)';
x=buffer(x,opts.df,0,'nodelay');
x=sqrt(mean(x.^2))' ;
fs = fs/opts.df ;

