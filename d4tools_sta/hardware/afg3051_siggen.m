function    x = afg3051_siggen(x,fs,fname)
%
%    afg3051_siggen(x,fs,fname)
%     Make a csv file for arbitrary waveform generation
%     on the Gwinstek AF-3051 signal generator.
%
%     Use ARB setting on sig gen front panel.
%     x should be between -1 and 1 and should have 1048574 samples or less.
%     Waveform is zero-filled to 1048574 samples and converted to 16 bit signed
%     to generate the CSV file.

x = x(:) ;
if length(x)<1048574,
   x = [x;zeros(1048574-length(x),1)] ;
end

f = fopen(fname,'wt') ;
fprintf(f,'Start:,1,\n') ;
fprintf(f,'Length:,%d,\n',length(x)) ;
fprintf(f,'Sample Rate:,+%E,\n',fs) ;
fprintf(f,'%d,\n',round(32767*x)) ;
fclose(f) ;
