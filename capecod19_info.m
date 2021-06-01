%% Metadata
info = make_info(depid,'D4',depid(1:2),'jd')
info.dephist_deploy_method = 'suction cups' ;     % or 'suction cups' if on a whal
info.dephist_deploy_locality = 'Massachusetts, USA' ;
info.project_name = 'SBNMS2019' ;

info = make_info(depid,'D4',depid(1:2),'bp'); 
info.project_name = 'ONR Tag Design'; 
info.project_datetime_start = '2019/06/19'; 
info.project_datetime_end = '2019/06/29'; 
info.dephist_deploy_locality = 'Cape Cod, Massachusetts'; 
info.dephist_deploy_method = 'suction cup'; 
info.dephist_deploy_location_lat = 41.7; % the approx latitude of the tag deployment info.dephist_deploy_location_lon = -69.9; % the approx longitude of the tag deployment