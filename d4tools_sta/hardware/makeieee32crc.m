function    C = makeieee32crc(V)
%
%     C = makeieee32crc(V)
%     Make a 256-element lookup table for the IEEE802.3 32 bit cyclic redundancy code
%     Based on Eric Johnson, NMSU report and RIchard Black document on the
%     web
%     Does not give the right answers!
%
%     mark johnson
%     30 January 2008

F = makeieee32crctab ;
C = 2^32-1 ;
%C = 0 ;
rshft = 2^(-24) ;

for k=1:length(V),
   kk = bitand(bitxor(V(k),floor(C*rshft)),255)+1 ;
   C = bitxor(bitshift(C,8,16),F(kk)) ;
end

% bit rev result
%B = dec2bin(C,32) ;
%C = bin2dec(fliplr(B)) ;
%C = bitcmp(C,32) ;
