% LLA2ECEF - convert latitude, longitude, and altitude to
%            earth-centered, earth-fixed (ECEF) cartesian
% 
% USAGE:
% ECEF = lla2ecef(LLA)
% 
% x = ECEF X-coordinate (m)
% y = ECEF Y-coordinate (m)
% z = ECEF Z-coordinate (m)
% LLA = [lat,lon,alt]
%  lat = geodetic latitude (radians)
%  lon = longitude (radians)
%  alt = height above WGS84 ellipsoid (m)
% ECEF = [x,y,z]
%  x = ECEF X-coordinate (m)
%  y = ECEF Y-coordinate (m)
%  z = ECEF Z-coordinate (m)
%
% Notes: This function assumes the WGS84 model.
%        Latitude is customary geodetic (not geocentric).
% 
% Source: "Department of Defense World Geodetic System 1984"
%         Page 4-4
%         National Imagery and Mapping Agency
%         Last updated June, 2004
%         NIMA TR8350.2
% 
% Michael Kleder, July 2005
%
%  mj checked it against Example 14.3 pg 470 of Strang and Borre
%  results agree to a few centimeters.
%
function ECEF=lla2ecef(LLA)

lat = LLA(:,1) ;
lon = LLA(:,2) ;
alt = LLA(:,3) ;

% WGS84 ellipsoid constants:
a = 6378137;
e = 8.1819190842622e-2;

% intermediate calculation
% (prime vertical radius of curvature)
N = a ./ sqrt(1 - e^2 .* sin(lat).^2);

% results:
x = (N+alt) .* cos(lat) .* cos(lon);
y = (N+alt) .* cos(lat) .* sin(lon);
z = ((1-e^2) .* N + alt) .* sin(lat);
ECEF = [x,y,z] ;
return