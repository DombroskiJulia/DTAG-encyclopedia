function    cuefname = makecuefile(recdir,prefix,suffix)
%
%    cuefname = makecuefile(recdir,prefix,suffix)
%     Forms a cue file from a sequence of D3 WAV-format files with
%     names like recdir/prefixnnn.suffix, where nnn is a 3 digit number.
%     Suffix can be 'wav' (the default) or 'swv' or any other suffix
%     assigned to a wav-format configuration.
%     Called by d3getcues.
%
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

cuefname = [] ;
if nargin<3 || isempty(suffix),
   suffix = 'wav' ;
end

[cuetab,fs,fn,recdir,id,recn] = d3getwavcues(recdir,prefix,suffix) ;
if isempty(cuetab)
   return ;
end

tempdir = gettempdir ;
cuefname = [tempdir '_' prefix suffix 'cues.mat'] ;

% nominate a reference time and refer the cues to this time
ref_time = cuetab(1,2)+cuetab(1,3)*1e-6 ;  % ref time is time of 1st sample in the deployment
ctimes = (cuetab(:,2)-cuetab(1,2))+(cuetab(:,3)-cuetab(1,3))*1e-6 ;
cuetab = [cuetab(:,1) ctimes cuetab(:,4:5)] ;
vers = d3toolvers() ;

vv = version ;
if vv(1)>'6',
   save(cuefname,'-v6','ref_time','fn','fs','id','cuetab','recdir','recn','vers') ;
else
   save(cuefname,'ref_time','fn','fs','id','cuetab','recdir','recn','vers') ;
end

return
