function    buff = fixcrc(buff,nstart)
%
%    buff = fixcrc(buff)
%
crc = makeccitt16crc(buff(1:length(buff)-2)) ;
if(crc == buff(end+[-1 0])*[256;1])
   fprintf(' no error\n');
   return
end
%msk = 2.^(0:7) ;
msk = 1:255;
for k=nstart:length(buff),
   for kk=1:length(msk),
      buff(k) = bitxor(buff(k),msk(kk)) ;
      crc = makeccitt16crc(buff(1:length(buff)-2)) ;
      if(crc == buff(end+[-1 0])*[256;1])
         fprintf(' got it %d:%d\n',k,kk);
         return
      end
      buff(k) = bitxor(buff(k),msk(kk)) ;
   end
end

