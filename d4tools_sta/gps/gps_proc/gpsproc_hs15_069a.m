load('C:\tag_data\danuta\hs15_069aOBS.mat')
T=vertcat(OBS(:).T) ;
pos=[54.2,7.9];

kproc=[1:26 28:34 36:58 60:72];
[lat1,lon1,h1,m1,N1] = gps_posns(OBS,pos,22,kproc);T1=T(kproc,:);

kproc=[73 75:76 81] ;
[lat2,lon2,h2,m2,N2] = gps_posns(OBS,pos,30,kproc);T2=T(kproc,:);

kproc=[83:96] ;
[lat3,lon3,h3,m3,N3] = gps_posns(OBS,pos,38,kproc);T3=T(kproc,:);

kproc=[97 102 104:110 113:117 119:153] ;
[lat4,lon4,h4,m4,N4] = gps_posns(OBS,pos,46,kproc);T4=T(kproc,:);

kproc=[154:156 158:161 163:176 178:190 192:193 197 199 201 202 205 207 209:212] ;
[lat5,lon5,h5,m5,N5] = gps_posns(OBS,pos,52,kproc);T5=T(kproc,:);

kproc=[214:219 222:224 226] ;
[lat6,lon6,h6,m6,N6] = gps_posns(OBS,pos,57,kproc);T6=T(kproc,:);

LAT = [lat1;lat2;lat3;lat4;lat5;lat6] ;
LON = [lon1;lon2;lon3;lon4;lon5;lon6] ;
TT = [T1;T2;T3;T4;T5;T6] ;
DN=datenum(TT) ;
D = DN-DN(1) ;
M = [TT LAT LON] ;
k = find(~isnan(LAT));
csvwrite('hs15_069aPOS.csv',M(k,:));
clf,scatter(LON,LAT,14,D,'filled'),grid
