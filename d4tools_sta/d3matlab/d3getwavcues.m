function    [BLKS,fs,fn,recdir,id,recn] = d3getwavcues(recdir,prefix,suffix)
%    [BLKS,fs,fn,recdir,id,recn] = d3getwavcues(recdir,prefix,suffix)
%     Forms a cue table from a sequence of D3 WAV-format files with
%     names like recdir/prefixnnn.suffix, where nnn is a 3 digit number.
%     Suffix can be 'wav' (the default) or 'swv' or any other suffix
%     assigned to a wav-format configuration.
%     Called by makecuefile.
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%     suffix is an optional file suffix such as 'swv'. The default
%        is 'wav'.
%     Returns:
%     The columns of BLKS are:
%        File number
%        Start time of block (UNIX seconds)
%        Microsecond offset to first sample in block
%        Number of samples in the block
%        Status of block (1=zero-filled, 0=data bearing, -1=data gap)
%     fs is the sampling rate of the requested sensor. For sensors with
%      inherent duty-cycle such as sonars, fs will have four elements:
%        fs(1) is the effective data rate in samples/sec
%        fs(2) is the raw data rate
%        fs(3) is the number of samples per frame
%        fs(4) is the duration of each frame in seconds
%     fn is a cell structure of file names
%     recdir is the directory name for the recordings
%     id is the identification number for the recording device
%
%     Updated 11/2/16 to improve timing error detection
%     Updated 15/2/17 for dtag4
%     Updated 20/12/18 for dutycycled sensors
%
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

BLKS= [] ; fs = [] ; fn = [] ; id = [] ; fill = [] ;
TERR_THR = 0.005 ;       % report timing errors larger than this many seconds
SERR_THR = 10 ;          % as long as they are also at least this many samples

if nargin<3 || isempty(suffix) || ~ischar(suffix),
   suffix = 'wav' ;
end

% get file names
[fn,did,recn,recdir] = getrecfnames(recdir,prefix) ;
if isempty(fn), 
   recdir = [] ; 
   return
end

% read in xml data for each output file and assemble a cue table
fprintf(' Found %d files. Checking file    ',length(fn)) ;
for k=1:length(fn),
   fprintf('\b\b\b%03d',k) ;
   d3 = readd3xml([recdir fn{k} '.xml']) ;
   if isempty(d3),
      fprintf(' Unable to find or read file %s.xml\n', fn{k});
      return
   end
   
   % find the sampling rate if we don't already know it
   if isempty(fs),
      [fs,fsne,fill] = getfs(d3,suffix) ;
      id = getxmldevid(d3) ;
      if ~isempty(fill),
         fs = [fill(1)/fill(2),fs,fill] ;
         TERR_THR = fill(2) ;
      end
   end

   if isempty(fs),
      fprintf('\n Unable to determine the sampling rate. Check file name and suffix\n') ;
      return
   end

   % find WAVBLK entries with the correct suffix
   blks = getwavblks(d3,suffix) ;   % check if WAVBLK entries are in the xml file
   if isempty(blks),
      blks = getwavtblks([recdir fn{k}],suffix) ;
   end

   % if a corresponding WAV file exists, check the sample count and rate
   fname = [recdir fn{k} '.' suffix] ;
   if ~exist(fname,'file'),
      fprintf(' No %s file found for recording %s, skipping\n',suffix,fn{k}) ;
   else
      s = audioinfo(fname) ;
      if(fsne~=s.SampleRate)
         fprintf(' Warning: Sampling rate mismatch in recording %s\n',fn{k}) ;
      end
      if ~isempty(blks),
         if s.TotalSamples~=sum(blks(:,3)),
            fprintf(' Warning: Sample count mismatch in recording %s\n',fn{k}) ;
         end
      else
         % d3 xml files made with an old d3read don't have WAVBLK fields
         fprintf('\n Warning: no WAVBLK fields - check version of d3read and re-run\n') ;
         t = getcuetime(d3,suffix) ;
         blks = [t s(1) 0] ;
      end
   end
   BLKS = [BLKS;repmat(k,size(blks,1),1) blks] ;
end
fprintf('\n') ;

if isempty(fs),
   fprintf(' Warning: Unable to determine sampling rate for this configuration\n');
   return ;
end

if(size(BLKS,1)<=1),
   return
end

