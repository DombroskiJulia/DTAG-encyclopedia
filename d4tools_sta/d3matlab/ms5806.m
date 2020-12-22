function		[H,TEMP,P] = ms5806(cal,p,t)

%		[h,t,p] = ms5806(cal,p,t)
%		h is height in metres
%		t is temperature in degrees C
%		p is pressure in millibars

if ~isfield(cal,'cal'),
	fprintf(' Cal structure for ms5837 must contain a cal field\n') ;
	return
end
	
C = cal.cal ;
C(C<0) = C(C<0)+2^16 ;

% Below calibration is for data format:
% <WDLEN SENS="PRES"> 16,8 </WDLEN>

if ~isfield(cal,'poffs'),
	cal.poffs = 0 ;
end
	
if ~isfield(cal,'toffs'),
	cal.toffs = -15000 ;
end

% temperature calculation
D2 = X.x{7}*2^15-cal.toffs ;
k = find(D2<0) ;
D2(k) = 2^16+D2(k) ;
dT = D2-C(5) ;
TEMP = (2000+dT*C(6)/2^15)/100 ;  % temperature in degC

% second order compensation for temperatures < 20 degC
T2 = zeros(length(TEMP),1) ;
OFF2 = T2 ;
SENS2 = T2 ;
kk = find(TEMP<20) ;
T2(kk) = dT(kk).^2/2^15 ;
tt = (TEMP(kk)-20).^2 ;
OFF2(kk) = (61e4/2^4)*tt ;
SENS2(kk) = 2e4*tt ;
TEMP = TEMP - T2 ;
kk = find(TEMP<-15) ;
tt = (TEMP(kk)+15).^2 ;
OFF2(kk) = OFF2(kk) + 20e4*tt ;
SENS2(kk) = SENS2(kk) + 12e4*tt ;

% pressure calculation
D1 = (X.x{8}*256+X.x{9})*2^15-cal.poffs*256 ;
OFF = C(2)*2^17+C(4)*dT*4 - OFF2 ;
SENS = C(1)*2^16+C(3)*dT*2 - SENS2 ;
P = (D1.*SENS/2^21-OFF)/(2^15*100) ;   % pressure in millibars
H = 44308*(1-(P/1013.25).^0.1903) ;    % height in metres
