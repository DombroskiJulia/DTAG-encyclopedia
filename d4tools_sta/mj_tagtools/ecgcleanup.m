function    [y,h] = ecgcleanup(x,FS,lambda,thr,h)
%
%    [y,h] = ecgcleanup(x,fs,lambda,thr,h)
%

fmains = 49.99 ;     % frequency of mains interference, Hz
Fbase = 250 ;         % frequency of sensor interference, Hz
g = 5 ;

if nargin<2,
   ecgcleanup ;
end

if nargin<3 | isempty(lambda),
   lambda = 0.0001 ;
end

if nargin<4 | isempty(thr),
   thr = 100 ;
end

N = round(FS/Fbase) ;
wf = 2*pi*fmains/FS ;

if nargin<5 | isempty(h),
   h = zeros(N+2,1) ;
end

y = zeros(length(x),1) ;
bl = floor(length(x)/N) ;
R = hadamard(N) ;
blk = (0:bl-1)*N ;

for k=1:bl,
   kk = blk(k)+(1:N) ;
   s = g*exp(j*wf*kk');
   RR = [R real(s) imag(s)] ;
   e = x(kk)-RR*h ;
   y(kk) = e ;
   if std(e)<thr,
      h = h + RR'*(lambda*e) ;
   end
end
