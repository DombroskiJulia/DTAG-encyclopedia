h=fir1(31,1/8);
hr=2*h(1:2:end).*((-1).^(1:16));
hi=2*h(2:2:end).*((-1).^(2:17));
offs=-sum(hr)/2;

% make 256 length look-up tables
% to unpack, demodulate and decimate x

x = 0:255 ;
LUT8 = zeros(length(x),4) ;
for k=1:length(x),
	b=unpack(x(k),8) ;     % convert to 0,1
	LUT8(k,:)= ([hr(1:8);hr(9:16);hi(1:8);hi(9:16)]*b)'+offs/2 ;
end

% fake data
x=floor(2^16*rand(1024,1));

% convolution method
b=unpack(x,16) ;     % convert to 0,1. MSB first
Xr=buffer(b(2:2:end),16,16-4,'nodelay');
yrd=(hr*Xr)'+offs;
Xi=buffer(b(3:2:end),16,16-4,'nodelay');
yid=(hi*Xi)'+offs;
yd=yrd+1j*yid ;

% 8-bit look-up table method
b=unpack(x,16) ;     % convert to 0,1
bm = 2.^(7:-1:0) ;
Xr=buffer(b(2:2:end),16,16-4,'nodelay');
br1 = bm*Xr(1:8,:) ;
br2 = bm*Xr(9:16,:) ;
yrm = LUT8(br1+1,1) + LUT8(br2+1,2) ;
Xi=buffer(b(3:2:end),16,16-4,'nodelay');
bi1 = bm*Xi(1:8,:) ;
bi2 = bm*Xi(9:16,:) ;
yim = LUT8(bi1+1,3) + LUT8(bi2+1,4) ;
ydm=yrm+1j*yim ;

% compare results - they should be identical minus round-off error
[yd(1:10) ydm(1:10)]
