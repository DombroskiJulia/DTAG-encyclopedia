function			find_start_point(OBS,latr,longr,tc,THR)

%			find_start_point(OBS,latr,longr,tc)
%			OBS is a pseudo-range observation resulting from d3preprocgps.
%			  OBS should have at least 6 SVs with received level over 200.
%			latr is a range of latitudes over which to search, in degrees.
%			longr is a range of longitudes over which to search, in degrees.
%			tc is a range of time errors to search over, in seconds.
%
%			Example:
%			find_start_point(OBS(18),[-50 -44],[62 68],[-20 20]);

if nargin<5,
   THR = 200 ;
end
[latc,longc] = meshgrid(min(latr):max(latr),min(longr):max(longr)) ;
E = zeros(size(latc,1)*size(latc,2),1) ;
figure(1),clf,hold on,grid on
axis([min(longr)-0.5 max(longr)+0.5 min(latr)-0.5 max(latr)+0.5])
caxis([1 5])
colorbar

for k=1:length(E),
	[tt,E(k)] = gps_timesearch(OBS,[latc(k),longc(k)],tc,THR,[],1) ;
	if isnan(E(k)),
		scatter(longc(k),latc(k),100,5)
	else
		scatter(longc(k),latc(k),100,log10(E(k)),'filled')
	end
	caxis([1 5])
	drawnow
end
[m,k] = nanmin(E) ;
fprintf('Best fit at latitude %d, longitude %d with %d m RMS error\n',latc(k),longc(k),round(m))
