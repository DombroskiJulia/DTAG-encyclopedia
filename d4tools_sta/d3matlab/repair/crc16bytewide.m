function       C = crc16bytewide(V)

%     C = crc16bytewide(V)
%     Compute the 16 bit CCITT cyclic redundancy code for a vector V
%     of 8-bit data using the lookup table method.
%     Each entry in V must be between 0 and 255.
%
%     Based on 'High-speed computation of cyclic redundancy checks'
%     Eric E. Johnson, Report NMSU-ECE-95-011, New Mexico State
%     University, 1995.
%     Tested against CRC generators on the web
%
%     Example:
%     v = hex2dec(['12';'34';'56';'78';'9a';'bc';'ef';'01';'23';'45']) ;
%     crc16bytewide(v)           % should be 24312 (0x5ef8)
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     November 2012

F = makeccitt16tab ;        % make the lookup table
C = 65535 ;                 % initial CRC value
rshft = 2^(-8) ;            % use multiply to do a right shift
V = V(:) ;

% calculate the CRC over the data bytes
for k=1:length(V),
   kk = bitand(bitxor(V(k),floor(C*rshft)),255)+1 ;
   C = bitxor(bitshift(C,8,16),F(kk)) ;
end
