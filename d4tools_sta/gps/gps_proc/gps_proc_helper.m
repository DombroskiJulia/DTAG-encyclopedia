%d3preprocgps('f:/hs16/hs16_265b','hs16_265b');
OBS=d3combineobs('C:\tag_data\gps','hs16_265b');
pos=[54.4 8.7];
[lat,lon,h,t,N] = gps_posns(OBS,pos,0);
k=find(h>-100 & h<200 & N(:,4)<200);
plot(lon(k),lat(k),'.-'),grid
%axis([7.5 9 54.25 54.75])
plot_google_map('MapType','hybrid')
