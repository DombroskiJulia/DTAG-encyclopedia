load /tag/tag2/metadata/clicks/md10_146abuzzwork
bz = 14 ;
st = [100 3.2] ;
box = [36 290] ;
bz = 15 ;
st = [173 2.2] ;
box = [1 580] ;
bz = 4 ;
st = [189 1.45] ;
box = [] ;

OPTS.maxout = 3 ;
OPTS.sigma = 30 ;       % m/s2
OPTS.winsz = 0.12 ;     % m
OPTS.snr = 4 ;          % dB
OPTS.measnoise = 0.03 ; % m

[scl,R]=timeindexedechoes('md10_146a',[],BZ.clicks{bz},[-0.0005 0.015],4,[],1);
R=R{1};
d=R{1};
t=R{2};
T=R{3};
RR{1}=d;RR{2}=t;RR{3}=T;
dinc = d(2)-d(1) ;
[Sf,CR]=kalmanechotracker(RR,st,box,OPTS);
figure(1),clf
imagesc((1:size(T,2))',d,T),grid
axis xy
hold on
plot(Sf(:,1),Sf(:,4),'k')
plot(Sf(:,1),Sf(:,6),'w')
figure(2),clf
plot(Sf(:,2),Sf(:,6)),grid
hold
k = Sf(:,1) ;
plot(t(k(1:end-1)),diff(t(k))*750,'.')
figure(3),clf
plot(Sf(:,2),Sf(:,[3 5])),grid

% elusive fig1 example
d = Z.T*750 ;
t = Z.BCL ;
T = RdB' ;
RR={} ;
RR{1}=d;RR{2}=t;RR{3}=T ;
dinc = d(2)-d(1) ;
st1 = [280,1.95] ;
box1 = [189 405] ;
st2 = [428,4.57] ;
box2 = [420 433] ;
st3 = [559,1.93] ;
box3 = [455 812] ;
OPTS.maxout = 5;
OPTS.snr = 4 ;
OPTS.winsz = 0.1 ;
Sf1=kalmanechotracker(RR,st1,box1);
Sf2=kalmanechotracker(RR,st2,box2);
Sf3=kalmanechotracker(RR,st3,box3);
Sf=[Sf1;NaN*ones(1,6);Sf2;NaN*ones(1,6);Sf3] ;

figure(1),clf
imagesc((1:size(T,2))',d,T),grid
axis xy
hold on
plot(Sf(:,1),Sf(:,4),'k')
plot(Sf(:,1),Sf(:,6),'w')
figure(2),clf
plot(Sf(:,2),Sf(:,6)),grid
hold
k = Sf(:,1) ;
plot(t(k(1:end-1)),diff(t(k))*750,'.')
figure(3),clf
plot(Sf(:,2),Sf(:,[3 5])),grid
