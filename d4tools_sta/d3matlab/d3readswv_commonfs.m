function    X = d3readswv_commonfs(recdir,prefix,fs,fnums)

%     X = d3readswv_commonfs(recdir,prefix)
%     or
%     X = d3readswv_commonfs(recdir,prefix,fs)
%     or
%     X = d3readswv_commonfs(recdir,prefix,fs,fnums)
%     
%     Read sensor data and convert to a common sampling rate, fs. 
%     This is useful to make a low sampling rate sensor data set for 
%     overview and calibration. Accepts DTAG3 and DTAG4 sensor data.
%
%     Inputs
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%     fs is the target sampling rate. Default value is 5 Hz. 
%     fnums is an optional vector of file numbers to read. The default is
%        to read all files in recdir with names starting with prefix. fnums
%        allows a subset of files to be specified. This is useful if there
%        is a large gap between recordings (e.g., due to duty-cycling) that
%        you do not want to fill to make a contiguous sensor vector.
%
%     Returns:
%     X  is a structure containing:
%        x: a cell array of sensor vectors. There are as many
%        cells in x as there are unique sensor channels in the
%        recording. Each cell may have a different length vector
%        according to the sampling rate of the sensor channel.
%        fs: a vector of sampling rates. Each entry in fs is the
%        sampling rate in Hz of the corresponding cell in x.
%        cn: a vector of channel id numbers corresponding to
%        the cells in x. Use d3channames to get the name and
%        description of each channel.
%
%     markjohnson@st-andrews.ac.uk
%     Last modified: January 2018

% get full sampling rates of each sensor channel
X = [] ;
if nargin<3,
   fs = 5 ;
end

if nargin<4,
   fnums = [] ;
end

[fn,did,recn,recdir] = getrecfnames(recdir,prefix);
if isempty(fn), return, end

x=d3parseswv([recdir fn{1}],'info');
if any(fs>x.fs),
   fprintf(' fs must be <= to lowest sensor sampling rate (%3.1f Hz)\n',min(X.fs)) ;
   return
end

dd = round(x.fs/fs) ;
df = unique(dd) ;
if any(abs(dd*fs-x.fs)>1e-10),
   fprintf(' fs is not an integer divider of all sensor sampling rates\n') ;
   return
end

cn = x.cn ;
xx = cell(length(dd),1) ;

for k=1:length(df),
   cc = find(dd==df(k)) ;
   ch = cn(cc) ;
   x=d3readswv(recdir,prefix,df(k),ch,fnums) ;
   if isempty(x.fs), return, end
   for kk=1:length(cc),
      xx{cc(kk)} = x.x{find(x.cn==ch(kk))} ;
   end
end

X.x = xx ;
X.fs=fs*ones(length(cn),1);
X.cn=cn ;
