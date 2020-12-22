function    n = load_fft_dat(fname)

%    n = load_fft_dat(fname)
%    Read a Texas Instruments FFT test data file.
%    Example:
%	  n=load_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\invec_fft_1024pts.dat');
%    r=load_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\refvec_fft_1024pts.dat');
%	  F=fft(n*1024);
%	  plot([real(F)-real(r) imag(F)-imag(r)])
%
%	  For the 1024 point FFT dataset, the refvec should be within +/- 2 bits of:
%		round(fft(invec/1024))
%	  For the 1024 point IFFT dataset, the refvec should be within +/- 10 bits of:
%		round(ifft(invec*1024))

f = fopen(fname,'r') ;
n = zeros(10000,2) ;
k = 0 ;

while 1,
   s = fgetl(f) ;
   if ~ischar(s), break, end
   k = k+1 ;
   s = strtok(s) ;
   n(k,:) = [hex2dec(s(3:6)) hex2dec(s(7:10))] ;
end
fclose(f) ;
n = n(1:k,:) ;
k = find(n>32767) ;
n(k) = n(k)-65536 ;
if any(n(:,2)~=0),
   n = n(:,1)+j*n(:,2) ;
else
   n = n(:,1) ;
end
