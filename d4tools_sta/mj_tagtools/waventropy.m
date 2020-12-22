function    [h0,n,rms] = waventropy(fname,cues,h,t)
%
%    [h0,n,rms] = waventropy(fname,cues,h,t)
%

if nargin<2 | isempty(cues),
   cues = [0 Inf] ;
end

if nargin<3,
   h = [] ;
end

cue = cues(1) ;
endcue = cues(2) ;
LEN = 10 ;
nbits = 16 ;
% get the sampling frequency
[sz fs] = wavread(fname,'size') ;
endcue = min(endcue,sz(1)/fs(1)) ;

if ~isempty(h),
   [x,Z] = filter(h,1,zeros(100,1)) ;
end
m = 2^(nbits-1) ;
n = zeros(2*m,1) ;
ss = 0 ;

while cue<endcue,
   fprintf('Reading at cue %d\n', cue) ;
   len = min([LEN,endcue-cue]) ;
   x = wavread(fname,floor([fs*cue+1 fs*(cue+len)])) ;
   if length(x)<=length(h),
      break
   end
   cue = cue+len ;

   if ~isempty(h),
      [x,Z] = filter(h,1,x,Z) ;
   end
   n = n+histc(round(32768*x),-m:m-1) ;
   ss = ss + sum((x-mean(x)).^2) ;
end

if nargin>3,
   w = (-32768:32767)' ;
   kk = find(abs(w)<=t) ;
   p = n(kk)/sum(n(kk)) ;
else
   p = n/sum(n) ;
end

kk = find(p>0) ;
h0 = -sum(p(kk).*log(p(kk))) ;
h0 = h0/log(2) ;
rms = sqrt(ss/sum(n)) ;
return
