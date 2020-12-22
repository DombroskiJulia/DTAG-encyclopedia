function    [y,tout] = lanczos_resample(x,tin,fsout)
%
%    [y,tout] = lanczos_resample(x,tin,fsout)
%

a = 2 ;
nf = 128 ;
phstep = 1/nf ;
t = -2:phstep:2-phstep ;
L = a*sin(pi*t).*sin(pi*t*(1/a))./(pi^2*t.^2) ;
L(t==0) = 1 ;
% make filter lookup table
T = reshape(L,nf,2*a) ;

to = ceil(tin(3)*fsout)/fsout ;
tout = (to:1/fsout:tin(end)-1/fsout) ;
% average input sampling rate
y = zeros(length(tout),1) ;
phsinc = (length(x)-1)/((tin(end)-tin(1))*fsout) ;
ks = find(tin>tout(1),1) ;
phs = ks+fsout*(tin(ks)-tout(1)) ;
for k=1:length(tout),
   kk = floor(phs)+(-2:1) ;
   kf = 1+floor(nf*rem(phs,1)) ;
   y(k) = T(kf,:)*x(kk) ;
   %y(k) = x(kk(3)) ;
   phs = phs+phsinc ;
end
