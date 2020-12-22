dd = datevec(datenum(TAGON')+CUETAB(:,2)/24/3600) ;
for k=1:size(dd,1),
   dn = sprintf('%s%4d%02d%02d_%02d%02d%02d_%03d.wav',tag(1:2),...
      dd(k,1:5),floor(dd(k,6)),round(1000*(dd(k,6)-floor(dd(k,6)))))
end
