function    print_sv_code(svn)

%     print_sv_code(svn)
%
%

G = reshape([ca_code(svn);0],32,[]);
W = G*2.^(31:-1:0)';
fprintf('0x%08x,0x%08x,0x%08x,0x%08x,\n',W)

% below to compute spectrum
%x = reshape(((2*ca_code(svn)-1)*[1 1])',[],1);
%x = [x(1:1023);0;x(1024:2046);0] ;
%F=fft(x*32767/2048);
