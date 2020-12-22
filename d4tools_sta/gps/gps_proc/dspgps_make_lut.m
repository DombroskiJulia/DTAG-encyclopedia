% Make look-up tables for GPS unpacking, demodulation and decimation

h=fir1(31,1/8);
hr=2*h(1:2:end).*((-1).^(1:16));
hi=2*h(2:2:end).*((-1).^(2:17));
offs=-sum(hr)/2;
scf = 256*0.8828 ;	% to avoid overflow in 8-bit words

% make 256 length look-up tables
% to unpack, demodulate and decimate x

x = 0:255 ;
LUT = zeros(length(x),4) ;
PLUT = zeros(length(x),2) ;
for k=1:length(x),
	b=unpack(x(k),8) ;     % convert to 0,1
	m = round(scf*(([hr(1:8);hi(1:8);hr(9:16);hi(9:16)]*b)'+offs/2)) ;
	LUT(k,:) = m ;
	m(m<0) = 256 - m(m<0) ;
	PLUT(k,:) = [m(1)*256+m(2) m(3)*256+m(4)] ;
end

for k=1:length(x)/8,
	fprintf('%d,',PLUT(8*(k-1)+(1:8),1)) ;
	fprintf('\n');
end
fprintf('\n');

for k=1:length(x)/8,
	fprintf('%d,',PLUT(8*(k-1)+(1:8),2)) ;
	fprintf('\n');
end
fprintf('\n');

% check for overflow
yr = zeros(256,256);
yi = zeros(256,256);
for k1=1:256,
	for k2=1:256,
		yr(k1,k2) = LUT(k1,1) + LUT(k2,3) ;
		yi(k1,k2) = LUT(k1,2) + LUT(k2,4) ;
	end
end

[max(max(yr)) min(min(yr)) max(max(yi)) min(min(yi))]
