function    [v,f] = sak_noise(r1,r2,c1,c2,g,f)
%
%  [v,f] = sak_noise(r1,r2,c1,c2)
%     Compute the input-output gain and the noise gain of a S&K filter.
%     v = [io_gain noise_gain] for each frequency in f.

w0sq = 1/(r1*r2*c1*c2) ;
w0 = sqrt(w0sq) ;
if nargin<6,
   w = logspace(log10(w0)-2,log10(w0)+0.5,3000)' ;
   f = w/2/pi ;
else
   w = 2*pi*f ;
end

s = j*w ;

v0vi = g*abs(w0sq./(s.^2+s*w0sq*(c2*(r1+r2)+c1*r1*(1-g))+w0sq)) ;
v0vn = g*abs((s.^2+s*w0sq*(c1*r1+c2*r1+c2*r2)+w0sq)./(s.^2+s*w0sq*(c2*(r1+r2)+c1*r1*(1-g))+w0sq)) ;
v = [v0vi v0vn] ;
