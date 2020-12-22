function    R = gpsperfrep(SNR)
%
%    R = gpsperfrep(SNR)
%

if isstruct(SNR),
   d=horzcat(SNR.dev);
else
   d=SNR' ;
end

N = min(size(d,2),20);
n200 = mean(sum(d(:,1:N)>10*log10(200))) ;
n500 = mean(sum(d(:,1:N)>10*log10(500))) ;
m=sqrt(max(d(:,1:N)-20,0));
mm = mean(sum(m))/n200 ;
sm = sum(std(m'))/n200 ;

R = [n200 n500 mm sm] ;
