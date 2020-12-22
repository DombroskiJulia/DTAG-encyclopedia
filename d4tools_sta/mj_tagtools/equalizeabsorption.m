function       X = equalizeabsorption(X,d,fs)
%
%      X = equalizeabsorption(X,d,fs)
%     NOTE: this is intended for beaked whale clicks recorded with
%     a sampling rate of 96kHz, at distances of 0-2000 m

n = size(X,1) ;
N = 1024 ;
D = (0:250:2000)' ;

% acceptable freq. tapers for emphasis of waveforms recorded with absorption
H = zeros(N,length(D)) ;
H(:,1) = ones(N,1) ;
[H(:,2),f]=absorptiontaper(N,fs,250,0.5,-4);
[H(:,3),f]=absorptiontaper(N,fs,500,-0.5,-6.5);
[H(:,4),f]=absorptiontaper(N,fs,750,-1.5,-8.5);
[H(:,5),f]=absorptiontaper(N,fs,1000,-2.5,-10);
[H(:,6),f]=absorptiontaper(N,fs,1250,-3.3,-12);
[H(:,7),f]=absorptiontaper(N,fs,1500,-4,-14);
[H(:,8),f]=absorptiontaper(N,fs,1750,-5,-16);
[H(:,9),f]=absorptiontaper(N,fs,2000,-6,-18);

kn = nearest(D,d) ;
HH = zeros(N,size(X,2)) ;
for k=1:size(X,2),
   HH(:,k) = H(:,kn(k)) ;
end
HH = 1./HH ;         % invert taper to perform emphasis
F = fft(X.*repmat(hamming(n),1,size(X,2)),1024) ;
X = real(ifft(F.*HH)) ;
X = X(1:n,:) ;
