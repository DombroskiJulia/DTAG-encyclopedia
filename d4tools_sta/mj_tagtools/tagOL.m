function    [L,fc] = tagOL(tag,nb,T,p,cues)
%
%   [L,fc] = tagOL(tag,nb,T,p,cues)
%   Compute octave levels for an entire wav file.
%     fname is the wav file name
%     nb is the number of octave bands to compute.
%     T=[Tr,Ta] where Tr is the reporting interval and Ta is
%     the minimum averaging interval, both in seconds.
%     p is a list of percentiles to compute.
%     Returns:
%     L is the power level in each octave band at each
%     sampling interval, in dB. It is an mxn matrix where m is the
%     number of sampling intervals in the file.
%     
%   mark johnson
%   last modified: July 2013

if nargin<3,
   help tagOL
   return
end

CH = 1 ;    % which channel to process if there are more than one

if nargin<5,
   reclen = recordlength(tag) ;
   cues = [0 reclen] ;
end

% get sampling rate and number of channels
[x,fs] = tagwavread(tag,cues(1),0.1) ;
fc = 0.7071*fs/2*2.^(0:-1:-nb+1) ;

tk = round(T(1)*fs)/fs ;
if tk*fs>1e7,
   fprintf('Sampling interval too long\n') ;
   return
end

ns = floor((cues(2)-cues(1))/tk) ;
if ns>1e7,
   fprintf('Sampling interval too short\n') ;
   return
end

ng = round(T(2)*fs) ;
p = p(:)' ;
L = zeros(ns,nb,length(p)) ;
hh = fir1(24,0.47,'high') ;
hl = fir1(24,0.53) ;
zx = zeros(24,nb) ;
zy = zx ;
Z = cell(nb,1) ;
curs = cues(1) ;

for k=1:ns,
   fprintf(' Processing block %d of %d\n',k,ns) ;
   x = tagwavread(tag,curs,tk) ;
   if size(x,2)>1,
      x = x(:,CH) ;
   end

   for kk=1:nb,
      [y,zy(:,kk)] = filter(hh,1,x,zy(:,kk)) ;
      [x,zx(:,kk)] = filter(hl,1,x,zx(:,kk)) ;
      x = x(2:2:end) ;
      [Y,Z{kk}] = buffer([Z{kk};y.^2],ng,0,'nodelay') ;
      mY = mean(Y) ;
      L(k,kk,:) = prctile(mY,p) ;
   end

   curs = curs+tk ;
end

L = 10*log10(L) ;
