function DTAG = dtagtype(tag,SILENT)
%
%     DTAG = dtagtype(tag,SILENT)
%     Report which tag type a given tag deployment is.
%     e.g., dtagtype('md04_287a')
%     Returns 2 for DTAG-2 and 3 for DTAG-3 or [] if
%     tag type cannot be evaluated.
%
%     FHJ 8 April 2014

DTAG=0;
if nargin<2,
   SILENT = 0 ;
end
global TAG_PATHS
if isempty(TAG_PATHS) | ~isfield(TAG_PATHS,'CAL'),
   if SILENT==0,
      fprintf(' No %s file path - use settagpath\n', 'CAL') ;
   end
   return
end

% If DTAG2, CAL file is stored as .MAT
d2suffix = strcat(tag,'cal.xml') ;
d2cal = sprintf('%s/%s',getfield(TAG_PATHS,'CAL'),d2suffix) ;
if exist(d2cal,'file')
   DTAG=2;
   return
end

% If DTAG3, CAL file is stored as .XML
d3suffix = strcat(tag,'cal.mat') ;
d3cal = sprintf('%s/%s',getfield(TAG_PATHS,'CAL'),d3suffix) ;
if exist(d3cal,'file')
    DTAG=3;
    return
end

if SILENT==0,
   disp('No CAL file found when evaluating function dtagtype')
end
return
    
