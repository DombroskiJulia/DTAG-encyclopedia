function    X = d3parseswv(fname,ch)
%    X = d3parseswv(fname,[ch])
%     Read a D3 format SWV (sensor wav) sensor file using
%     the accompanying xml file to interpret the sensor channels.
%     To read all sensor files from a deployment, use d3readswv
%     which calls this function.
%     fname is the full path (if needed) and filename of the swv
%     file to read. The .swv suffix is not needed.
%     ch is an optional vector of channel numbers to read. Use [] for 
%        all channels. If specified, only sensor channels matching values
%        in ch will be read. The channel numbers are the same as those
%        returned in X.cn. To find out what channels are available in 
%        a dataset, use d3parseswv(fname,'info') or d3channames(recdir,prefix).
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
%     Updated 29/1/18 to enable subset of channels to be read
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

X.x = [] ; X.fs = [] ; X.cn = [] ;
% remove a suffix from the file name if there is one
if any(fname=='.'),
   fname = fname(1:find(fname=='.',1)-1) ;
end

% get metadata
% get sensor channel names from the xml file 
d3 = readd3xml([fname '.xml']) ;
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

if nargin==2 && ~isempty(ch),
   if ischar(ch)
      if strcmp(ch,'info'),
         return
      else
         fprintf('Unknown option "%s" to d3parseswv\n',ch) ;
         return
      end
   end
   k = find(ismember(uchans,ch)) ;
   uchans = uchans(k) ;
   fs = fs(k) ;
   X.cn = uchans ;
   X.fs = fs ;
end

if isempty(uchans),
   return
end

% read the swv file and convert to fractional offset binary
n = wavread16([fname '.swv'],'size') ;
if n(1)*n(2)>100e6,
   s = input(sprintf(' Warning: very large file (%d bytes). Continue y/n? ',n(1)*n(2)*8),'s') ;
   if s(1)~='y',
      return ;
   end
end

xb = wavread16([fname '.swv']) ;
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

X.x = x ;
return
