function    [GD,GC,Q]=ecef2azel(pos)
%
%  [GD,GC,Q]=ecef2azel(pos)
%

Fsq = (6356752.3/6378137)^2 ;   % squared ratio of the minor to major axes of the earth

az = atan2(pos(2),pos(1)) ;                     % azimuth of position in ECEF
elgc = atan(pos(3)/sqrt(pos(1:2).^2*[1;1])) ;   % geocentric latitude
el = atan(1/Fsq*tan(elgc)) ;                      % geodetic latitude
reast = [-sin(az);cos(az);0] ;
rnorth = [-sin(el)*[cos(az);sin(az)];cos(el)] ;
rup = pos'/norm(pos) ;
GD = [az el] ;
GC = [az elgc] ;
Q = [rnorth reast rup] ;
