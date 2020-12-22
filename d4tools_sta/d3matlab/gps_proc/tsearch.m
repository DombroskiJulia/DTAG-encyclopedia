function       [Q,R] = tsearch(eph,gps_s,posi,mdel)
%
%       [Q,R] = tsearch(eph,gps_s,posi,mdel,offs)
%     eph is the ephemeris for the period
%     posi is an estimate of the position in ecef
%     gps_s is the time of the grab in gps second-of-week
%		mdel is the clock delay for each satellite

gps_s = gps_s(:) ;
SVP = svposns(eph,gps_s,posi) ;
if isempty(SVP),
   Q = [] ; R = [] ;
   return
end
R = zeros(length(gps_s),1) ;
pos1 = zeros(length(gps_s),3) ;
tt = zeros(length(gps_s),1) ;
for ko=1:size(gps_s,1),
   [pos1(ko,:),tt(ko),R(ko)]=refineposn(squeeze(SVP(:,:,ko)),posi,mdel) ;
end

[m n] = min(R) ;
Q = [pos1(n,:) tt(n) m gps_s(n)] ;
return
