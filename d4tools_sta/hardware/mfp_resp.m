function    [H,f,f0,q,K]=mfp_resp(r1,r2,r3,c1,c2)
%
%    [H,f,f0,q,K]=mfp_resp(r1,r2,r3,c1,c2)
%
%          ----r3----        
%     -r1- -r2-  -c2-
%         c1      

w0sq = 1./(c1*c2*r2*r3) ;
K = -r3/r1 ;
b = 1/c1*(1/r1+1/r2+1/r3) ;

f0 = sqrt(w0sq)/2/pi ;
q = sqrt(w0sq)/b ;
lfc = round(log10(f0)) ;
f = logspace(lfc-3,lfc+2,1000)' ;
h = freqs([0 0 K*w0sq],[1 b w0sq],2*pi*f) ;
H = 20*log10(abs(h)) ;
