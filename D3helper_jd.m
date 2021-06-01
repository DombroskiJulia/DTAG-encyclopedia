%D3 Processing%
%Julia Dombroski%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
settagpath('prh', 'D:\SRW2018\data\prh') %set tag path. this is where files will be saved. If you don't have the folders, make the folders at the same level as mn19, mn18 etc. within data folder.  
settagpath('cal', 'D:\SRW2018\data\cal')
gettagpath
recdir='D:\SRW2018\data\ea18\ea18_202a'; %where your unpacked files should be (swv, xml and wav)
prefix='ea18_202a'; %tag name
df=1; %decimation factor 
X=d3readswv(recdir, prefix, df);
deploy_name='ea18_202a'; %you can set deploy_name=prefix 

[CAL, D]=d3deployment(recdir, prefix, 'ea18_202a'); %looking for calibration file from each device.
%[ch_names,descr] = d3channames(X.cn)%geetin fs for sensors 
%CAL=d3findcal('53230515')

[p, CAL]=d3calpressure(X,CAL,'full'); %calibrating pressure using the "full" method" 
figure
plot(p);axis ij %plotting p to see that it looks like. 
d3loadcal('mn19_175h')
depid=prefix

d3savecal('mn19_175g', 'TAGON.POSITION', [41.6064, -69.68693333]) %insert tag on position using decimal degrees.
d3savecal('mn19_175g', 'DECLINATION', -15) %insert declination at tag on deployment. 
d3savecal('mn19_175g', 'LOCATION', 'Stellwagen') %insert deployment location

[A, CAL, fs]=d3calacc(X, CAL, 'full', 5); %calibrating A
[M, CAL]=d3calmag(X, CAL, 'full', 5); %calibrating M
d3savecal('mn19_175g', 'CAL', CAL); %Saving correction factors to deployment cal file. 

info=make_info(depid,tagtype,species,owner) %replace with adequate tag type (d2, d3), species (eg, mn), etc.  
%If make_info dosent work use %info=csv2struct(dataset) %and have the d3_templatecsv table filled and saved with a different name than the original.  
%% 
%%Converting data to work with animaltools
A=sens_struct(A,fs,info.depid,'acc');
A.frame = 'animal' ;
M=sens_struct(M,fs,info.depid,'mag');
M.frame = 'animal' ;
P=sens_struct(p,fs,info.depid,'press');
T=sens_struct(t,fs,info.depid,'temp');
if exist('POS','var'),
   POS=sens_struct(POS,T,info.depid,'pos');
   save_nc(dataset,A,M,P,POS,info) ;
else
   save_nc(dataset,A,M,P,info) ;
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%making PRH file 
min_depth=2;
PRH=prhpredictor(p, A, fs, 40, 1, 'descent')

[Aw,Mw] = tag2whale(A,M,OTAB,fs);

d3savecal(deploy_name,'OTAB',OTAB)
[Aw,Mw] = tag2whale(A,M,OTAB,fs);
d3makeprhfile(recdir, prefix, 'tm17_010a', 10)

%Making ptrack
P=ptrack(pitch, head, p, fs);
colline3(P(:,2), P(:,1), P(:,3), P(:,3)), grid;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Useful plots to observe data 
time=(1:length(p))/fs;
figure
d(1)=subplot(3,1,1)
plot(-p)
grid on
hold
d(2)=subplot(3,1,2)
plot(norm2(A), 'b');
grid on
hold
j=njerk(A, fs);
d(3)=subplot(3,1,3) 
plot(j, 'r')
grid on
linkaxes(d, 'x') %links the x axis of the plots 
hold off 


figure
plot(A)
subplot(2,1,1)
plot(A)
subplot(2,1,2)
plot(p)
axis ij

figure
plott(p, fs)
hold on
plot((1:length(p))/ fs, rad2deg(-pitch), 'r')

figure
d(1)=subplot(3,1,1)
plot((1:length(p))/ fs, -p)
hold
d(2)=subplot(3,1,2)
plot((1:length(p))/ fs, rad2deg(pitch), 'r')
linkaxes(d, 'x')
hold off 


