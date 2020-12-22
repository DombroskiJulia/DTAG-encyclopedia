df = 8 ; %decimation factor 
hpf = 80e3 ;
dirname = 'C:\Heather\DTAGs\d4\D4\test\' ;
fnames = dir([dirname '*.wav']) ;

for k=1:length(fnames),
   fn = [dirname fnames(k).name] ;
   kk = find(fn=='.',1,'last') ;
   fprintf('Processing %s...\n',fn(1:kk-1)) ;
   [x,fs]=wavread16(fn);
   [b,a]=butter(6,hpf/(fs/2),'high');
   x=hilbenv(filter(b,a,x));
   x=buffer(x,2*df,df,'nodelay');
   x=sqrt(mean(x.^2))' ;
   fs = fs/df ;
   save([fn(1:kk-1) '.mat'],'x','fs');
end