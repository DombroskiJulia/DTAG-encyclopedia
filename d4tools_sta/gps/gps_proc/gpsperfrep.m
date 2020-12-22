function    R = gpsperfrep(SNR)
%
%    R = gpsperfrep(SNR)
%

d=horzcat(SNR.dev);
n200 = mean(sum(d(:,1:20)>10*log10(200))) ;
n500 = mean(sum(d(:,1:20)>10*log10(500))) ;
m=sqrt(max(d(:,1:20)-20,0));
mm = mean(sum(m))/n200 ;
sm = sum(std(m'))/n200 ;

R = [n200 n500 mm sm] ;
