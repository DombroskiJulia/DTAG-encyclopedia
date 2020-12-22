fr = 60e3 ;

% bessel design
%fd = 95e3 ;
%f1 = 1.0825*fd ;  % 1.0825
%f2 = 0.9598*fd ;  % 0.9598
%f3 = 1.05*fd ;     % 0.9264*fd
%q1 = 1.2 ;   % 0.917
%q2 = 0.54 ;    % 0.5635

% butter design
fd = 95e3 ;
f1 = 1*fd ;
f2 = 1*fd ;
f3 = 1*fd ;
q1 = 1.62 ;
q2 = 0.62 ;

fd = 90e3 ;
f1 = 1*fd ;
f2 = 1*fd ;
f3 = 1*fd ;
q1 = 0.8 ;
q2 = 0.7 ;

w1 = 2*pi*f1/fr ;
w2 = 2*pi*f2/fr ;
w3 = 2*pi*f3/fr ;

b1 = [1 w1/q1 w1^2] ;
b2 = [1 w2/q2 w2^2] ;
b3 = [1 w3] ;

b = w1^2*w2^2*w3 ;
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
