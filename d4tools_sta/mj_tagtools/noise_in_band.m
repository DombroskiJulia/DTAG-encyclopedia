function   [v,fout] = noise_in_band(tag,f,startcue,endcue)
%
%     [v,fs] = noise_in_band(tag,f,startcue,endcue)
%
%     mark johnson
%     majohnson@whoi.edu
%     January, 2013
%

if nargin<4,
   help noise_in_band
   return
end

avetime = 0.001 ;          % averaging time in secs
LEN = 10 ;                 % audio block length in secs

cue = startcue ;

% get the sampling frequency
[x fs] = tagwavread(tag,cue,0.1) ;

% work out the decimation factor
df = round(avetime*fs) ;     % power averaging decimation factor
fout = 2*fs/df ;

% process is:
%  1. acquire a block of audio
%  2. sum the channels if multi-channel 
%  3. bandpass filter
%  4. average power over 1 ms with 50% overlap

[b,a] = butter(6,f/(fs/2)) ;
[y,Z] = filter(b,a,x) ;
v = [] ;

while cue<endcue,
   fprintf('Reading at cue %d\n', round(cue)) ;
   len = min([LEN,endcue-cue]) ;
   x = tagwavread(tag,cue,len+avetime) ;
   cue = cue+len ;

   [y,Z] = filter(b,a,x,Z) ;     % 3. p is at fout (25Hz BW)
   [y1,z] = buffer(y(:,1).^2,df,df/2,'nodelay') ;
   p = sum(y1) ;
   if size(y,2)>1,
      [y1,z] = buffer(y(:,2).^2,df,df/2,'nodelay') ;
      p = p+sum(y1) ;
   end
   n = min(length(p),round(len*fout)) ;
   v(end+(1:n)) = p(1:n) ;  % 4. v is at fout
end
v = v(:) ;
return
