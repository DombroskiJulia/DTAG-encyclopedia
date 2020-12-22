function    F = makeieee32crctab
%
%      F = makeieee32crctab
%     Make a 256-element lookup table for the IEEE802.3 32 bit cyclic redundancy code
%     Based on Eric Johnson, NMSU report and RIchard Black document on the
%     web.
%     Produces the table in the Eric Johnson report.
%

% generator polynomial
G = hex2dec('4c11db7') ;

% compute the table entries
F = zeros(256,1) ;
for k=1:256,
   f = bitshift(k-1,24,32) ;
   for kk=1:8,
      if bitget(f,32) 
         f = bitshift(f,1,32) ;
         f = bitxor(f,G) ;
      else
         f = bitshift(f,1,32) ;
      end
   end
   % bit rev result
   %B = dec2bin(f,32) ;
   %F(k) = bin2dec(fliplr(B)) ;
   F(k) = f ;
end
