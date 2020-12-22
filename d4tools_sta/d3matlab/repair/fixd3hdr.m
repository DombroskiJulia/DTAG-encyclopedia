function fixd3hdr(badfile)
%
% fixd3hdr(badfile)
%  Find and repair errors in the header section of 'badfile'
%  This is primarily for file downloads from a tag that terminated with errors.
%

fb = fopen(badfile,'rb') ;

% read the d3 header
hdr=fread(fb,42,'uchar') ;

% read the first block header
db=fread(fb,22,'uchar') ;
if isempty(db), return, end
dbw=db(1:2:end)*256+db(2:2:end);
% check header crc
cb = crc16(dbw(1:10));
if cb~=dbw(11),
   fprintf('crc error in first block header: got %04x, should be %04x\n',dbw(11),cb) ;
   fprintf('Starting chip and block may be wrong\n') ;
end
stblk = dbw(6) ;
stchp = db(13) ;
% these should be the same as in the d3 header
if any(hdr(31:33)~=db([13 11 12])),
   fprintf('Start chip and block in d3 header may be wrong:\n') ;
   fprintf('Reported chip:block is %d:%d, First block header is %d:%d\n',...
      hdr(31),hdr(32)*256+hdr(33),stchp,stblk) ;
   s=input('Repair y/n? ','s') ;
   if lower(s)=='y',
      hdr(31:33) = db([13 11 12]) ;
   end
   fprintf('\n') ;
end

bs = db(8:10)'*[256^2;256;1] ;   % block size in bytes

% now loop through blocks in the file
nblks = 1 ;
while(1),
   fseek(fb,bs-22,0) ;
   db=fread(fb,22,'uchar') ;
   if isempty(db), break, end
   dbw=db(1:2:end)*256+db(2:2:end);
   %fprintf('%04x ',dbw);
   %fprintf('\n');
   if dbw~=23228, fprintf('Out of sequence block header - unable to repair\n'); break, end
   nblks = nblks+1 ;
end

fclose(fb) ;
if dbw~=23228, return, end

% check final block header crc
cb = crc16(dbw(1:10));
if cb~=dbw(11),
   fprintf('crc error in last block header: got %04x, should be %04x\n',dbw(11),cb) ;
   fprintf('End chip and block may be wrong\n') ;
end
edblk = dbw(8) ;
edchp = bitand(dbw(7),255) ;

% these should be the same as in the d3 header
fprintf('Found end chip and block of %d:%d, nblocks %d\n',edchp,edblk,nblks) ;
fprintf('Adjusting d3 file header\n');
hdr(34:36) = [edchp floor(edblk/256) bitand(edblk,255)] ;
hdr(40) = bitand(nblks,255) ;
nblks = floor(nblks/256) ;
hdr(39) = bitand(nblks,255) ;
nblks = floor(nblks/256) ;
hdr(38) = bitand(nblks,255) ;
nblks = floor(nblks/256) ;
hdr(37) = bitand(nblks,255) ;
c = crc16hdr(hdr(1:40)) ;
hdr(41:42) = [floor(c/256) bitand(c,255)] ;
fprintf('%02x ',hdr(1:20));
fprintf('\n');
fprintf('%02x ',hdr(21:42));
fprintf('\n');

fprintf('Attempting to repair errors...\n') ;
fb = fopen(badfile,'r+') ;
fwrite(fb,hdr,'uchar') ;

fprintf('Adding termination...\n') ;
fseek(fb,0,1) ;
fwrite(fb,[170;170],'uchar') ;
fclose(fb) ;
fprintf('\ndone\n') ;
