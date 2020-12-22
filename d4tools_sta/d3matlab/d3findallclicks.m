function    CL = d3findallclicks(recdir,prefix,cue,INOPTS,CL)
%
%     CL = d3findallclicks(recdir,prefix,cue,OPTS,CL)
%		IN DEVELOPMENT - NOT YET GENERALLY USEFUL
%		General purpose automatic click finder. Follow with
%     d3findmissedclicks to ensure that most clicks are identified.
%
%		Inputs:
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%     cue is the time in seconds-since-tag-on to start and end working.
%        cue = [start_cue end_cue].
%		OPTS is an optional 2-vector of high-pass and low-pass frequencies
%        defining a filter to apply to the audio before click detection. 
%        If no OPTS are given, the species prefix in tag is used
%        to select sensible values. If OPTS is a structure, it is passed
%        to the click finder routine. Valid fields
%        are OPTS.fh, OPTS.blank, OPTS.thrave, OPTS.DT, OPTS.df and OPTS.minthr.
%     CL optional input to allow the click list to be assembled in multiple
%			sessions.
%
%		Returns:
%     CL is a vector of click cues in seconds.
%
%  	markjohnson*st-andrews.ac.uk
%  	24 Sept. 2018

if nargin<5,
   CL = [] ;
end

if nargin<2,
   help d3findallclicks
   return
end

if nargin<3 || isempty(cue),
   cue = 0 ;
end

OPTS.sw.fh = [5e3 40e3] ;
OPTS.sw.blank = 5e-3 ;
OPTS.sw.minthr = 0.03 ;

OPTS.md.fh = [5e3 20e3] ;

OPTS.pw.fh = [10e3 65e3] ;

OPTS.pp.fh = [100e3 230e3] ;  % for harbour porpoise
OPTS.pp.blank = 1e-3 ;
OPTS.pp.thrave = 0.2 ;
OPTS.hp.fh = [100e3 230e3] ;  % for harbour porpoise
OPTS.hp.blank = 1e-3 ;
OPTS.hp.thrave = 0.3 ;

OPTS.mb.fh = [50e3 90e3] ;  % for Sowerby's
OPTS.mb.blank = 2e-3 ;
OPTS.mb.thrave = 0.3 ;

OPTS.def.fh = [20e3 70e3] ;
OPTS.def.blank = 3e-3 ;
OPTS.def.thrave = 1 ;
OPTS.def.minthr = 0.005 ;
OPTS.def.DT = 0.2 ;
OPTS.def.df = 8 ;

if nargin<4,
   INOPTS = struct([]) ;
elseif ~isstruct(INOPTS) & ~isempty(INOPTS),
	INOPTS = setfield([],'fh',INOPTS(1:2)) ;
end

OPTS = resolveopts(prefix,OPTS,INOPTS) 
scue = cue(1) ;
if length(cue)>1,
	ecue = cue(2) ;
else
	ecue = [] ;
end
	
[x,fs] = d3wavread(scue+[0 0.1],recdir,prefix) ;
if isempty(x),
   fprintf('Unable to find wav files for this deployment\n') ;
   return
end

LEN = round(10e6/fs) ;

if isfield(OPTS,'mf'),
	b = OPTS.mf ;
	a = 1 ;
	[m,del] = max(xcorr(b)) ;
	del = del/fs ;
else
	if length(OPTS.fh)==1 || OPTS.fh(2)>=fs/2,
		[b,a]=butter(4,OPTS.fh(1)/(fs/2),'high');      % was 6
	else
		[b,a]=butter(4,OPTS.fh/(fs/2));      % was 6
	end
	del = 0 ;
end

fsd = fs/OPTS.df ;

while 1,
	if ~isempty(ecue) && scue>=ecue, break, end
   fprintf(' Processing cue %5.1f...\n',scue) ;

   % read in current block of audio
   x = d3wavread(scue+[0 LEN+OPTS.blank],recdir,prefix) ;
   if isempty(x), break, end
   x = filter(b,a,x(:,1)) ;
	[x,z] = buffer(x,OPTS.df,0,'nodelay');
	if del~=0,
		x = max(x)' ;
	else
		%x = hilbenv(x);
		x = sqrt(mean(x.^2))' ;
	end

   % find all clicks in current block
   cl = getclicks(x,fsd,OPTS) ;

   % identify saved clicks and append any clicks that don't appear in CL
   if ~isempty(cl),
      cl = scue-del+cl(:,1) ;
      plot(cl(1:end-1),log10(diff(cl)),'.'),grid,drawnow
      if ~isempty(CL),
         kk = find(cl>=CL(end)+OPTS.blank) ;
         CL = [CL;cl(kk)] ;     % and add them to CL
      else
         CL = cl ;
      end
   end
   
   scue = scue+LEN ; 
   save('_d3findallclicks_recover.mat','CL','scue');
end
