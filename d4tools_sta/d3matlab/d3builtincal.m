function    X = d3builtincal(X,cfg)

%    X = d3builtincal(X,cfg)
%     Apply built-in calibrations to corresponding sensor channels.
%     This is called by d3parseswv and d3getswv to apply calibrations
%     to the temperature and pressure channels for tags with I2C pressure
%     sensors.

if nargin<2,
   help d3builtincal
   return
end

if ~isfield(cfg,'CAL') || ~strncmp(cfg.CAL.SENS,'PRES',4),
   return
end

% get pressure sensor calibration constants
cc = cfg.CAL.CAL ;
cc(cc=='_') = '-' ;
psel = struct('cal',str2num(cc)) ;
if isfield(cfg,'TYPE') && strncmp(cfg.TYPE.SENS,'PRES',4),
	psel.type = deblank(cfg.TYPE.TYPE) ;
else
	psel.type = [] ;
end
if isfield(cfg,'POFFS'),
	psel.poffs = str2num(cfg.POFFS) ;      % find the sensor sampling rate
else
	psel.poffs = -12500 ;
end
if isfield(cfg,'POFFS'),
	psel.toffs = str2num(cfg.TOFFS) ;      % find the sensor sampling rate
else
	psel.toffs = 0 ;
end

if isempty(psel.type),
	fprintf(' No sensor type identified for builtin calibration\n') ;
   return
end

if ~exist(psel.type,'file')
   fprintf(' No method found for sensor type "%s"\n',c.type) ;
   return
end

% find channels that need to be calibrated
[chnames,descr,chnums] = d3channames(X) ;
if length(chnums)==1,
   chnames = {chnames} ;
   descr = {descr} ;
end
 
m = strfind(descr,psel.type) ;
ch = [0 0 0] ;
for k=1:length(m),
   if isempty(m{k}), continue, end
   if strncmp(chnames{k},upper('temp'),4),
      ch(1) = k ;
   elseif strncmp(chnames{k},upper('presext'),7),
      ch(3) = k ;
   elseif strncmp(chnames{k},upper('pres'),4),
      ch(2) = k ;
   end
end

if ch(1)==0,
   return
end

t = X.x{ch(1)} ;
p = [] ; ext = [] ;
if ch(2)~=0,
   p = X.x{ch(2)} ;
end
if ch(3)~=0,
   ext = X.x{ch(3)} ;
end

try
   [d,t] = feval(lower(psel.type),psel,p,t,ext) ;
catch
   fprintf(' Calibration failed for sensor type "%s"\n',psel.type) ;
   return
end

X.x{ch(1)} = t ;
if ch(2)~=0,
   X.x{ch(2)} = d ;
end
