y=(lat-nanmean(lat))*1852*60;
x=(lon-nanmean(lon))*1852*60.*cos(lat*pi/180);
X=[x y] ;
Xt=trimoutliers(X(~isnan(x),:),1) ;
Xt=Xt(~any(isnan(Xt),2),:) ;
Xt=detrend(Xt,0) ;
[V,D]=eig(Xt'*Xt/size(Xt,1)) ;
R=Xt*V ;
[std(R(:,1)) std(R(:,2))]
[iqr(R(:,1)) iqr(R(:,2))]
