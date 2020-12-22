function    [SL,T,F,len] = wavproc(fname,nfft,tave,fdet,tdet,tblnk,dthr)
%
%    [SL,T,F,len] = wavproc(fname,nfft,tave,fdet,tdet,tblnk,dthr)
%

if nargin<1,
   help wavproc
   return
end

if nargin<2,
   nfft = 1024 ;
end

if nargin<3,
   tave = 10 ;
end

if nargin<4,
   fdet = 10e3 ;
end

if nargin<5,
   tdet = 100e-6 ;
end

if nargin<6,
   tblnk = 5e-3 ;
end

if nargin<7,
   dthr = 15 ;
end

% get the sampling frequency
[sz fs] = wavread16(fname,'size') ;
cue = 0 ;
endcue = sz(1)/fs(1) ;
nov = round(nfft/2) ;
tave = min(tave,round(10e6/fs)) ;
N = floor((endcue-cue)/tave) ;
P = zeros(nfft/2,N) ;
w = hanning(nfft) ;

for k=1:N,
   fprintf('%d of %d s\n',cue,round(endcue)) ;
   x = wavread16(fname,floor([fs*cue+1 fs*(cue+tave)])) ;
   if size(x,2)>1,
      x = x(:,1) ;
   end
   if length(x)<=nfft,
      P = P(:,1:k-1) ;
      break
   end
   cue = cue+tave ;
   [x,z] = buffer(x,nfft,nov,'nodelay') ;
   kk = find(max(abs(x))<0.5) ;
   x = detrend(x(:,kk)).*repmat(w,1,length(kk)) ;
   f = abs(fft(x)).^2 ;
   P(:,k) = sum(f(1:nfft/2,:),2)/size(x,2) ;
end

P = P/(nfft^2) ;
slc = 3-10*log10(fs/nfft)-10*log10(sum(w.^2)/nfft) ;
SL = 10*log10(P)+slc ;
F = (0:nfft/2-1)/nfft*fs ;
T = (0:size(SL,2)-1)+tave/2 ;
len = endcue ;
return

