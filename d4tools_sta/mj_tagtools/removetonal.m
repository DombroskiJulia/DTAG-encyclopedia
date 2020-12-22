function    [y,h] = removetonal(x,FS,f,lambda,thr,h)
%
%    [y,h] = removetonal(x,fs,f,lambda,thr,h)
%

if nargin<2,
   removetonal ;
end

if nargin<3 | isempty(f),
   f = 50 ;       % frequency of interference, Hz
end

if nargin<4 | isempty(lambda),
   lambda = 0.01 ;
end

if nargin<5 | isempty(thr),
   thr = 100 ;
end

nh = floor(FS/f/2) ;          % number of harmonics

if nargin<6 | isempty(h),
   h = zeros(2*nh,1) ;
end

if length(h)<2*nh,
   h(end+1:2*nh) = 0 ;
end

y = zeros(length(x),1) ;
wf = 2*pi*(1:nh)*f/FS ;
N = round(FS/f*10) ;
R = exp(j*(0:N-1)'*wf) ;
bl = floor(length(x)/N) ;
blk = (0:bl-1)*N ;

for k=1:bl,
   kk = blk(k)+(1:N) ;
   RR = repmat(exp(j*(kk(1)-1)*wf),N,1).*R ;
   RR = [real(RR) imag(RR)] ;
   e = x(kk)-RR*h ;
   y(kk) = e ;
   %if std(e)<thr,
      h = h + RR'*(lambda*e) ;
   %end
end
