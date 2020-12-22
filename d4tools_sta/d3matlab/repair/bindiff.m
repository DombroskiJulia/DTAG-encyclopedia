function bindiff(fname1,fname2)
%
%
%
NERRS = 100 ;
f1 = fopen(fname1,'rb') ;
f2 = fopen(fname2,'rb') ;
n = 0 ;
ne = 0 ;
while(1),
   d1=fread(f1,256,'uchar') ;
   d2=fread(f2,256,'uchar') ;
   if isempty(d1) | isempty(d2), break, end
   k=find(d1~=d2) ;
   if ~isempty(k),
      for kk=k',
         fprintf('%08x: %02x %02x\n',n*256+kk,d1(kk),d2(kk)) ;
      end
      ne = ne+1 ;
   end
   n = n+1 ;
   if ne>NERRS, break, end
end
fclose(f1);
fclose(f2);
