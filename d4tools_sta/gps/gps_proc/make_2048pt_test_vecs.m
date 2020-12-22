% Test vectors for 2048 point FFT and IFFT on DSP C55xx

x = round(32768*(2*rand(2048,1)-1)) ;
F = round(fft(x/2048)) ;
xx = round(ifft(F*2048)) ;
save_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\invec_fft_2048pts.dat',x);
save_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\refvec_fft_2048pts.dat',F);
save_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\invec_ifft_2048pts.dat',F);
save_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\refvec_ifft_2048pts.dat',xx);

x=load_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\invec_fft_2048pts.dat');
f1=fft(x(1:2:end)/1024);	% even (when index starts at 0)
f2=fft(x(2:2:end)/1024);	% odd
F=[real(f1) imag(f1) real(f2) imag(f2)];
k=find(F<0);
F(k)=F(k)+65536;
fprintf('%04x%04x, %04x%04x\n',round(F(1:20,:))')
% above should be within +/- 2 in each 16 bit field of:
% printf("%lx, %lx\n",data_even[k],data_odd[k]) ;

% below demonstrates conversion of two 1024 pt FFTs to a 2048 pt FFT
f = fft(x/2048) ;
N = 2048;
n = (0:(N/2-1))';
tw = cos(2*pi*n/N)-j*sin(2*pi*n/N);
ff = f2.*tw ;
fest = 0.5*[f1+ff;f1-ff] ;		% should be the same as f

N = 2048;
n = (0:(N/2-1))';
tw = cos(2*pi*n/N)-j*sin(2*pi*n/N);
T=round(32767*[real(tw) imag(tw)]);
k=find(T<0);
T(k)=T(k)+65536;
fprintf('0x%04x%04x,0x%04x%04x,0x%04x%04x,0x%04x%04x,\n',round(T(1:512,:))')

F=[real(f) imag(f)];
k=find(F<0);
F(k)=F(k)+65536;
fprintf('%04x%04x, %04x%04x\n',round([F(1:20,:) F(1024+(1:20),:)])')

% below demonstrates conversion of two 1024 pt IFFTs to a 2048 pt IFFT
x=load_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\invec_fft_2048pts.dat');
f = fft(x/2048) ;
xx = ifft(f) ;
x1=ifft(f(1:2:end));	% even (when index starts at 0)
x2=ifft(f(2:2:end));	% odd
N = 2048;
n = (0:(N/2-1))';
tw = cos(2*pi*n/N)+j*sin(2*pi*n/N);		% need the conjugate twiddle factors
ff = x2.*tw ;
xest = 0.5*[x1+ff;x1-ff] ;		% should be the same as xx

% save a x2 scaled 8 bit FFT result
x=load_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\invec_fft_2048pts.dat');
f = fft(x/1024) ;
save_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\refvec_fft_2048pts.dat',f/256,8);
