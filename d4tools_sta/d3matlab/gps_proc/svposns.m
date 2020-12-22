function    P = svposns(SVPOS,tow,pos,lla)
%
%     P = svposns(SVPOS,tow,pos,lla)
%     Computes the position of each space vehicle in the 
%     list SV at GPS times of week tow. The range, Doppler
%     azimuth and elevation of each SV with respect to a receiving
%     position pos=[lat long alt] are also given. Lat and lon are
%     in degrees. Alt is in m above the reference geoid.
%     P is a nx8xt matrix containing (n=number of SVs,
%     t is the number of times):
%     P(sv,:,t) = [x y z range doppler azimuth elevation clkerr]
%     All distances are in meters, doppler in Hz and angles
%     in radians. clkerr is in seconds.
%

DOPP_SCF = 1575.42e6/3e8 ;
if nargin==4,
   % convert lat and lon to radians
   lla(1:2) = lla(1:2)*pi/180 ;     

   % convert to ECEF
   pos = lla2ecef(lla(:)') ;
end

[GD,GC,Q]=ecef2azel(pos) ;
rnorth = Q(:,1); reast = Q(:,2) ; rup = Q(:,3) ;

P = NaN*zeros(length(SVPOS),8,length(tow)) ;
for kk=1:length(SVPOS),
   pp = SVPOS{kk} ;
   if isempty(pp), continue, end
	if all(tow<min(pp(:,1))-3e5),
		tow = tow+604800 ;
	end
		
   pint = 1000*interp1(pp(:,1),pp(:,2:4),tow) ;   % ECEF coords of satellite k at tow
   if any(isnan(pint)), continue, end
   [r,V] = rotrange(pint,pos) ;
   Vm = 1000*interp1(pp(:,1),pp(:,2:4),tow-0.5) ;   % ECEF coords of SV(k) at TIME-0.5s
   rm = rotrange(Vm,pos) ;
   Vp = 1000*interp1(pp(:,1),pp(:,2:4),tow+0.5) ;   % ECEF coords of satellite k at TIME+0.5s
   rp = rotrange(Vp,pos) ;
   dopp = DOPP_SCF*(rp-rm) ;    % doppler shift in Hz 
   el = pi/2-acos(V*rup) ;         % elevation of SV wrt to LTP
   az = atan2(V*reast,V*rnorth) ;  % azimuth of SV wrt to LTP
   clkerr = 1e-6*interp1(pp(:,1),pp(:,5),tow) ;   % clkerr of satellite k at tow
   P(kk,:,:) = [pint,r,dopp,az,el,clkerr]' ;
end

% remove third dimension of P if there is only one time
P = squeeze(P) ;
return