% check the timing
frst = 1 ;
overrun = 0 ;
while 1,
   tpred = cumsum(BLKS(1:end-1,4))/fs(1) ;
   tnxt = (BLKS(2:end,2)-BLKS(1,2))+(BLKS(2:end,3)-BLKS(1,3))*1e-6 ;
   terr = tnxt - tpred ;
   serr = round(terr*fs(1)) ;       % time errors in samples
   k = find((terr>TERR_THR) & (serr>SERR_THR),1) ;
   if isempty(k),
      BLKS(2:end,3) = BLKS(2:end,3) - terr*1e6 ;
      break ;
   end
   BLKS(2:k,3) = BLKS(2:k,3) - terr(1:k-1)*1e6 ;
   if frst && isempty(fill),
      fprintf(' Warning: Gaps found between data blocks\n') ;
      fprintf('          Gaps are allowed and are managed by the tag tools but if gaps are\n') ;
      fprintf('          unexpected check version of d3read or d4read.\n') ;
      frst = 0 ;
   end
   if k<size(BLKS,1) && (BLKS(k,1)==BLKS(k+1,1)),
      fprintf(' => gap in file %s of %3.3f seconds (%d samples)\n',...
               fn{BLKS(k,1)},terr(k),serr(k)) ;
   else
      fprintf(' => gap between files %s and %s of %3.3f seconds (%d samples)\n',...
               fn{BLKS(k,1)},fn{BLKS(k+1,1)},terr(k),serr(k)) ;
   end
   st = tpred(k)+BLKS(1,2)+BLKS(1,3)*1e-6 ;
   ablks = [BLKS(k,1) floor(st) rem(st,1)*1e6 serr(k) -1] ;
   BLKS = [BLKS(1:k,:);ablks;BLKS(k+1:end,:)] ;   % add the gap lines to the block table
end

k = find((terr<-TERR_THR) & (serr<-SERR_THR)) ;
if ~isempty(k),
   fprintf(' %d data overruns detected with maximum size %3.3f seconds (%d samples)\n',...
               length(k),-min(terr),-min(serr)) ;
end

return


function    [fs,fsne,fill] = getfs(d3,suffix)
%
%
fs = [] ; fsne = [] ; fill = [] ;
if ~isfield(d3,'CFG'),
   return
end

for k=1:length(d3.CFG),
   c = d3.CFG{k}(1) ;
   if ~isfield(c,'FTYPE'), continue, end
   if ~strcmp(c.FTYPE,'wav'), continue, end
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strncmp(c.SUFFIX,suffix,length(suffix)), continue, end
   if ~isfield(c,'FS'), continue, end
   if isfield(c,'EXP'),
      c.EXP(c.EXP=='_') = '-' ;     % reverse the fix in readd3xml to overcome Matlab
                                    % field name restrictions
      expn = str2double(c.EXP) ;
   else
      expn = 0 ;
   end
   fsne = str2double(c.FS) ;
   fs = fsne * 10^expn ;
   if isfield(c,'INTERVAL'),
      fill = getframelen(d3.CFG,str2double(c.SRC.ID)) ;
      fill(2) = str2double(c.INTERVAL.INTERVAL) ;
      if strcmp(c.INTERVAL.UNIT,'ms'),
         fill(2) = fill(2)/1000 ;
      end
   end
   break ;
end
return


function    len = getframelen(cfg,id)
%
%
len = 0 ;
while 1,
   for k=1:length(cfg),
      c = cfg{k}(1) ;
      if str2double(c.ID) ~= id, continue, end
      if isfield(c,'NSAMPS'),
         len = str2double(c.NSAMPS) ;
         break
      end
      if ~isfield(c,'SRC'),
         len = -1 ;
         break
      end
      id = str2double(c.SRC.ID) ;
      break
   end
   if len~=0, break, end
end
return


function    blks = getwavblks(d3,suffix)
%
%
blks = [] ;
if ~isfield(d3,'WAVBLK'),
   return
end

for k=1:length(d3.WAVBLK),
   c = d3.WAVBLK{k} ;
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strcmp(c.SUFFIX,suffix), continue, end
   if ~isfield(c,'RTIME') | ~isfield(c,'MTICKS') | ~isfield(c,'NSAMPS'), continue, end
   blks(end+1,:) = [str2double({c.RTIME;c.MTICKS;c.NSAMPS})',0] ;
end
return


function    t = getcuetime(d3,suffix)
%
%
t = [] ;
if ~isfield(d3,'CUE'),
   return
end

if isstruct(d3.CUE)
   d3.CUE = {d3.CUE} ;
end

for k=1:length(d3.CUE),
   c = d3.CUE{k} ;
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strcmp(c.SUFFIX,suffix), continue, end
   if ~isfield(c,'TIME') | ~isfield(c,'CUE'), continue, end
   t(1) = d3datenum(sscanf(c.TIME,'%d,',6)') ;
   t(2) = str2double(c.CUE)*1e6 ;
   return
end

return


function blks = getwavtblks(fn,suffix)
%
%
blks = [] ;
fname = [fn,'.wavt'] ;  % first check if there are '.wavt' files in the new format
if exist(fname,'file'),
   c = csvproc(fname,[],[],1) ;
   ks = strmatch(suffix,{c{:,1}}) ;
   for kk=1:length(ks),
      blks(end+1,:) = str2double({c{ks(kk),2:end}}) ;
   end
end

% if not, check for the old format
if isempty(blks),
   fname = [fn,'.',suffix,'t'] ;
   if exist(fname,'file'),
      blks(end+(1:size(s,1)),:) = str2double(csvproc(fname,[],[],1)) ;
   end
end
return
