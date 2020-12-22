function   [v,fout] = d3flownoise(recdir,prefix,startcue,endcue)

%     [v,fs] = d3flownoise(tag,startcue,endcue)
%     Returns the time series of flow noise energy sampled at 25 Hz.
%
%     mark johnson
%     July, 2013
%

if nargin<1,
   help d3flownoise
   return
end

fint1 = 12000 ;            % 1st intermediate sampling rate for audio, Hz
fint2 = 1000 ;             % 2nd intermediate sampling rate for audio, Hz
fout = 25 ;                % output sampling rate, Hz
LEN = 10 ;                 % audio block length in secs

if nargin<3,
   [ct,rt,fs] = d3getcues(recdir,prefix,'wav') ;
   startcue = ct(1,2) ;
   endcue = ct(end,2)+ct(end,3)/fs ;
end

cue = startcue ;

% get the sampling frequency
[x fs] = d3wavread(cue+[0 0.1],recdir,prefix) ;

% work out the decimation factors
df1 = round(fs/fint1) ;
if abs(fs-df1*fint1)>0.05*fs,
   fprintf('unsuitable sampling rate - adjust decimation factors in the function\n') ;
end

df2 = round(fint1/fint2) ;    % 2nd decimation factor
df3 = round(fint2/fout) ;     % power averaging decimation factor

% process is:
%  1. acquire a block of audio
%  2. sum the channels if multi-channel 
%  3. decimate to a sampling-rate of 12kHz
%  4. decimate to 1kHz sampling-rate
%  5. compute instanteous power, p
%  6. decimate to 25Hz sampling

Z1 = df1 ;
Z2 = df2 ;
Z3 = df3 ;
v = [] ;
k = 0 ;

while cue<endcue,
   fprintf('Reading at cue %d\n', round(cue)) ;
   len = min([LEN,endcue-cue]) ;
   x = d3wavread(cue+[0 len],recdir,prefix) ;
   if isempty(x),
      break
   end
   cue = cue+len ;

   if size(x,2)>1,
      x = sum(x,2) ;
   end

   [y,Z1] = decz(x,Z1) ;        % 1. y is at fint1 (6kHz BW)
   [z,Z2] = decz(y,Z2) ;        % 2. z is at fint2 (500Hz BW)
   % need to take the diff of z to get rid of dc offset in the audio
   [p,Z3] = decz(diff(z).^2,Z3) ;     % 3. p is at fout (25Hz BW)
   n = length(p) ;
   v(k+(1:n)) = sqrt(abs(p)) ;  % 4. v is at fout
   k = k+n ;
end
v = v(:) ;
return
