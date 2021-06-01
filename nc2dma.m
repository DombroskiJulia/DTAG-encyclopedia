%%GETTING FROM .NC FILE TO _DMA.txt %
%
%This script leads you step by step to generate a _dma.txt file (Trackplot)
%from a .nc file. This is basicaly a modified version of prh2dma
%
%Dombroski, J.
% dombroski.julia@gmail.com
%Last modified: Feb 01, 2020.
%%
depid = 'ea18_202b' 
recdir=['D:\SRW2018\data\ea18\ea18_202b\processed\'];
load_nc('D:\SRW2018\data\ea18\ea18_202b\processed\ea18_202bsens5.nc') %load the nc file you will need. 
outputFile = 'D:\SRW2018\data\ea18\ea18_202b\processed\ea18_202b_dma.txt';    % Give matlab the "address" and name of the dma file. Don't forget the .txt otherwise it will create something wierd that crashes you oc (been there, done that). Edit as needed

dep = P.data; %dep correponds to depth. That will be P.data (data section inside the P structure)
m1=Mw.data(:,1); %m1 is magnetometer x axis. That´s the first colunm of data inside M structure. The rest follows the same pattern
m2=Mw.data(:,2);
m3=Mw.data(:,3);
a1=Aw.data(:,1);
a2=Aw.data(:,2);
a3=Aw.data(:,3);
nrec= [dep m1 m2 m3 a1 a2 a3]; 

% Open/create output file for writing
fidOut = fopen(outputFile,'w');  %opening the file that we will write on
% Write header line
fprintf(fidOut,'nRec %d\n',length(dep));
fprintf(fidOut,'dep \tmx \tmy \tmz \tax \tay \taz\n');

%setting up matrix. for each value in dep we will have a line, lines are
%being populated with M and A values. 
for i = 1:length(dep)
fprintf(fidOut, '%5.3f  \t%5.3f  \t%5.3f  \t%5.3f  \t%5.3f  \t%5.3f  \t%5.3f \n', dep(i),m1(i),m2(i),m3(i),a1(i), a2(i), a3(i));
end
fclose(fidOut); %closing the file. Very important step, don't skip it. 
    