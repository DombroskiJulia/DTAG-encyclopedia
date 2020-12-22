function    clear_cues(prefix)
%
%     clear_cues(prefix)
%     Delete the directory and cue helper files for a tag deployment.
%     These helper files are generated automatically to speed up processing
%     of the large number of files in a dtag archive. If the archive is
%     changed e.g., by adding or deleting recordings, the helper files are
%     no longer valid and have to be re-built. This function deletes the
%     files forcing them to be rebuilt by subsequent operations.
%
%     markjohnson@st-andrews.ac.uk
%     10 march 2018

if nargin<1,
   prefix = [] ;
end

if isempty(prefix),
   s = input('Are you sure you want to delete all cue files? y/n... ','s') ;
   if s(1)~='y',
      return
   end
end

tempdir = gettempdir ;
cuefname = [tempdir '_' prefix '*.mat'] ;
fn = dir(cuefname) ;
s = warning('off','MATLAB:DELETE:FileNotFound') ;
for k=1:length(fn),
   delete([tempdir fn(k).name]) ;
end
warning(s) ;
