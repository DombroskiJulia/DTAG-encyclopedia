function    gaps = d3gaps(recdir,prefix,suffix)
%    gaps = d3gaps(recdir,prefix,suffix)
%     Check the cue table for a deployment and report gaps in the
%     data of the selected type. If the cue table doesn't exist, it
%     will be made.
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%     suffix is an optional file suffix such as 'swv' indicating the
%        data stream (sensor or audio) to analyse. The default
%        is 'wav'.
%
%     Returns:
%     gaps is a two column vector containing:
%        [file_number gap_length]
%        with gap_length in seconds
%
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2016

if nargin<3,
   suffix = 'wav' ;
end

% get the cue table. Make one if there isn't one
[ct,~,fs,fn,recdir,recn] = d3getcues(recdir,prefix,suffix) ;
gaps = [] ;
if isempty(fn), return, end

% read in swv data from each file
for k=1:length(fn),
   ctab = ct(ct(:,1)==k,2:end) ;
   if any(ctab(1:end-1,end)<0),
      fprintf(' Gap(s) found within recording %d\n',recn(k));
   end
   if ctab(end,end) < 0,
      tfill = ctab(end,2)/fs ;
      fprintf(' Fill between recordings %d and %d of %f s (%d samples)\n', recn(k),recn(k+1),tfill,ctab(end,2));
      gaps(end+1,:) = [k,tfill] ;
   end
end
