% bad ecc examples
%   000e a8c0 eb7d 4dfb f870 de55 8557
%   000e 28c0 eb7d 4dfb f878 de55 8557
PAR1=[0 14 168 192 235 125 77 251 248 112 222 85 34135] ;
PAR2=[0 14 40 192 235 125 77 251 248 120 222 85 34135] ;
   % PAR=[PAR2(1:3) PAR1(4:12)] is correct
   
%   000d 8f14 97eb f400 15cf 85ad f6ee
%   001d 8f14 97eb f400 11cf 85ad f6ee
PAR1=[0 13 143 20 151 235 244 0 21 207 133 173 63214] ;
PAR2=[0 13 143 20 151 235 244 0 17 207 133 173 63214] ;
   % PAR2 is correct after fixing seg num

%   000f 9517 036d bf4c d400 3940 efff
%   000f 9517 036d bf4c 5400 3940 ffff
PAR1 = [0 15 149 23 3 109 191 76 212 0 57 64 61439] ;
PAR2 = [0 15 149 23 3 109 191 76 84 0 57 64 65535] ;
   % PAR1 is correct with crc of PAR2

%   0001 f0cd abde 6d2b 3623 ed0b 043a
%   0001 f0cd abde 6d03 3623 ed0b 043a
PAR1 = [0 1 240 205 171 222 109 43 54 35 237 11 1082] ;
PAR2 = [0 1 240 205 171 222 109 3 54 35 237 11 1082] ;
   % PAR1 is correct with byte 7 == b instead of 2b
   
% below is a really bad one - 6 bit differences
%   000f 133c 799d 2baf 8550 f153 3de0
%   000f 0b3c 789d 2baf 8551 f1d3 7df0

