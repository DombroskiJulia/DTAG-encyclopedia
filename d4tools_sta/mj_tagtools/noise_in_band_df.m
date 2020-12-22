function   v = noise_in_band_df(tag,f,startcue,endcue,df,fout)
%
%     v = noise_in_band_df(tag,f,startcue,endcue,df,fout)
%
%     mark johnson
%     majohnson@whoi.edu
%     January, 2013
%

if nargin<4,
   help noise_in_band
   return
end

LEN = 10 ;                 % audio block length in secs
cue = startcue ;

% get the sampling frequency
[x fs] = tagwavread(tag,cue,0.1) ;

% work out the output decimation factor
nbl = round(2*fs/df/fout) ;     % power averaging decimation factor

% process is:
%  1. acquire a block of audio
%  2. decimate by df
%  3. bandpass filter
%  4. average power over 2/fout seconds with 50% overlap

[b,a] = butter(6,f/(fs/df/2)) ;
Z1 = df ;
[y,Z1] = decz(flipud(x(:,1)),df) ;
[y,Z] = filter(b,a,y) ;
v = [] ;

while cue<endcue,
   fprintf('Reading at cue %d\n', round(cue)) ;
   len = min([LEN,endcue-cue]) ;
   x = tagwavread(tag,cue,len+nbl*df/fs) ;
   cue = cue+len ;

   [y,Z1] = decz(x(:,1),Z1) ;        % 1. y is at fint (fs/df)
   [y,Z] = filter(b,a,y,Z) ;     % 2. y is at fint
   [y1,z] = buffer(y.^2,nbl,nbl/2,'nodelay') ;
   p = sum(y1) ;                 % p is at fout
   n = min(length(p),round(len*fout)) ;
   v(end+(1:n)) = p(1:n) ;  % 4. v is at fout
end
v = v(:) ;
return
