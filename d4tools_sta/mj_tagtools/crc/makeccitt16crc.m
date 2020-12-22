function    C = makeccitt16crc(V)
%
%     C = makeccitt16crc(V)
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

for k=1:length(V),
   kk = bitand(bitxor(V(k),floor(C*rshft)),255)+1 ;
   C = bitxor(bitshift(C,8,16),F(kk)) ;
end
