%recdir='C:\tag_data\data\zif_acc_trials\raw';
%prefix='SifA';
recdir='C:\Heather\DTAGs\d4\D4\Data\Movingtarget2\raw';
prefix='A_';
odir='C:\Heather\DTAGs\d4\D4\New';
opref='SifA2_' ;
fname=sprintf('%s\\%s003',recdir,prefix);
X=d3parseswv(ldf([],'swv'));
X.x{8}=X.x{8}*100;
T=finddives(X.x{8},X.fs(8),0.5,0.2);
t=(1:length(X.x{8}))/X.fs(8);
plot(t,X.x{8}),grid
set(gca,'YDir','reverse');
g=ginput(2)
k=find(T(:,1)> g(1,1) & T(:,1) < g(2,1));
for kk=1:length(k),
   d3wavcopy(recdir,prefix,T(k(kk),1:2),sprintf('%s\\%s%d.wav',odir,opref,kk));
end

ACC = {} ; P = {} ;
fsA = X.fs(1);
fsP = X.fs(8);
for kk=1:size(k),
ACC{kk} = extractcues([X.x{1:3}],fsA*T(k(kk),1),[0 fsA*(T(k(kk),2)-T(k(kk),1))]);
P{kk} = extractcues(X.x{8},fsP*T(k(kk),1),[0 fsP*(T(k(kk),2)-T(k(kk),1))]);
end
