function    [F,Fc] = dspgps_input(x)

%    [F,Fc] = dspgps_input(x)
%

% precompute hr, hi and offs - these would be just stored
% directly in the code
h=fir1(31,1/8);
hr=2*h(1:2:end).*((-1).^(1:16));
hi=2*h(2:2:end).*((-1).^(2:17));
offs=-sum(hr)/2;

% unpack, demodulate and decimate x
b=unpack(x,16) ;     % convert to 0,1
Xr=buffer(b(2:2:end),16,16-4,'nodelay');
yrd=(hr*Xr)'+offs;
Xi=buffer(b(3:2:end),16,16-4,'nodelay');
yid=(hi*Xi)'+offs;
yd=yrd+1j*yid ;

% group into 1ms chunks, resample to 2.048 MHz and take FFT
% decimated input stream has 2046 samples per ms
[B,z] = buffer(yd,2046,0,'nodelay') ;  
B = [B(1:1023,:);zeros(1,size(B,2));B(1024:end,:);zeros(1,size(B,2))] ;
F = fft(B,Nfft) ;

if nargout==2,
   % gives identical results to:
   b=2*unpack(x,16)-1 ;     % convert to +/-1
   bb=b.*repmat([-j;-1;j;1],length(b)/4,1) ;
   h=fir1(31,1/8);
   y=filter(h,1,bb);
   ydd=y(33:8:end);
   max(abs(ydd-yd(1:length(ydd))))
   [B,z] = buffer(ydd,2046,0,'nodelay') ;
   B = [B(1:1023,:);zeros(1,size(B,2));B(1024:end,:);zeros(1,size(B,2))] ;
   Fc = fft(B,Nfft) ;
end
