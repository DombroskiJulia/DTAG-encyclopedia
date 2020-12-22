function bindiff(fname1,fname2)
%
% bindiff(fname1,fname2)
%
NERRS = 100 ;
f1 = fopen(fname1,'rb') ;
f2 = fopen(fname2,'rb') ;
n = 0 ;
ne = 0 ;
nbe = 0 ;
while(1),
   d1=fread(f1,256,'uchar') ;
   d2=fread(f2,256,'uchar') ;
   if isempty(d1) | isempty(d2), break, end
   if length(d1)<length(d2),
      d2 = d2(1:length(d1));
   end
   if length(d2)<length(d1),
      d1 = d1(1:length(d2));
   end
   k=find(d1~=d2) ;
   if ~isempty(k),
      for kk=k',
         z = bitxor(d1(kk),d2(kk)) ;
         be = 0 ;
         while(z~=0),
            be = be+bitand(z,1);
            z = bitshift(z,-1);
         end
         nbe = nbe+be ;
         ne = ne+1 ;
         fprintf('%08x: %02x %02x, %d be\n',n*256+kk-1,d1(kk),d2(kk),be) ;
      end
   end
   n = n+1 ;
   if ne>NERRS, break, end
end
fclose(f1);
fclose(f2);
fprintf('Total differences: %d bytes, %d bits\n',ne,nbe);
