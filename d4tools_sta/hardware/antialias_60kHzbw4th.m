fr = 60e3 ;

% butter design
fd = 75e3 ;
f1 = 90e3 ;
f2 = 1*fd ;
f3 = 1*fd ;
q1 = 1.3 ;

w1 = 2*pi*f1/fr ;
w2 = 2*pi*f2/fr ;
w3 = 2*pi*f3/fr ;

b1 = [1 w1/q1 w1^2] ;
b2 = [1 w2] ;
b3 = [1 w3] ;

b = w1^2*w2*w3 ;
a = conv(conv(b1,b2),b3) ;
w = 2*pi*logspace(-0.5,0.7,1000)' ;
f = w/2/pi ;
h = freqs(b,a,w) ;
figure(1),clf,subplot(211)
semilogx(f,20*log10(abs(h))),grid
hold on
plot(f,-2+0*f,'r--')
plot(f,-40+0*f,'g--')
subplot(212)
semilogx(f(2:end),-diff(unwrap(angle(h)))./(2*pi*diff(f)*fr)*1e6),grid
