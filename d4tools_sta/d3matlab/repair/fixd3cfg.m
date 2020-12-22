function fixd3cfg(badfile,goodfile)
%
% fixd3cfg(badfile,goodfile)
%  Find and repair errors in the configuration section of 'badfile' using
%  'goodfile' as a template.
%

fb = fopen(badfile,'rb') ;
fg = fopen(goodfile,'rb') ;

% skip the d3 header and first block header - these should be ok
db=fread(fb,64,'uchar') ;
dg=fread(fg,64,'uchar') ;
b = db ;
nerrs = 0 ;
if isempty(db) || isempty(dg), return, end

chnk = 1 ;
while(1),
   % read the next chunk header
   db=fread(fb,18,'uchar') ;
   dg=fread(fg,18,'uchar') ;
   if isempty(db) || isempty(dg), break, end
   dbw=db(1:2:end)*256+db(2:2:end);
   dgw=dg(1:2:end)*256+dg(2:2:end);
   % check header crc
   if dgw(2)~=0, break, end    % end of the config chunks
   cb = crc16(dbw(1:8));
   if cb~=dbw(9),
      fprintf('crc error in chunk %d header: got %04x, should be %04x\n',chnk,dbw(9),cb) ;
      b = [b;dg] ;
      nerrs = nerrs+1 ;
   else
      b = [b;db] ;
   end

   if dgw(3)~=0,     % read the chunk data
      db=fread(fb,dbw(3)+4,'uchar') ;  % was dgw(3)+4
      dg=fread(fg,dgw(3)+4,'uchar') ;
      if isempty(db) || isempty(dg), break, end
      [c1,c2] = crc16byte2(db(1:end-4)) ;
      dbw = db(1:2:end)*256+db(2:2:end);
      if c1~=dbw(end-1) || c2~=dbw(end),
         fprintf('crc error in chunk %d data: got %04x %4x, should be %04x %04x\n',chnk,dbw(end+(-1:0)),c1,c2) ;
         b = [b;dg] ;
         nerrs = nerrs+1 ;
      else
         b = [b;db] ;
      end
   end
   chnk = chnk+1 ;
end

fclose(fb);
fclose(fg);

if nerrs>0,
   fprintf('Attempting to repair errors...') ;
   fb = fopen(badfile,'r+') ;
   fwrite(fb,b,'uchar') ;
   fclose(fb) ;
   fprintf('\ndone\n') ;
else
   fprintf('No errors found...\n') ;
end
