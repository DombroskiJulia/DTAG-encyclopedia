F=dir('C:\tag\projects\d4\code\d4usb_v10\Debug\seg*.txt');
for k=1:length(F),
   fprintf('%s\n',F(k).name) ;
   X=csvread(['C:\tag\projects\d4\code\d4usb_v10\Debug\' F(k).name]);
   X(X<0) = X(X<0)+65536 ;
   X = reshape(X,[],2);
   kk=find(X(1:256,1)~=X(1:256,2)) ;
   for kkk=1:length(kk),
      fprintf(' %d: %04x %04x\n',kk(kkk)-1,X(kk(kkk),1),X(kk(kkk),2));
   end
   %check crc on ecc
   for kk=1:2,
      xx=X(256+(1:14),kk)' ;
      xx(2,:)=rem(xx(1,:),256);
      xx(1,:)=floor(xx(1,:)/256);
      xx=reshape(xx,[],1);
      crc1 = makeccitt16crc(xx(1:12));
      crc2 = makeccitt16crc(xx(15:26));
      cerr(kk,:) = X(256+[7 14]) ~= [crc1 crc2] ;
   end
   kk = find(cerr(:)==0,1);
   if isempty(kk),
      fprintf(' no good ecc') ;
   end
   switch kk
      case 1
         ecc = X(256+(2:6),1) ;
      case 2
         ecc = X(256+(2:6),2) ;
      case 3
         ecc = X(256+7+(1:5),1) ;
      case 4
         ecc = X(256+7+(1:5),2) ;
   end
   if any(ecc~=X(256+14+(1:5),1)),
      fprintf(' ecc mismatch col 1\n');
   end
   if any(ecc~=X(256+14+(1:5),2)),
      fprintf(' ecc mismatch col 2\n');
   end
end
