load('C:\tag_data\danuta\gs15_139aOBS.mat')
T=vertcat(OBS(:).T) ;
pos=[54.2,7.9];

kproc=[1:41 44:45 47:50 52:54 56:59];
[lat1,lon1,h1,m1,N1] = gps_posns(OBS,pos,23,kproc);T1=T(kproc,:);

kproc=[61:80] ;
[lat2,lon2,h2,m2,N2] = gps_posns(OBS,pos,29,kproc);T2=T(kproc,:);

kproc=[90:96 99:106] ;
[lat3,lon3,h3,m3,N3] = gps_posns(OBS,pos,38,kproc);T3=T(kproc,:);

kproc=[122:129] ;
[lat4,lon4,h4,m4,N4] = gps_posns(OBS,pos,46,kproc);T4=T(kproc,:);

kproc=[130:131 133:134 137] ;
[lat5,lon5,h5,m5,N5] = gps_posns(OBS,pos,56,kproc);T5=T(kproc,:);

LAT = [lat1;lat2;lat3;lat4;lat5] ;
LON = [lon1;lon2;lon3;lon4;lon5] ;
TT = [T1;T2;T3;T4;T5] ;
DN=datenum(TT) ;
D = DN-DN(1) ;
M = [TT LAT LON] ;
k = find(~isnan(LAT));
csvwrite('gs15_139aPOS.csv',M(k,:));
