%%%%%%%%%%%%%%%%%%%%%%%
%%D2 Data Calibration%%
%%%%%%%%%%%%%%%%%%%%%%%

%Commands used to go through Tag2Whale steps using eg06_24a
%setting path
settagpath('audio', 'D:\DUKE Tagging\SEUS 2016_Duke tagging', 'cal', 'D:\DUKE Tagging\SEUS 2016_Duke tagging\cal','raw', 'D:\DUKE Tagging\SEUS 2016_Duke tagging\raw','prh', 'D:\DUKE Tagging\SEUS 2016_Duke tagging\prh')
%because I am working with only 1 tag for now, I'll attribute its name to tag
tag='eg16_025a';
%Generating the Cue table for this deployment
%!Attention! audio files should be in a folder named like: eg06. Inside
%eg06, there must be a folder named after the deployment (9 characters
%string)  like eg06_024a. Make sure text and wave files are named correctly
%as in eg024a01 (8 characters, no year, no extention, just sp,julien and chip) 
N=makecuetab(tag)
%saving tab to cal file
savecal(tag, 'CUETAB', N)
%enter tag on time as yy mm dd hh mm ss. You will find tag on time under
%FocalWhaleSummaries in the Datasheets folder. 
%adding location info to the call file
%finding relation between GMT and local time.
savecal('eg16_025a', 'GMT2LOC', -5)
%enter location in decimal degrees. You may use this site for convertion: https://www.fcc.gov/media/radio/dms-decimal 
savecal(tag,'TAGLOC', [30.66891, -81.26920])
%enter local declination. You may use this site to find local declination: http://www.magnetic-declination.com/ 
savecal(tag,'DECL', -6.36)
%before making the raw decimated file make sure path for raw and cal are
%correct
%reading swv files
[s, fs]=swvread(tag);
%saving it in a raw file
saveraw(tag, s, fs)
%making the frame for prh files. Make sure path for prh is set and that you have s and fs on your workspace
%read calibration files for tag. Make sure to know TagId or look for it @
%the MicrosoftAcess file under tagAttachLog
CAL=tag250
%making pressure calibration. --> follow screen directions
%a window with 2 graphs will pop. box the botton points (should correspond
%to surface) presss any key while at this window. Then click on MatLab
%window and accept (y) or reject (n) results. 
[p, tempr, CAL] = calpressure(s,CAL,'full');
%Making the Magnetometer and accelerometer calibration. Follow screen
%directions to accept or reject results. Attention to results compared to
%what is shown at the screen
[M,CAL]=autocalmag(s,CAL);
[A,CAL]=autocalacc(s,p,tempr,CAL);
%saving callibration results
savecal(tag,'CAL',CAL)
%saving tagframe results
saveprh(tag, 'p', 'tempr', 'fs', 'A', 'M')
%determining tag orientation on whale. Make sure to have all field notes
%in hand and prh path set correctly. 
loadprh(tag)
%inpect data by making plots (plot pressure to inspect pressure @ surface
%is 0)
%ATTENTION FOR THE COLOR SCHEME: BLUE=PITCH; RED=ROW; YELLOW=HEADING)
figure %figure command opens a new figure window 
plot(-p)
plot(A)
%Use prh predictor to analyse logging/diving events to estimate heading
%pitch and roll.
T=prhpredictor(p,A,fs, 7, 1, 'descent') %here mindive=7. this means that we will be looking at dives > than 7 m deep in order to estimate prh
%also, met 1 is used for animals actively swimming @ surface while met 2 is
%used for animals primarely logging @ surface. 
%for right whales in calving grounds, whales spend most of their time @
%shallow waters and make shallow dives as well. So choose dives with a good
%surface interval. It is a  good idea do call for figure before using
%phrpredictor.
%2 figures will be generated. on figure 2 you will have to estabelish
%loggind (first black square) and descending periods (second black square). Use figure 1 to obtain dive time. When you are done click on figure 2 to activate it and press any key to acept and 'x' to reject dive based on your error graph(bottom chart on Figure 1)
%a dive should look like as shown in Tagshow2
%after this process, T will have all estimate p r h were cue is time in
%samples. 
%now you should make the OTAB. if you dont suspect that the tag has moved
%use t1=t2=0, If you do suspec it moved, check t1 and t2 of segments that
%would have the same phrs and use OTAB=[t1, t2, estimatedp, estimatedr, estimatedh; t1a, t2a....]
%use mean values for p r h in aech segment
%plot Aw and Mw values to make sure they are correct.
prhmean=mean(T(:, 2:4)) 
OTAB=[0,0, prhmean]
[Aw Mw]=tag2whale(A, M, OTAB, fs); %creating whale frame acceleration
%Inspect Aw graphicaly using prhpredictor
Tw=prhpredictor(p, Aw, fs, 10, 1, 'descent')
savecal(tag, 'OTAB', OTAB) %saving orientation table
makeprhfile(tag) %making the prh file
%%Making track
%load the prhfile
loadprh(tag)
P=ptrack(pitch,head,p,fs); %estimating track using Ptrack
set(gca,'Zdir','reverse'); %I have no idea what this is... setting directory for something?

%%Loking for tag shifts in acellerometer and magnetometer data on piece at a time%%

time=(1:length(s))./fs; %making the variable 'time'. It corresponds to time in seconds. 
%Acellerometer data%
%Before setting whale frame%% 
figure
subplot (3,1,1)
plot(time/3600,A(:,1)); grid %1=X
subplot(3,1,2)
plot(time/3600,A(:,2)); grid %2=Y
subplot(3,1,3)
plot(time/3600,A(:,3)); grid %3=Z

%after setting whale frame%%

figure
subplot (3,1,1)
plot(time/3600,Aw(:,1)); grid %1=X
subplot(3,1,2)
plot(time/3600,Aw(:,2)); grid %2=Y
subplot(3,1,3)
plot(time/3600,Aw(:,3)); grid %3=Z

%Magnetometer data%
%before whale frame adjustments%
figure
subplot (3,1,1)
plot(time/3600,M(:,1)); grid %1=X
subplot(3,1,2)
plot(time/3600,M(:,2)); grid %2=Y
subplot(3,1,3)
plot(time/3600,M(:,3)); grid %3=Z

%After setting whale frame%

figure
subplot (3,1,1)
plot(time/3600,Mw(:,1)); grid %1=X
subplot(3,1,2)
plot(time/3600,Mw(:,2)); grid %2=Y
subplot(3,1,3)
plot(time/3600,Mw(:,3)); grid %3=Z













