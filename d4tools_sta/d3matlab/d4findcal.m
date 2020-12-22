function CAL = d4findcal(recdir,prefix,opt)
%
%     CAL = d4findcal(depid)     % read in an existing calibration file
%     or
%     CAL = d4findcal(recdir,prefix)   % get the attributes from the data
%     or
%     CAL = d4findcal(recdir,prefix,'file')  % read the attribute file
%
%     markjohnson@st-andrews.ac.uk
%     last modified: 2/3/18
%     - added depid call format

CAL = [] ;
if nargin<1,
   help d4findcal
   return
end

% first see if there is a calibration file for this deployment
if nargin==1,
   prefix = recdir ;
   recdir = [] ;
end

if ~isempty(recdir) && ~ismember(recdir(end),'\/') ;
   recdir(end+1) = '/' ;
end

fname = [recdir prefix 'cal.mat'] ;
if exist(fname,'file'),
   s = load(fname) ;
   if isfield(s,'CAL'),
      CAL = s.CAL ;
      return
   end
end

[fn,did,recn,recdir] = getrecfnames(recdir,prefix);
if isempty(fn),
   return
end

% get sensor settings from the xml file 
d3 = readd3xml([recdir fn{1} '.xml']) ;
if isempty(d3) | ~isfield(d3,'CFG'),
   fprintf('Unable to find or read file %s.xml - check the file name\n', fn{1});
   return
end

[CFG,fb,dtype] = getsensorcfg(d3) ;
if dtype~=4,
   CAL = d3findcal(did(1)) ;
   return
end

% get pressure sensor gain
if isfield(CFG,'GAIN') && strncmp(CFG.GAIN.SENS,'PRES',4),
   psel = str2num(CFG.GAIN.GAIN) ;
else
   psel = 0 ;
end

% get pressure sensor calibration constants if they are present
if isfield(CFG,'CAL') && strncmp(CFG.CAL.SENS,'PRES',4),
	cc = CFG.CAL.CAL ;
	cc(cc=='_') = '-' ;
   psel = struct('cal',str2num(cc)) ;
	if isfield(CFG,'TYPE') && strncmp(CFG.TYPE.SENS,'PRES',4),
		psel.type = deblank(CFG.TYPE.TYPE) ;
	else
		psel.type = [] ;
	end
	if isfield(CFG,'POFFS'),
		psel.poffs = str2num(CFG.POFFS) ;      % find the sensor sampling rate
	else
		psel.poffs = -12500 ;
	end
	if isfield(CFG,'POFFS'),
		psel.toffs = str2num(CFG.TOFFS) ;      % find the sensor sampling rate
	else
		psel.toffs = 0 ;
	end
end

% get accelerometer full-scale setting
accsel = 0 ;
if isfield(CFG,'RANGE')
   for k=1:length(CFG.RANGE),
      if strncmp(CFG.RANGE(k).SENS,'ACC',3),
         accsel = str2num(CFG.RANGE(k).RANGE) ;
      end
   end
end

% get audio gain
audsel = 0 ;
if isfield(d3,'EVENT'),
   for k=1:length(d3.EVENT),
      if isfield(d3.EVENT{k},'AUDIO'),
         if isfield(d3.EVENT{k}.AUDIO,'GAIN'),
            audsel = str2num(d3.EVENT{k}.AUDIO.GAIN) ;
         end
      end
   end
end

if nargin<3 || strcmp(opt,'file')~=1,
   for k=1:length(d3.CFG),
      c = d3.CFG{k} ;
      if isfield(c(1),'ATTR')
         s = c(1).ATTR.ATTR ;
         CAL = d4decodeattr(s,psel,accsel,audsel) ;
         break ;
      end
   end
end

if isempty(CAL),
   CAL = d4readattr(did(1),psel,accsel,audsel) ;
end
