function    d3preprocgps(recdir,prefix,suffix,fnums)
%
%    d3preprocgps(recdir,prefix,[suffix,fnums])
%     Pre-process GPS grabs collected by dtag-3 or dtag-4 tags. This
%     function finds and reads in binary gps files and performs the
%     ambiguity (delay-doppler) search to find satellite signals. It saves
%     the SNR, delay and doppler for each satellite and grab in files with
%     the same name as the binary files but with a gps.mat suffix.
%     recdir is the full path of the directory where the tag data is stored.
%     prefix is the common first part of the name of the files in that
%     directory.
%     suffix is an optional suffix for the gps grab files (default is
%     .bin).
%     fnums is an optional vector of file numbers to process. If not
%     specified, all files will be processed.
%
%     markjohnson@st-andrews.ac.uk
%     www.soundtags.org
%     20 January 2017

[fn,did,recn,recdir] = getrecfnames(recdir,prefix,1) ;

if nargin<3 || isempty(suffix),
   suffix = 'bin' ;
end

if nargin<4 || isempty(fnums),
   fnums = 1:length(fn) ;
else
   % identify which files are being requested
   n = zeros(length(fn),1) ;
   for k=1:length(fn),
      n(k) = sscanf(fn{k}(end+(-2:0)),'%03d') ;
   end
   fnums = find(ismember(n,fnums(:)'))' ;
end

% find metadata
for k=fnums,
   d3 = readd3xml([recdir fn{k} '.xml']) ;
   if ~isempty(d3), break, end
end

if isempty(fnums) || isempty(d3),
   fprintf(' No xml files found with names like %sNNN\n', [recdir prefix]) ;
   return
end

if ~isfield(d3,'CFG'),
   fprintf(' No CFG fields found in xml file %s\n', [recdir fn{1}]) ;
   return
end

% decode tag type
dtype = [] ;
if isfield(d3,'DGEN'),
   if strncmp(d3.DGEN,'D4',2),
      dtype = 4 ;
   else
      dtype = 3 ;
   end
else
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
         if strncmp(c.OTHER.RF,'SE4150L',6),
            dtype = 4 ;
         else
            dtype = 3 ;
         end
      end
   end
end

if isempty(dtype),
   fprintf(' Unable to determine tag type from xml file\n') ;
   return
end

for k=fnums,
   fname = [recdir fn{k} '.' suffix] ;
   if exist(fname,'file'),
      fprintf('Processing gps file %s...\n',fname) ;
      obs = proc_gpsbinfile(fname,[],dtype) ;
      ofn = [recdir fn{k} 'gps.mat'] ;
      save(ofn,'obs') ;
   else
      fprintf('No bin file for recording %s\n',fn{k}) ;
   end
end
