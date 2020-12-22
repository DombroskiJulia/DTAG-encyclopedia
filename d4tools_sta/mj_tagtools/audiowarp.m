function  [y,fs] = audiowarp(x,fs,n)

%     [y,fs] = audiowarp(x,fs,n)
%     EXPERIMENTAL!!
% high-pass audio at 5kHz and compute envelope. Remove quiet sections
% sufficient to shorten the vector by n times. Add this to the low frequency
% audio decimated by n.
%

n = round(n) ;
x = x(1:n*floor(length(x)/n),:) ;
fc = 5000 ;
[bl al] = butter(4,fc/(fs/2)) ;
[be ae] = butter(2,fc/(fs/2)/3) ;
[bh ah] = butter(4,fc/(fs/2),'high') ;
xl = decdc(filter(bl,al,x),n) ;
x = filter(bh,ah,x) ;
if size(x,2)>1,
   %env = filtfilt(be,ae,sum(x'.^2)') ;         % takes too much memory
   env = filtfilt(be,ae,x(:,1).^2+x(:,2).^2) ;  % do it this way instead
else
   env = filtfilt(be,ae,x.^2) ;
end

% find loudest episodes and fit them first
bsize = 0.01 ;                % block size in seconds
nb = round(bsize*fs/n) ;      % number of output samples in each block
kb = n*nb ;                   % number of input samples in each block
nf = floor(length(x)/kb) ;    % number of blocks in input
yy = zeros(nb,nf,size(x,2)) ;
y = 0*xl ;

ee = reshape(env(1:nf*kb),kb,nf) ;
[eee,I] = sort(ee) ;
I = flipud(I) ;
I = I(1:nb,:) ;
for kk=1:size(I,2),
   II = sort(I(:,kk))+(kk-1)*kb ;
   yy(:,kk,:) = x(II,:) ;
end
y(1:nb*nf,:) = reshape(yy,nb*nf,1,size(x,2)) ;

y = y+xl ;
fs = fs / n ;
