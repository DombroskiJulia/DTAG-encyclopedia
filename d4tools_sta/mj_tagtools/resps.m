function    R = resps(p,fs)
%
%      R = resps(p,fs)
%

T=finddives(p,fs,5);
fd = fs/5 ;
f = (0:255)*fd/512 ;
R = [] ;
for k=1:size(T,1)-1,
   kk=round(fs*T(k,2)):round(fs*T(k+1,1));
   if length(kk)/fs<60, continue, end
   pd = decdc(p(kk),5) ;
   [pp,z] = buffer(pd,60*fd,30*fd,'nodelay') ;
   F=fft((pp-repmat(mean(pp),60*fd,1)).*repmat(tukeywin(60*fd),1,size(pp,2)),512);
   [m fn] = max(abs(F)) ;
   R(end+(1:size(pp,2)),:) = [T(k,2)+(1:length(m))'*30 f(fn)'*60 m'/256/sqrt(2)/(sum(tukeywin(60*fd))/512) std(pp)'] ;
end
