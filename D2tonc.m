settagpath('PRH', 'F:\egprh\prhs')
depid='eg16_025a'
loadprh(depid)
info = make_info(depid,'D2',depid(1:2),'jd') ;
info.dephist_deploy_method = 'suction cup';
info.dtype_source = sprintf('%sprh%',depid,fs) ;
info.dtype_nfiles = 1 ; 
info.dtype_format = 'mat' ; 
info.device_serial = num2str(depid) ;
%info.dephist_device_datetime_start = datestr(tagon,info.dephist_device_regset) ;
P = sens_struct(p,fs,depid,'pres') ;
A = sens_struct(9.81*Aw,fs,depid,'acc') ;
M = sens_struct(Mw,fs,depid,'mag') ;
A.frame = 'animal' ; M.frame = 'animal' ;
T = sens_struct(tempr,fs,depid,'temp') ;
ncname = sprintf('%ssens%5d',depid,fs) ;
save_nc(ncname,info,P,A,M,T) ;
recdir=['E:\SEUS 2006_Duke tagging\eg06\eg06_021a'];
prefix=depid




Oroll=0;
Oheading=-0*pi/180;%pretty similar result with pitch -95 or -100 so we choose -100 as Julia and Lucia agreed on that
OTAB=[0 0 Opitch Oroll Oheading]
Opitch=0*pi/180;%pretty similar result with pitch 0 or +5 so we choose 0 as Julia and Lucia agreed on that
Oroll=0;
Oheading=-0*pi/180;%pretty similar result with pitch -95 or -100 so we choose -100 as Julia and Lucia agreed on that
OTAB=[0 0 Opitch Oroll Oheading]
[Aw,Mw]=tag2whale(A.data,M.data,OTAB,10);
[pitch,roll]=a2pr(Aw);
[head,v, incl] = m2h(Mw,Aw);
[head,v, incl] = m2h(Mw,Aw, 10);
plot(pitch)


