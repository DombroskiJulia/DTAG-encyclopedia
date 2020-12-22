fd=35e3/2048e3;
fd1=35.5e3/2048e3;
s=exp(2*pi*j*fd*(0:2047)');
s1=exp(2*pi*j*fd1*(0:2047)');
F=fft([s s1]);

h=sinc(0.5+(-20:19)).*((-1).^(0:39)) ;
hh=h.*hamming(40)';
hh=hh(5:end-4);
ff=conv(hh,F(16:end,1));

figure(1),clf
subplot(211)
plot(abs([F(1:1024,:) ff(1:1024)]),'.-'),grid
axis([10 70 0 2050])

iff=ifft([F(:,2),ff(1:2048)]);
subplot(212)
plot([real(iff(:,2)) imag(iff(:,2))]),grid
