ddir = 'C:\tag_data\data\hp12_272a\' ;
fbase = 'hp12_272a_bz' ;
suffix = 'cl.mat' ;
bzn = [22682 27261 27949] ;
for k=1:length(bzn),
   fn = sprintf('%s%s%d%s',ddir,fbase,bzn(k),suffix);
   load(fn)
   ici=medianfilter(diff(cl(:,1)),3);
   cc=cl(1:end-1,1);
   ks = find(ici<0.004,1);
   ke = find(ici(ks:end)>0.013,1);
   ke = find(ici(ks+(0:ke))<0.004,1,'last');
   kk = ks+(0:ke);
   T=0.001*(ceil(1000*cc(1)):floor(1000*cc(end)))';
   ii=interp1(cc,ici(kk),T);
end

plot(f,10.^(S/20),'.-'),grid
