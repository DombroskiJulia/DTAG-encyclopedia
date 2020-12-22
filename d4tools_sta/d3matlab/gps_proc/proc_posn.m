function    POS = proc_posn(P,pos,T,eph,tc,THR,silent)
%
%    POS = proc_posn(P,pos,T,eph,tc,THR,silent)
%     P is a three-column matrix resulting from cross-correlation of GPS
%     grabs: [sv,snr,delay].
%     pos is a starting estimate of the position [latitude,longitude]
%     T is a starting estimate of the grab time in UTC
%     eph is the ephemeris for the period
%     tc is a time correction in seconds

if nargin<6 || isempty(THR),
   THR = 150 ;
end

if nargin<7,
   silent = 0 ;
end

offs1 = -5:0.2:5 ;
offs2 = -0.5:0.02:0.5 ;
offs3 = -0.05:0.001:0.05 ;
maxdev = 10 ;     % maximum deviation in seconds from nominal
QQ = zeros(1,7) ;
L = zeros(1,10) ;
POS = [] ;

T = datevec(datenum(T)+tc/(24*3600)) ;
tcin = tc ;
tc = 0 ;
tgps = utc2gps(T) ;
sgps = tgps(2) ;        % GPS second of week
ecef_pos = lla2ecef([pos*pi/180 0]) ;
SVP = svposns(eph,sgps,ecef_pos) ;
if isempty(SVP),return, end
ksv = find(P(:,2)>THR & SVP(P(:,1),8)<0.002) ;
if length(ksv)<4,return, end
eph = {eph{ksv}} ;

mdel = P(ksv,3) ;
[Q,R] = tsearch(eph,sgps+offs1,ecef_pos,mdel) ;
if isempty(Q),return, end

if silent==0,
   figure(1)
   plot(offs1,R),grid on,hold on
end
tc = tc+interpmin(offs1,R) ;
if abs(tc)>maxdev,return, end

[Q,R] = tsearch(eph,sgps+tc+offs2,ecef_pos,mdel) ;
if isempty(Q), return, end
tc = tc+interpmin(offs2,R) ;
if abs(tc)>maxdev,return, end

[Q,R] = tsearch(eph,sgps+tc+offs3,ecef_pos,mdel) ;
if isempty(Q), return, end
tc = tc+interpmin(offs3,R) ;
if abs(tc)>maxdev,return, end

SVP = svposns(eph,sgps+tc,Q(1:3)) ;       
if isempty(SVP),return, end
[pos,tt,m,L]=refineposn(SVP,Q(1:3),mdel) ;

% if there are 8 or more satellites and the RMS prange error is > 30,
% try eliminating the SV with the largest prange error.
if length(L)>=8 && m>30,
   k = abs(L)<max(abs(L)) ;
   [pos1,tt1,m1]=refineposn(SVP(k,:),Q(1:3),mdel(k)) ;
   if m1<m,
      pos = pos1 ;
      tt = tt1 ;
      m = m1 ;
   end
end

tc = tc+tcin ;
%fprintf('capture %d, #sv %d, m %f, tc %f\n',ki,length(kk),m,tc) ;
POS = [pos tt m tc min(R)] ;
