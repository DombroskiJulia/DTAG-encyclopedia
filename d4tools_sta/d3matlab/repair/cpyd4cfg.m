function cpyd4cfg(badfile,goodfile)
%
% fixd4cfg(badfile,goodfile)
%  Add the configuration section from 'goodfile' to the start
%  of 'badfile' to repair a fragment.
%

fb = fopen([badfile '.dtg'],'rb') ;
fg = fopen([goodfile '.dtg'],'rb') ;
fw = fopen([badfile '_rep.dtg'],'wb') ;
nhdr = 40+20*2 ;  % 40 bytes d4 header + 2 repeats of 20 byte block header

% copy the d3 header and first block header - these should be ok
db=fread(fb,nhdr,'uchar') ;
dg=fread(fg,nhdr,'uchar') ;
if isempty(db) || isempty(dg), return, end
fwrite(fw,db,'uchar') ;

% find the config chunks in goodfile and copy them
chnk = 1 ;
while(1),
   % read the next chunk header
   dg=fread(fg,20,'uchar') ;
   if isempty(dg), break, end
   dgw=dg(1:2:end)*256+dg(2:2:end);
   if dgw(2)~=0,     % non configuration chunk
      break ;
   end
   if dgw(3)~=0,     % read the chunk data
      dgd=fread(fg,dgw(3),'uchar') ;
   end
   fwrite(fw,dg,'uchar') ;
   fwrite(fw,dgd,'uchar') ;
end

fclose(fg);

% find the first chunk header in badfile
n = [0 0] ;
while(1),
   % read the next chunk header
   n(2)=fread(fb,1,'uchar') ;
   if all(n==[169 82]),
      break ;
   end
   n(1) = n(2) ;
end

fwrite(fw,dg(1:2),'uchar') ;

% and copy from here on
fprintf('Copying 000 MB')
MB=0 ;
while 1,
   MB = MB+1 ;
   fprintf('\b\b\b\b\b\b%03d MB',MB);
   d=fread(fb,1048576,'uchar') ;
   if isempty(d), break, end
   fwrite(fw,d,'uchar') ;
end

fprintf('\ndone\n') ;
fclose(fb);
fclose(fw);
