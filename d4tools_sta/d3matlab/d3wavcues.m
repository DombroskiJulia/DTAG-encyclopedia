function    ltime = d3wavcues(cues,recdir,prefix,dirn)
%
%     ltime = d3wavcues(cues,recdir,prefix,dirn)
%     Report the local time corresponding to tag cues (i.e., 
%     second since start of recording).
%     If dirn=0 (default), cues is taken as containing tag cues.
%     If dirn=1, cues is taken as containing local times as datenumbers.
%
%     Returns:
%     ltime is in Unix seconds. 
%     Use d3datevec to convert to a date vector.
%
%     Usage:
%     ltime = d3wavcues(cues,recdir,prefix)
%     cues = d3wavcues(ltime,recdir,prefix,1)
%
%     MJ. Last modified feb 2015 - changed argument order in call
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

ltime = [] ; dv = [] ;
if nargin<3,
   help d3wavcues
   return
end

if nargin<4 || isempty(dirn),
   dirn = 0 ;
end

if nargin<5 || isempty(suffix),
   suffix = 'wav' ;
end

[ct,ref_time,fs,fn,recdir] = d3getcues(recdir,prefix,suffix) ;

if dirn==1
   ltime = cues-ref_time ;        % convert local times to cues
else
   ltime = ref_time+cues ;        % convert cues to local times
end
return
