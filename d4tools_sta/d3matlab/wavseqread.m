function    [x,fs] = wavseqread(cues,recdir,prefix,suffix)
%
%     [x,fs] = wavseqread(cues,recdir,prefix,[suffix])
%     Read a segment from a sequence of wav files. The wav files must
%     all have filenames with the same prefix followed by increasing
%     (but not necessarily sequential) numbers. 
%     cues = [start_cue end_cue], cues are in seconds with respect
%        to the start first sample in the first file in the sequence.
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%     suffix is an optional file name suffix (without the .). If no suffix
%        is given, wav is assumed.
%
%     Assumptions:
%     This code assumes that the wav files are contiguous, i.e., there is
%     no gap between successive files. If the recordings come from
%     Soundtraps, make sure the 'zero fill dropouts' option is selected 
%     in the tools menu of Soundtrap Host.
%
%     Examples:
%        wavseqread([2000 2010],'f:/hp14/hp14_226b','');
%
%     modified 12 April 2017
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013


x = [] ; fs = [] ;
if nargin<3,
   help wavseqread
   return
end

if nargin<4 || isempty(suffix) || ~ischar(suffix),
   suffix = 'wav' ;
end

% check format of directory name for MAC compatibility
if ~isempty(recdir) && ~ismember(recdir(end),'/\'),
   recdir(end+1) = '/' ;
end
recdir(recdir=='\') = '/' ;

% read in cues
C = getwavseqcues(recdir,prefix,suffix) ; % this function is below
if isempty(C),
   fprintf(' Unable to find files\n') ;
   return
end

fs = C.fs ;
ct = C.cuetab ;
fn = C.fn ;

if isempty(ct),
   fprintf(' Unable to make cue file\n') ;
   return
end

k = find(ct(:,1)<=cues(1),1,'last') ;
if isempty(k),
   fprintf(' Cue is before the start of recording\n') ;
   return
end

% compute the number of samples to read
n = round(fs*(cues(2)-cues(1))) ;     
c = cues(1) ;
x = [] ;

while n>0,
   fnum = find(c>=ct(:,1),1,'last') ;    % find which file the current cue comes from
   st = round(fs*(c-ct(fnum,1))) ;   % convert cue to samples wrt start of file

   % find out how many samples can be taken from this file
   len = min(n,ct(fnum,2)-st) ;
   if len<n & fnum==size(ct,1), 
      fprintf(' cue is beyond end of recording - truncating\n') ;
   elseif len==0,
      c = c+1/(2*fs);   % catch rare case of cue coinciding with block end
      continue
   end

   % and read the samples
   xx = audioread([recdir fn{fnum}],st+[1 len]) ;   
   x = [x;xx] ;
   if size(xx,1)<len,
      fprintf(' error reading file %s - insufficient samples\n',fname) ;
      return
   end
   n = n-len ;
   c = c+(len+1)/fs ;
end
return


function    C = getwavseqcues(recdir,prefix,suffix)
%
%  look for a cue file or generate one if there isn't one
%

% try to find a cue file from a previous invocation of wavseqread
cuefname = [recdir '_' prefix suffix 'cues.mat'] ;
if exist(cuefname,'file'),
   C = load(cuefname) ;
   return
end
      
fprintf(' Generating cue file - will take a few seconds\n') ;
ff = dir([recdir,prefix,'*.',suffix]) ;
fn = {ff.name} ;

if isempty(fn),
   fprintf(' No recordings starting with %s found in directory %s\n', prefix, recdir) ;
   C = [] ;
   return
end

fprintf(' %d recordings found\n',length(fn)) ;
fs = -1 ;
t = 0 ;
cuetab = zeros(length(fn),2) ;
for k=1:length(fn),
   fname = [recdir fn{k}] ;
   [s,fss] = audioread(fname,'size') ;
   if fs==-1,
      fs = fss ;
   end
   cuetab(k,:) = [t s(1)] ;
   t = t+s(1)/fs ;
end

vv = version ;
if vv(1)>'6',
   save(cuefname,'-v6','fn','fs','cuetab','recdir') ;
else
   save(cuefname,'fn','fs','cuetab','recdir') ;
end
C = load(cuefname) ;
return

