function    info=audioinfo(fname)

%    info=audioinfo(fname)
%		Compatibility tool for versions of Matlab <2015.

[s,fs] = audioread(fname,'size') ;
info.TotalSamples = s(1) ;
info.NumChannels = s(2) ;
info.Duration = s(1)/fs ;
info.SampleRate = fs ;
