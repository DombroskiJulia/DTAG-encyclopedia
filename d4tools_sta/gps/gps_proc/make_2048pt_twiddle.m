% Generate a 1/4 length twiddle table for 2048 pt FFT.
% A 1/4 table can be extended to a half table as required by the final
% butterfly of the FFT by using:
% 1..512   TWreal(k), TWimag(k)
% 513..1024  -TWreal(1024-k+1), TWimag(1024-k+1)

N = 2048;
n = (0:N/4)';
tw = cos(2*pi*n/N)-j*sin(2*pi*n/N);
T=round(32767*[real(tw) imag(tw)]);
k=find(T<0);
T(k)=T(k)+65536;
fprintf('0x%04x%04x,0x%04x%04x,0x%04x%04x,0x%04x%04x,\n',round(T)')
