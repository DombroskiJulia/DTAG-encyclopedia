function       [C1,C2] = crc16byte2(V)

%     [C1,C2] = crc16byte2(V)
%     Compute the double 16 bit CCITT cyclic redundancy code for an
%     interleaved vector V of 8-bit data using the lookup table method.
%     Each entry in V must be between 0 and 255. This function mimics the
%     data crc used in version 3 dtg files.
%
%     Based on 'High-speed computation of cyclic redundancy checks'
%     Eric E. Johnson, Report NMSU-ECE-95-011, New Mexico State
%     University, 1995.
%
%     GNU General Public License, see README.txt
%     mark johnson, SOI / Univ. St. Andrews
%     mj26@st-andrews.ac.uk
%     April 2015

F = makeccitt16tab ;        % make the lookup table
C1 = 65535 ;                 % initial CRC value
C2 = 65535 ;                 % initial CRC value
rshft = 2^(-8) ;            % use multiply to do a right shift

% deinterleave V
V1 = V(1:2:end) ;
V2 = V(2:2:end) ;

% calculate the CRC over the data bytes
for k=1:length(V1),
   kk = bitand(bitxor(V1(k),floor(C1*rshft)),255)+1 ;
   C1 = bitxor(bitshift(C1,8,16),F(kk)) ;
end
for k=1:length(V2),
   kk = bitand(bitxor(V2(k),floor(C2*rshft)),255)+1 ;
   C2 = bitxor(bitshift(C2,8,16),F(kk)) ;
end
