function    [CAL,DEPLOY] = d3deployment(recdir,prefix,uname)
%
%      [CAL,DEPLOY] = d3deployment(recdir,prefix,uname)
%      Collect information about a deployment and create a deployment
%         'cal' file. Any timing inconsistencies will be reported and,
%         if possible, repaired.
%      recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%      prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%      uname is the full name that will be given to the deployment. Typically
%        this will have a two letter species prefix followed by a two digit
%        year, an underscore and the three digit Julian day. A final letter
%        indicated the deployment of the day, e.g., eg15_207a. If a uname #
%        is not given, the prefix is used.
%
%      Returns:
%      CAL  is a structure containing calibration information for the tag
%        used in the deployment. This can be used with the data-driven
%        calibration refinement tools such as d3calpressure.
%      DEPLOY is a structure containing general information about the
%        deployment.
%      A CAL file called <uname>cal.xml will be written to the CAL 
%        directory on the tag path (see settagpath.m). If a CAL file with
%        the same name already exists it will be overwritten.
%
%      Examples:
%          CAL=d3deployment('e:/data/bb10','bb215a','bb10_215a') ;
%      or  d3deployment('e:/data/bb10','bb10_215a') ;
%
%      Updated 12/2/16 to defer timing error detection to d3getwavcues.m
%      Updated 22/1/17 to accommodate DTAG4
%
%      markjohnson@st-andrews.ac.uk
%      Licensed as GPL, 2013

DEPLOY = [] ; CAL = [] ;

if nargin<2,
   help d3deployment
   return
end

if nargin<3,
   uname = prefix ;
end

% make a filename for the deployment 'cal' file
global TAG_PATHS
if isempty(TAG_PATHS) | ~isfield(TAG_PATHS,'CAL'),
   fprintf(' No CAL file path - use settagpath\n') ;
   return
end
ufname = sprintf('%s/%scal.xml',getfield(TAG_PATHS,'CAL'),uname) ;

% check if a deployment file already exists - if so, check if overwriting is ok
if exist(ufname,'file'),
   ss = sprintf(' A deployment with the same name already exists.\n Do you want to overwrite it? y/n... ') ;
   s = input(ss,'s') ;
   if lower(s(1))=='n',
      return
   end
end

[fn,did,recn,recdir] = getrecfnames(recdir,prefix) ;
DEPLOY.ID = dec2hex(did(1)) ;
if length(DEPLOY.ID)<8,      % check if zero-padding is required
   DEPLOY.ID = [repmat('0',1,8-length(DEPLOY.ID)) DEPLOY.ID];
end
DEPLOY.NAME = [] ;
DEPLOY.RECN = recn ;
DEPLOY.RECDIR = recdir ;
DEPLOY.FN = fn ;
fprintf(' Checking sensor files...\n') ;
d3getcues(recdir,prefix,'swv') ;
fprintf(' Checking audio files...\n') ;
d3getcues(recdir,prefix,'wav') ;

% look for a suitable CAL
CAL = d4findcal(recdir,prefix);
DEPLOY.CAL = CAL ;

% create the deployment record file
writematxml(DEPLOY,'DEPLOY',ufname) ;
