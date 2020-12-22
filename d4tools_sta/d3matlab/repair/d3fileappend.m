function d3fileappend(file1,file2)
%
%  d3fileappend(file1,file2)
%  Add file2 to the end of file1 and adjust the header of the composite file.
%  Both files must be valid d3 files.
%

f1 = fopen(file1,'rb') ;
f2 = fopen(file2,'rb') ;

% read the d3 headers
hdr1=fread(f1,42,'uchar') ;
hdr2=fread(f2,42,'uchar') ;

% add the 2nd file blocks to the first file header
fprintf('Adjusting d3 file header\n');
hdr1(34:36) = hdr2(34:36) ;
nblks = hdr1(37:40)'*[256^3;256^2;256;1] ;   % file1 block count
nblks = nblks+hdr2(37:40)'*[256^3;256^2;256;1] ;   % new block count

hdr1(40) = bitand(nblks,255) ;
nblks = floor(nblks/256) ;
hdr1(39) = bitand(nblks,255) ;
nblks = floor(nblks/256) ;
hdr1(38) = bitand(nblks,255) ;
nblks = floor(nblks/256) ;
hdr1(37) = bitand(nblks,255) ;
c = crc16hdr(hdr1(1:40)) ;
hdr1(41:42) = [floor(c/256) bitand(c,255)] ;

fprintf('%02x ',hdr1(1:20));
fprintf('\n');
fprintf('%02x ',hdr1(21:42));
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
fprintf('Adding termination...\n') ;
fwrite(f1,[170;170],'uchar') ;
fclose(f1) ;
fprintf('\ndone\n') ;
