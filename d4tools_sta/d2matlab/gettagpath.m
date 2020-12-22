function    datapath = gettagpath(datatype)
%
%    datapath = gettagpath(datatype)
%    Prints the paths selected for tag data using settagpath.m
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: July 2012

datapath = [] ;
if ~exist('TAG_PATHS','var'),
   global TAG_PATHS
else
   if ~isglobal(TAG_PATHS),
      ss = TAG_PATHS ;
      clear TAG_PATHS ;
      global TAG_PATHS
      TAG_PATHS = ss ;
   end
end

if isempty(TAG_PATHS),
   fprintf(' No tag data paths currently selected\n') ;
end

fnames = fieldnames(TAG_PATHS) ;
if nargin>0,
   datatype = upper(datatype) ;
   if isfield(TAG_PATHS,datatype),
      datapath = getfield(TAG_PATHS,datatype) ;
      return
   else
      fprintf('no path for data type "%s"\n',datatype) ;
      return
   end
end

for k=1:length(fnames),
   fprintf(' %s path set to %s\n', fnames{k},getfield(TAG_PATHS,fnames{k}))
end
