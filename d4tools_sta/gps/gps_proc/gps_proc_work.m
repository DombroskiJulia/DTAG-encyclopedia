[B,BH,H] = d3readbin('/tag/temp/pas012.bin',[]);
x = B{:,30} ;
kz = find((x(1:end-1)==0) & (x(2:end)==0)) ;
x = x(4:kz(1)-2) ;
[b,fs] = bitgrab2bb(x,8,0,1);

CF = 2 ;
FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
fstep = 300/FS ;           % Doppler step
FD = [-8 8]*1e3 ;
sv = 16 ;
Nfft = 2*2046 ;         % FFT length to use - has to span two times the code length
wd = 2*pi*(FD(1)/FS:fstep:FD(2)/FS) ;     % doppler test frequencies in rad/s

g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of 2
%g = reshape(repmat(2*ca_code(sv)-1,1,2)',1,[])' ;      % interpolate C/A code by factor of 2
mf = g(end:-1:1) ;                  % reverse code order for matched filtering
nmf = length(g) ;
%cc = repmat(mf,1,length(wd)).*exp(-j*(0:nmf-1)'*wd) ;  % C/A codes with different dopplers
%Fmf = fft(cc,Nfft) ;      % fft of the matched filters
Fmf = fft(mf,Nfft) ;      % fft of the matched filters

OFFS = 10000 ;
%S = fft(b(OFFS+(1:Nfft)),Nfft) ;        % take the fft of the input blocks
cc = repmat(b(OFFS+(1:Nfft)),1,length(wd)).*exp(-j*(0:Nfft-1)'*wd) ;  % C/A codes with different dopplers
S = fft(cc,Nfft) ;      % fft of the matched filters
PP = ifft(conj(S).*repmat(Fmf,1,length(wd)),Nfft) ;   % apply the matched filters and inverse fft
pp = abs(PP).^2 ;
figure(1)
plot(pp),grid

[m,n] = max(pp) ;
[m,dop] = max(m) ;
del = n(dop) ;
fprintf(' Peak of %d (median level %d), at delay %d, doppler %4.1f\n',round(m),...
   round(median(pp(:))),del,wd(dop)/2/pi*FS) ;
