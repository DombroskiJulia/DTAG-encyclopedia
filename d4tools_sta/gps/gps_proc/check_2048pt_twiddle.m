% Example showing that 2:1 linear interpolation of 1024 pt twiddle
% table gives better than 16 bit accuracy so that there is no need
% to store a 2048 pt twiddle table.

N = 2048;
n = 0:(N/2-1);
tr2 = cos(2*pi*n/N);
ti2 = -sin(2*pi*n/N);

N = 1024;
n = 0:(N/2-1);
tr = cos(2*pi*n/N);
ti = -sin(2*pi*n/N);

tr2e = reshape([tr' (tr+[tr(2:end) -tr(1)])'*0.5]',[],1) ;
ti2e = reshape([ti' (ti+[ti(2:end) -ti(1)])'*0.5]',[],1) ;
max(abs(round(32768*(tr2e-tr2'))))
max(abs(round(32768*(ti2e-ti2'))))
