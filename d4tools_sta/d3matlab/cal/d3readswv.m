function    X = d3readswv(recdir,prefix,df,ch,fnums)

%     X = d3readswv(recdir,prefix)
%     or
%     X = d3readswv(recdir,prefix,df)
%     or
%     X = d3readswv(recdir,prefix,df,ch)
%     or
%     X = d3readswv(recdir,prefix,df,ch,fnums)
%
%     Reads a sequence of D3 format SWV (sensor wav) sensor files
%     and assembles a continuous sensor sequence in x.
%     Calls d3parseswv to read in each file.
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%     df is an optional decimation factor. If df is not specified, a
%        df of 1 is used, i.e., the full rate data is returned (which
%        may be very large and cause memory problems). If df is a
%        positive integer, the data will be decimated to give a rate 
%        for each channel of 1/df of the input data rate.
%     ch is an optional vector of channel numbers to read. Use [] for 
%        all channels. If specified, only sensor channels matching values
%        in ch will be read. The channel numbers are the same as those
%        returned in X.cn. To find out what channels are available in 
%        a dataset, use d3channames(recdir,prefix).
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
%     Updated 11/2/16 to fill gaps between recordings
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

DISCARD = 1 ;     % discard the first 1s of data at start and after each gap
                  % to avoid power-up transients. Discard is done by replacing
                  % with NaNs to keep timing correct
OUTTHR = 0.4 ;
MAXOUT = 100 ;
MAXSIZE = 30e6 ;  % maximum size of storage object before using part files

if nargin<3 || isempty(df),
   df = 1 ;
end

if nargin<4,
   ch = [] ;
end

% get file names and cue table
[ct,nu1,fs,fn,recdir,recn] = d3getcues(recdir,prefix,'swv') ;
ct(:,1) = recn(ct(:,1)) ;
if nargin==5 && ~isempty(fnums),
   k = find(ismember(recn,fnums)) ;
   fn = {fn{k}} ;
   recn = recn(k) ;
   k = find(ismember(ct(:,1),fnums)) ;
   ct = ct(k,:) ;
end

basefs = fs ;
X.x = [] ; X.fs = [] ; X.cn = [] ;
if isempty(fn), return, end
x = [] ;
dodiscard = 1 ;
npartf = 0 ;
delete('_d3rpart*.mat') ;

% read in swv data from each file
for k=1:length(fn),
   fprintf('Reading file %s\n', fn{k}) ;
   XX = d3parseswv([recdir '/' fn{k}],ch) ;
   if isempty(XX.fs), return, end
   ctab = ct(ct(:,1)==recn(k),2:end) ;     % get cue table for this file
   fs = XX.fs; cn = XX.cn ;
   [nu1,nu2,nu3,ctype] = d3channames(XX.cn) ;
   xx = XX.x ;
   clear XX
   fsmult = round(fs/basefs) ;
   if isempty(x),
      x = cell(length(xx),1) ;
      if ischar(df),
         fso = sscanf(upper(df),'U%d') ;
         df = round(fs/fso) ;
         for kk=1:length(xx),
            z{kk} = df(kk) ;
         end
      else
         [z{1:length(xx)}] = deal(df) ;
         df = df*ones(size(fs)) ;
      end
      curs = cell(length(xx),1) ;
   end

   % replace first DISCARD seconds with NaNs if dodiscard is set
   if dodiscard,
      nfill = round(min(fs)*DISCARD) ;
      %fprintf(' Discard recn %d, %d samples\n', recn(k),nfill);
      for kk=1:length(xx),
         fill = NaN*ones(nfill*fsmult(kk),1) ;
         xx{kk}(1:size(fill,1)) = fill ;
      end
      dodiscard = 0 ;
   end

   % remove any single sample outliers on each sensor, skipping MAG and ACC sensors
   for kk=1:length(xx),
      if ismember(ctype{kk},{'acc','mag'}), continue, end
      %d = diff(xx{kk}) ;
      %ko = find(d(1:end-1,:)>OUTTHR & d(2:end,:)<-OUTTHR) ;
      %if length(ko)<MAXOUT,
      %   xx{kk}(ko+1) = xx{kk}(ko) ;
      %end
      xx{kk} = deglitch(xx{kk}) ;
   end

   try   % NaN-fill end of X if there is a gap in the cue table and this is not the end
      if ctab(end,end)<0 && k<length(fn),
         nfill = ctab(end,2) ;
         fprintf(' Fill recn %d, %d samples\n', recn(k),nfill);
         for kk=1:length(xx),
            fill = NaN*ones(nfill*fsmult(kk),1) ;
            xx{kk}(end+(1:size(fill,1))) = fill ;
         end
         dodiscard = 1 ;   % do a discard on the next block
      end
   catch
      keyboard
   end
   
   for kk=1:length(xx),
      if df(kk)==1,
         x{kk}(end+(1:length(xx{kk}))) = xx{kk} ;
      else 
   	   [xd,z{kk}] = decz(xx{kk},z{kk}) ;
         x{kk}(end+(1:size(xd,1))) = xd ;
      end
   end
   
   sz = whos('x') ;
   if sz.bytes > MAXSIZE,
      npartf = npartf+1 ;
      fname = sprintf('_d3rpart%d.mat',npartf) ;
      save(fname,'x') ;
      x = cell(length(xx),1) ;
   end
end

X.fs = fs./df ;
if df>1,
   % get the last few samples out of the decimation filter
   for kk=1:length(x),
      xd = decz([],z{kk}) ;
      x{kk}(end+(1:length(xd))) = xd ;
   end
end

% reload part files if they were used
if npartf>0,
   npartf = npartf+1 ;
   fname = sprintf('_d3rpart%d.mat',npartf) ;
   save(fname,'x') ;
   x = cell(length(xx),1) ;
   for k=1:npartf ;
      fname = sprintf('_d3rpart%d.mat',k) ;
      xx = load(fname) ;
      delete(fname) ;
      xx = xx.x ;
      for kk=1:length(xx),
         x{kk}(end+(1:length(xx{kk}))) = xx{kk} ;
      end
   end
   clear xx
end

% reorient columns if necessary
for kk=1:length(x),
   x{kk} = x{kk}(:) ;
end

X.x = x ;
X.cn = cn ;
return
