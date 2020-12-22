recdir='C:\Heather\DTAGs\d4\D4\Data\Movingtarget2\raw\B\target\20170525_AM';
odir='C:\Heather\DTAGs\d4\D4\Data\Movingtarget2\metadata\SifB1';

fname='SifB1_1tgt.wav';
oname='SifB1_1';


[x,fs]=audioread([recdir '\' fname]);%,[500e3*(0+[10 25.9])]);

A=decdc(decdc(x(:,2:3),40),25);
fsa = fs/40/25;
Ams2=(A*5-2)*9.8/0.814 ;
save([odir '\' oname 'acc.mat'],'-v6','A','Ams2','fsa')

% make envelope of audio
df=8;
hpf=100e3;
[b,a]=butter(6,hpf/(fs/2),'high');
x=x(:,1);
save([odir '\' oname 'hyd.mat'],'-v6','x','fs')
x=hilbenv(filter(b,a,x));
x=buffer(x,2*df,df,'nodelay');
x=sqrt(mean(x.^2))' ;
fs=fs/df;
save([odir '\' oname 'hydenv.mat'],'-v6','x','fs')

load([odir '\' oname 'cl.mat'])
t=timeoffset(x,fs,cl,1,2)

figure, ax(1)=subplot(211),plot((1:size(Ams2,1))/fsa-t,Ams2),grid
ax(2)=subplot(212), plot_echogram(x,fs,cl)
linkaxes(ax,'x')
