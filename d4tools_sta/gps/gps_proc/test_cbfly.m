% test vectors for 2048 pt FFT

% TEST16 option (tests cbfly16):
f = fft(x/1024) ;		% no scaling in cbfly16
save_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\refvec_fft_2048pts.dat',f);

% TEST8 option (tests cbfly8):
f = fft(x/2048) ;		% scaling in cbfly8
save_fft_dat('C:\tag\projects\d4\code\gpsproc\inc\refvec_fft_2048pts.dat',f/256,8);
