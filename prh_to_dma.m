% Adjustable parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prhFile = 'C:\my_prh_filename';       % Edit as needed (no extension)
outputFile = 'C:\cware\pwxx_dma.txt';    % Edit as needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load prhFile;

dep = p;
m1=Mw(:,1);
m2=Mw(:,2);
m3=Mw(:,3);
a1=Aw(:,1);
a2=Aw(:,2);
a3=Aw(:,3);
nrec= [dep m1 m2 m3 a1 a2 a3]; 

% Open/create output file for writing
fidOut = fopen(outputFile,'w'); 
% Write header line
fprintf(fidOut,'nRec %d\n',length(dep));
fprintf(fidOut,'dep \tmx \tmy \tmz \tax \tay \taz\n');

for i = 1:length(dep)
fprintf(fidOut, '%5.3f  \t%5.3f  \t%5.3f  \t%5.3f  \t%5.3f  \t%5.3f  \t%5.3f \n', dep(i),m1(i),m2(i),m3(i),a1(i), a2(i), a3(i));
end

fclose(fidOut);
    