function			find_start_point(OBS,latr,longr,tc,THR)

%			find_start_point(OBS,latr,longr,tc)
%			OBS is a structure containing one or more pseudo-range observations 
%			from d3preprocgps. This function searches in OBS for the first
%		   grab with at least 6 SVs with received level over 200 (or the
%			user defined threshold). It then performs a 1x1 degree grid 
%			search over the requested latitude and longitude range to determine
%			if there is a time value within a user-defined range for which a
%			GPS position can be determined
%			latr = [min_lat,max_lat] is a range of latitudes over which to 
%			 search, in degrees.
%			longr = [min_long,max_long] is a range of longitudes over which to 
%			 search, in degrees.
%			tc = [min_t,max_t] is a range of time errors to search over, in seconds.
%			THR is an optional SV magnitude threshold. Default value is 200.
%
%			Example:
%			find_start_point(OBS,[-50 -44],[62 68],[-20 20]);
%
%			markjohnson@st-andrews.ac.uk
%			8 March 2018

if nargin<4,
	help find_start_point
	return
end
	
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
