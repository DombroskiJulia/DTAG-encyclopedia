function    X = d3getswv(cues,recdir,prefix)
%    X = d3getswv(cues,recdir,prefix)
%     Read a segment from a sequence of D3 format SWV (sensor wav) sensor 
%     files, using the accompanying xml files to interpret the sensor channels.
%
%     Inputs:
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%
%     Returns:
%     X.x  is a cell array of sensor vectors. There are as many
%        cells in x as there are unique sensor channels in the
%        recording. Each cell may have a different length vector
%        according to the sampling rate of the sensor channel.
%     X.fs is a vector of sampling rates. Each entry in fs is the
%        sampling rate in Hz of the corresponding cell in x.
%     X.cn is a vector of channel id numbers corresponding to
%        the cells in x. Use d3channames to get the name and
%        description of each channel.
%
%     last modified 1/3/2018
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

X.x = [] ; X.fs = [] ; X.cn = [] ;

% TODO: store following metadata in the cue file to speed up subsequent
% calls 

% get metadata
[ct,nu1,fs,fn,recdir,recn] = d3getcues(recdir,prefix,'swv') ;

% get sensor channel names from the xml file 
d3 = readd3xml([recdir '\' fn{1} '.xml']) ;
if isempty(d3) | ~isfield(d3,'CFG'),
   fprintf('Unable to find or read file %s.xml - check the file name\n', fname);
   return
end

[CFG,fb,dtype] = getsensorcfg(d3) ;
if isempty(CFG),
   fprintf('No sensor configuration in file %s\n',fname) ;
   return
end

% find the channel count and numbers
N = str2num(CFG.CHANS.N) ;
if isempty(N),
   fprintf('Invalid attribute in CHANS field - check xml file\n') ;
   return
end

chans = sscanf(CFG.CHANS.CHANS,'%d,') ;

if length(chans)~=N,
   fprintf('Attribute N does not match value size in CHANS field - check xml file\n') ;
   return
end

chans = chans(:) ;
uchans = unique(chans) ;

% group channels
fs = zeros(length(uchans),1) ;
for k=1:length(uchans),
   kk = find(chans==uchans(k)) ;
   fs(k) = fb*length(kk) ;
end

X.fs = fs ;
X.cn = uchans ;
[nu1,nu2,nu3,ctype] = d3channames(X.cn) ;

% read the swv data and convert to fractional offset binary
xb = d3wavread(cues,recdir,prefix,'swv') ;
if isempty(xb), return, end

if dtype==3,
   k = find(xb<0) ;
   xb(k) = 2+xb(k) ;               % convert from two's complement to offset binary
   xb = xb/2 ;                     % sensor reading range is 0..1 in Matlab
   xb(xb==0) = NaN ;               % replace fill values with NaN
else
   xb(xb==-1) = NaN ;         % replace fill words with NaN
end

% group channels
x = cell(length(uchans),1) ;
for k=1:length(uchans),
   kk = find(chans==uchans(k)) ;
   if ~isempty(kk),
      x{k} = reshape(xb(:,kk)',[],1) ;
   end
end

% remove any single sample outliers on each sensor, skipping MAG and ACC sensors
for k=1:length(x),
   if ismember(ctype{k},{'acc','mag'}), continue, end
   x{k} = deglitch(x{k}) ;
end

X.x = x ;
if isfield(CFG,'CAL'),
   X = d3builtincal(X,CFG) ;
end
return
