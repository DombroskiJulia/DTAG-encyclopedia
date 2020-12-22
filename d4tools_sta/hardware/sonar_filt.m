fs = 15e6;
ncyc = 6 ;
s=sin(2*pi*1.5e6/fs*(1:10*ncyc)');
ss=[zeros(100,1);s;zeros(1000,1)];
R=10;
C=2e-9;
L=11.3e-6/2;
[b,a]=impinvar([1 0 0],[1 R/L 1/L/C],fs);
%[b,a]=impinvar(1/L/C,[1 R/L 1/L/C],fs);
y=filter(b,a,ss);
F=fft([ss y],2048);
plot((0:1023)/2048*fs,20*log10(abs(F(1:1024,:)))),grid
