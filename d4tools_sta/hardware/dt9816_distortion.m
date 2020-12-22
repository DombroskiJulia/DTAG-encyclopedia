figure(1),subplot(211),getDT9816,FS,[s,f]=speclev(x(50000:end),2048,FS);
subplot(212),plot(f,s),grid
std(x(50000:end))
k=nearest(f',g(:,1));
S = [s(k(1)+(-2:2)) s(k(2)+(-2:2))] ;
P = 10*log10(sum(10.^(S/10))) ;
diff(P)


figure(1),subplot(211),getDT9816,FS,[s,f]=speclev(x(50000:end),2048,FS);
subplot(212),plot(f,s),grid
std(x(50000:end))

xd=decdc(decdc(x(50000:end),8),8);
FSd=FS/64;
[b,a]=butter(5,[30 300]/(FSd/2));
xf=filter(b,a,xd);
std(xf(5000:end))

xd=decdc(x(50000:end),8);
FSd=FS/8;
[b,a]=butter(6,[300 3000]/(FSd/2));
xf=filter(b,a,xd);
std(xf(5000:end))

[b,a]=butter(6,[3000 30000]/(FS/2));
xf=filter(b,a,x);
std(xf(50000:end))

[b,a]=butter(6,[25000 100000]/(FS/2));
xf=filter(b,a,x);
std(xf(50000:end))

[b,a]=butter(6,[50000 200000]/(FS/2));
xf=filter(b,a,x);
std(xf(50000:end))
