function    OBS = d3combineobs(recdir,prefix)
%
%    OBS = d3combineobs(recdir,prefix)
%     Combine preprocessed GPS observations for a tag deployment.
%     This should be run after d3preprocgps.m and before gps_posns.m
%     recdir is the path to the directory containing the preprocessed
%      observations (files ending with gps.mat).
%     prefix is the shared first part of the file names, e.g., for
%      files called hs16_265bnnngps.mat (where nnn is a three digit
%      number), the prefix would be 'hs16_265b'.
%

OBS = [] ;
if ~exist(recdir,'dir'),
   fprintf(' No directory %s\n', recdir) ;
   return
end

if length(recdir)>1 & ismember(recdir(end),['/','\']),
   recdir = recdir(1:end-1) ;
end

recdir = [recdir,'/'] ;       % use / for MAC compatibility
recdir(recdir=='\') = '/' ;
sp = [recdir,prefix,'*gps.mat'] ;
ff = dir(sp) ;

if isempty(ff),
   fprintf(' No files with names %s found\n',sp) ;
   return
end

for k=1:length(ff),
   s = load([recdir ff(k).name]) ;
   if isfield(s,'obs') && ~isempty(s.obs),
      if isempty(OBS),
         OBS = s.obs ;
      else
         OBS(end+(1:length(s.obs))) = s.obs ;
      end
   end
end
