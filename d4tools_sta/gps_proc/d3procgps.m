function    OBS = d3procgps(recdir,prefix,suffix,start,OBS)
%
%    Obs = d3procgps(recdir,prefix,[suffix,start,OBS])
%

[fn,did,recn,recdir] = getrecfnames(recdir,prefix,1) ;

if nargin<3 || isempty(suffix),
   suffix = 'bin' ;
end

if nargin<4 || isempty(start),
   start = 1 ;
end

if nargin<5,
   OBS = [] ;
end

% find metadata
d3 = [] ; k = 0 ;
while isempty(d3),
   k=k+1; d3 = readd3xml([recdir '\' fn{k} '.xml']) ;
end

if isempty(d3),
   fprintf(' No xml files found with names like %s\n', [recdir '\' fn{1}]) ;
   return
end

if ~isfield(d3,'CFG'),
   fprintf(' No CFG fields found in xml file %s\n', [recdir '\' fn{1}]) ;
   return
end

% decode tag type
dtype = [] ;
cfg = d3.CFG ;
for k=1:length(cfg),
   c = cfg{k}(1) ;
   if isfield(c,'FTYPE') && strncmp(c.FTYPE,'bin',3),
      if isfield(c,'SUFFIX') && ~strncmp(c.SUFFIX,suffix,3),
         continue ;
      end
      if ~isfield(c,'OTHER') || ~isfield(c.OTHER,'RF'),
         continue ;
      end
      if(strncmp(c.OTHER.RF,'SE4150L',6)
         dtype = 4 ;
      else
         dtype = 3 ;
      end
   end
end
dtype
if isempty(dtype),
   fprintf(' Unable to determine tag type from xml file\n') ;
   return
end

for k=start:length(fn),
   fname = [recdir fn{k} '.' suffix] ;
   if exist(fname,'file'),
      fprintf('Processing gps file %s...\n',fname) ;
      obs = proc_gpsbinfile(fname,[],dtype) ;
      fn = [recdir fn{k} 'gps.mat'] ;
      save(fn,'obs') ;
      n = length(obs) ;
      if isempty(OBS),
         OBS = obs ;
      else
         [OBS(end+(1:n))] = deal(obs) ;
      end
   end
end

SNR = horzcat(OBS.snr) ;
N = sum(SNR>150) ;
D=catdlgfiles(recdir,prefix);
D=D(D(:,3)==1,4);
d = unique(D) ;
for k=1:length(d),
   n = sum(N(D(1:length(N))==d(k))>=4) ;
   fprintf('Setting %d: %d receptions\n',d(k),n) ;
end
