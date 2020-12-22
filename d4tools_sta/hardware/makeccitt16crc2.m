function    C = makeccitt16crc2(V)
%
%     C = makeccitt16crc2(V)
%     Compute the 16 bit CCITT cyclic redundancy code for a vector V
%     using the lookup table method.
%     Based on Eric Johnson, NMSU report
%     Tested against CRC generators on the web
%
%     Example:
%     v = hex2dec(['12';'34';'56';'78';'9a';'bc';'ef';'01';'23';'45']) ;
%     makeccitt16crc(v(1:4)) ;      % should be 12524 (0x30ec)
%     makeccitt16crc(v) ;           % should be 24312 (0x5ef8)
%
%     mark johnson
%     30 January 2008

F = makeccitt16tab ;
C = 65535 ;                 % initial CRC value
rshft = 2^(-8) ;

for k=1:2:length(V),
   k1 = bitand(bitxor(V(k),floor(C*rshft)),255)+1 ;
   k2 = bitxor(bitxor(V(k+1),bitand(C,255)),floor(F(k1)*rshft))+1 ;
   C = bitxor(F(k2),bitshift(bitand(F(k1),255),8,16)) ;
end
