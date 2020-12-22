function    L = wavOLeq(fname,nb,T,cues)
%
%   L = wavOLeq(fname,nb,T,cues)
%   Compute octave levels for an entire wav file.
%     fname is the wav file name
%     nb is the number of octave bands to compute.
%     T is the reporting interval in seconds.
%     Returns:
%     L is the power level in each octave band at each
%     sampling interval, in dB. It is an mxn matrix where m is the
%     number of sampling intervals in the file.
%     
%   mark johnson
%   last modified: July 2013

if nargin<3,
   help wavOLeq
   return
end

CH = 1 ;    % which channel to process if there are more than one

% get sampling rate and number of channels
[N,fs] = wavread16(fname,'size') ;
nk = round(T(1)*fs) ;
if nk>1e7,
   fprintf('Sampling interval too long\n') ;
   return
end

if nargin==4,
   curs = round(fs*cues(1)) ;
   cend = round(fs*cues(2)) ;
else
   curs = 1 ;
   cend = N(1) ;
end

ns = floor((cend-curs+1)/nk) ;
if ns>1e6,
   fprintf('Sampling interval too short\n') ;
   return
end

L = zeros(ns,nb) ;
hh = fir1(24,0.47,'high') ;
hl = fir1(24,0.53) ;
zx = zeros(24,nb) ;
zy = zx ;

for k=1:ns,
   fprintf(' Processing minute %3.1f of %3.1f\n',curs/fs/60,cend/fs/60) ;
   x = wavread16(fname,[curs curs+nk-1]) ;
   if size(x,2)>1,
      x = x(:,CH) ;
   end

   for kk=1:nb,
      [y,zy(:,kk)] = filter(hh,1,x,zy(:,kk)) ;
      [x,zx(:,kk)] = filter(hl,1,x,zx(:,kk)) ;
      x = x(2:2:end) ;
      L(k,kk) = mean(y.^2) ;
   end

   curs = curs+nk ;
end

L = 10*log10(L) ;
