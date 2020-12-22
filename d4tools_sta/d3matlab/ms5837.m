function		[D,TEMP] = ms5837(cal,p,t,ext)

%		[p,t] = ms5837(cal,p,t,ext)
%     Returns:
%		p is pressure in metres H2O
%		t is temperature in degrees C
%     ext is the pressure extension word which is ignored

if ~isfield(cal,'cal'),
	fprintf(' Cal structure for ms5837 must contain a cal field\n') ;
	return
end
	
C = cal.cal ;
C(C<0) = C(C<0)+2^16 ;

% Below calibration is for data format:
% <WDLEN SENS="PRES"> 16,0 </WDLEN>

% temperature calculation
D2 = t*2^15-cal.toffs ;			 % 16 bit value so 1/256th of D2 in datasheet
k = find(D2<0) ;
D2(k) = 2^16+D2(k) ;
dT = D2-C(5) ;							 % also 1/256th of dT in datasheet
TEMP = (2000+dT*C(6)/2^15)/100 ;  % temperature in degC

% second order compensation for temperatures < 20 degC
T2 = zeros(length(TEMP),1) ;
kk = find(TEMP<20) ;
T2(kk) = 3/100*dT(kk).^2/2^17 ;		% 1/100th of datasheet
TEMP = TEMP - T2 ;						% degsC

% pressure calibration
OFF2 = zeros(length(TEMP),1) ;
SENS2 = OFF2 ;
kk = find(TEMP<20) ;
tt = (TEMP(kk)-20).^2 ;					% 1/100th of datasheet
OFF2(kk) = (3/2*1e4/2^8)*tt ;			% 1/256th of datasheet
SENS2(kk) = (5/8*1e4)*tt ;				% same as datasheet
kk = find(TEMP<-15) ;
tt = (TEMP(kk)+15).^2 ;
OFF2(kk) = OFF2(kk) + (7*1e4/2^8)*tt ;			% 1/256th of datasheet
SENS2(kk) = SENS2(kk) + (4*1e4)*tt ;			% same as datasheet

if isempty(p),
   D = [] ;
   return
end

% pressure calculation
D1 = p*2^15-cal.poffs ;			% 16 bit value so 1/256th of D1 in datasheet
OFF = C(2)*2^8+C(4)*dT/2^7 - OFF2 ;	% also 1/256th of OFF in datasheet
SENS = C(1)*2^15+C(3)*dT - SENS2 ;	% same as SENS in datasheet
P = (D1.*SENS/2^21-OFF)/(2^5*10) ;  % pressure in millibars
D = P*0.0102-10.12 ;						% convert millibars to metres head
