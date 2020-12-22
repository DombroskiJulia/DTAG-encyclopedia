function		d4fileappend(file1,file2)

%  d4fileappend(file1,file2)
%  Add file2 to the end of file1 and adjust the header of the composite file.
%  Both files must be valid d4 files.
%

% DTAG 4.0 dtg file header is:
%	<DTAG 4.0 (8)> <host code ver (2)> <UTC time (4)> <device type (2)>
%	<device code ver (2)> <sectorsize (2)> <eraseunit (2)> <device UID (4)>	
%  <startlocation (4)> <endlocation (4)> <nsectors (4)> <CRC16 (2)>
%	TOTAL = 40 bytes

f1 = fopen(file1,'rb') ;
f2 = fopen(file2,'rb') ;

% read the d4 headers
hdr1=fread(f1,40,'uchar') ;
hdr2=fread(f2,40,'uchar') ;

if strcmp(char(hdr1(1:8)'),'DTAG 4.0')==0 || strcmp(char(hdr2(1:8)'),'DTAG 4.0')==0,
	fprintf('One or more input files is not a valid D4 file\n')
	fclose(f1)
	fclose(f2)
	return
end	

% add the 2nd file blocks to the first file header
% need to adjust the endlocation (31:34) and nsectors (35:38)
fprintf('Adjusting file header\n');
hdr1(31:34) = hdr2(31:34) ;
nsecs = hdr1(35:38)'*[256^3;256^2;256;1] ;   % file1 sector count
nsecs = nsecs+hdr2(35:38)'*[256^3;256^2;256;1] ;   % new sector count

hdr1(38) = bitand(nsecs,255) ;
nsecs = floor(nsecs/256) ;
hdr1(37) = bitand(nsecs,255) ;
nsecs = floor(nsecs/256) ;
hdr1(36) = bitand(nsecs,255) ;
nsecs = floor(nsecs/256) ;
hdr1(35) = bitand(nsecs,255) ;
c = crc16hdr(hdr1(1:38)) ;
hdr1(39:40) = [floor(c/256) bitand(c,255)] ;

fprintf('%02x ',hdr1(1:20));
fprintf('\n');
fprintf('%02x ',hdr1(21:40));
fprintf('\n');

fclose(f1) ;
f1 = fopen(file1,'r+') ;
fwrite(f1,hdr1,'uchar') ;
fseek(f1,-2,1) ;           % go to the end of the first file minus the termination word

% now loop through appending 2nd file
fprintf('Appending file...\n') ;
N = 1000000 ;
while(1),
   x=fread(f2,N,'uchar') ;
   fwrite(f1,x,'uchar') ;
   if length(x)<N, break, end
end

fclose(f2) ;
if any(x(end+(-1:0))~=170),
	fprintf('Adding termination...\n') ;
	fwrite(f1,[170;170],'uchar') ;
end
fclose(f1) ;
fprintf('\ndone\n') ;
