function    [x,fs] = readwav(fname,samples)
%
%   [x,fs] = readwav(fname,samples)
%     Version independent wav file reader.
%     This function defers to audioread or wavread depending
%     on which tools is available.
%

if exist('audioread')==2,
   if iscell(fname),
      x = [] ;
      for k=1:length(fname),
         [xx,fs] = audioread(fname{k}) ;
         x = [x;xx] ;
      end
   elseif nargin==2,
      [x,fs] = audioread(fname,samples) ;
   else
      [x,fs] = audioread(fname) ;
   end
else
   if iscell(fname),
      x = [] ;
      for k=1:length(fname),
         [xx,fs] = wavread(fname{k}) ;
         x = [x;xx] ;
      end
   elseif nargin==2,
      [x,fs] = wavread(fname,samples) ;
   else
      [x,fs] = wavread(fname) ;
   end
end

