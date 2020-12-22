fsin=526.23;
fsout=500;
tin=10126.1754+(0:99)/fsin;
x=fir_nodelay(randn(length(tin),1),12,0.3);
[y,tout] = lanczos_resample(x,tin,fsout)
figure(1),clf
plot(tin-floor(tin(1)),x),grid
hold on
plot(tout-floor(tin(1)),y,'r')

