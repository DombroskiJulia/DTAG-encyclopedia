function    [h,S,f] = sens_decf(df,n,scf)
%
%
%
nf = n*df ;
nf = floor(nf/2)*2 ;
h=fir1(nf,scf/df)';
[ff,f]=freqz(h,1,2048,1000);
S=20*log10(abs(ff));
k1=find(S<-3,1);
k2=find(f>1000/df-f(k1),1) ;
[length(h) round(f(k1)) S(k2)]
hh = round(32766*h) ;
fprintf('%d,',hh) ;
fprintf('\n') ;
