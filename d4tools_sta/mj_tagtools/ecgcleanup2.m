function    [y,fs] = ecgcleanup2(ecg,fs)
%
%  [y,fs] = ecgcleanup2(ecg,fs)
%

x = decdc(ecg,20) ;
N = 50 ;
wf = 2*pi*(1:4)'*50/(fs/20);
R = exp(j*wf*(0:N-1)) ;
nbl = floor(length(x)/N) ;
y = zeros(N,nbl) ;
xx = reshape(x(1:N*nbl),N,nbl) ;
H = R*xx ;
Y = xx-(2/N)*real(R'*H) ;
y = decdc(Y(:),2) ;
fs = fs/40 ;
yl = fir_nodelay(y,250,2.5/125);
y = y-yl ;
