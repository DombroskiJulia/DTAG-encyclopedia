function		d4cpycfg(file1,file2)

%  d4cpycfg(file1,file2)
%  Copy the configuration chunks from file2 to the start of file1.
%  Both files must be valid d4 files. This is used to add configuration
%  chunks to a file that doesn't have any. The result is put into a
%	new file called the same as file1 but with _repair.dtg at the end of
%	the name.
%

% DTAG 4.0 dtg file header is:
%	<DTAG 4.0 (8)> <host code ver (2)> <UTC time (4)> <device type (2)>
%	<device code ver (2)> <sectorsize (2)> <eraseunit (2)> <device UID (4)>	
%  <startlocation (4)> <endlocation (4)> <nsectors (4)> <CRC16 (2)>
%	TOTAL = 40 bytes

CHNK_MAGIC = 43346 ;       % 0xA952 in decimal
f1 = fopen(file1,'rb') ;
f2 = fopen(file2,'rb') ;
ofilename = [file1(1:find(file1=='.',1)-1) '_repair.dtg'] ;

% read the d4 headers and first block headers
hdr1=fread(f1,80,'uchar') ;
hdr2=fread(f2,80,'uchar') ;

if strcmp(char(hdr1(1:8)'),'DTAG 4.0')==0 || strcmp(char(hdr2(1:8)'),'DTAG 4.0')==0,
	fprintf('One or more input files is not a valid D4 file\n')
	fclose(f1)
	fclose(f2)
	return
end	

fprintf('Appending configurations...\n');
fo = fopen(ofilename,'wb') ;
fwrite(fo,hdr1,'uchar') ;

% add the 2nd file config chunks after the first file header
chnk = 1 ;
while(1),
   % read the next chunk header
   dg=fread(f2,20,'uchar') ;
   if isempty(dg), break, end
   dgw=dg(1:2:end)*256+dg(2:2:end);
   if dgw(1) ~= CHNK_MAGIC, break, end
   if dgw(2) ~= 0, break, end    % end of the config chunks
   fwrite(fo,dg,'uchar') ;
   
   if dgw(3)~=0,     % read the chunk data
      dg=fread(f2,dgw(3),'uchar') ;
      if isempty(dg), break, end
      fwrite(fo,dg,'uchar') ;
   end
   chnk = chnk+1 ;
end

fclose(f2) ;

% now loop through appending 1st file
fprintf('Appending file...\n') ;
N = 1000000 ;
while(1),
   x=fread(f1,N,'uchar') ;
   fwrite(fo,x,'uchar') ;
   if length(x)<N, break, end
end

fclose(f1) ;
if any(x(end+(-1:0))~=170),
	fprintf('Adding termination...\n') ;
	fwrite(fo,[170;170],'uchar') ;
end
fclose(fo) ;
fprintf('\ndone\n') ;
