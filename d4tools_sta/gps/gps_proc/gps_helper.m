

d3preprocgps(recdir,prefix,'bin') ;
OBS = d3combineobs(recdir,prefix) ;

pos=[56.7 8.8];		% rough starting point for Limfjord
pos=[54.4 8.7];		% rough starting point for Husum

[POS,N,gps] = gps_posns(OBS,pos,0,200);
save(['/tag_data/metadata/gps/' prefix 'trk.mat'],'gps','POS','N') ;

plot(POS.lon,POS.lat,'g.-'),grid
plot_google_map('MapType','hybrid')
