function		save_fft_dat(fname,n,nb)

%		save_fft_dat(fname,n,nb)
%
%

f = fopen(fname,'w') ;
n = [real(n) imag(n)] ;
k = find(n<0) ;
if nargin<3 || nb==16,
	n(k) = 65536+n(k) ;
	for k=1:length(n)-1,
		fprintf(f,'    0x%04X%04X,\n',round(n(k,:))) ;
	end
	fprintf(f,'    0x%04X%04X\n',round(n(end,:))) ;
else
	n(k) = 256+n(k) ;
	n = [n(1:2:end,:) n(2:2:end,:)] ;
	for k=1:size(n,1)-1,
		fprintf(f,'    0x%02X%02X%02X%02X,\n',floor(n(k,:))) ;
	end
	fprintf(f,'    0x%02X%02X%02X%02X\n',floor(n(end,:))) ;
end

fclose(f) ;
