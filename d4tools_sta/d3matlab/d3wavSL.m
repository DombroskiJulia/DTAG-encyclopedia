function    [SL,f,T] = d3wavSL(recdir,prefix,cues,nfft,len,freqr,ptrim)
%
%    [SL,f,T] = d3wavSL(recdir,prefix,cues,nfft,len,freqr,ptrim)
%     Compute the SL in blocks of len seconds from tag audio.
%     If freqr and plim are specified, calculate the spectral
%     power between freqr(1) and freqr(2) Hz for each nfft-length 
%     interval within each len block. Select the largest (or
%     smallest if ptrim is negative) ptrim percent of spectra according
%     to the power in this band. Mean the power in this subset of
%     spectra.
%     If freqr and ptrim are not given, just average the power spectra
%     over each len block.
%
%     mark johnson
%     7 feb 2013

SL = [] ; f = [] ;
if nargin<3,
   help d3wavSL ;
   return
end

if nargin<4 || isempty(nfft),
   nfft = 1024 ;
end

if nargin<5 || isempty(len),
   len = 10 ;
end

if nargin<7,
   ptrim = [] ;
end

if isempty(cues),
	cue = 0 ;
	endcue = NaN ;
else
	cue = cues(1) ;
	endcue = cues(2) ;
end
	
nov = nfft/2 ;
% get the sampling frequency and cue table
if dtagtype(prefix,1)==2,
   [x,fs] = tagwavread(prefix,cue,0.1) ;
   % check the cues
   cue = max(cue,0) ;
   endcue = min(endcue,recordlength(prefix)) ;
else
   [ct,ref_time,fs,fn,recdir] = d3getcues(recdir,prefix,'wav') ;
   % check the cues
   cue = max(cue,ct(1,2)) ;
   endcue = min(endcue,ct(end,2)+(ct(end,3)-1)/fs) ;
end

N = floor((endcue-cue)/len) ;
T = cue+len/2+len*(0:N-1)' ;
P = NaN*zeros(nfft/2,N) ;
w = hanning(nfft) ;
f = (0:nfft/2-1)/nfft*fs ;
if nargin>=6 && ~isempty(freqr),
   kf = find(f>=freqr(1) & f<freqr(2)) ;
else
   kf = 1:length(f) ;
end
lastrep = cue-100 ;

for k=1:N,
   if cue-lastrep>60,
      fprintf('Reading at cue %d\n', round(cue)) ;
      lastrep = cue ;
   end
   x = d3wavread(cue+[0 len+nov/fs],recdir,prefix) ;
   if size(x,2)>1,
      x = x(:,1) ;
   end
   if length(x)<=nfft,
      P = P(:,1:k-1) ;
      break
   end
   cue = cue+len ;
   [x,z] = buffer(x,nfft,nov,'nodelay') ;
   x = detrend(x).*repmat(w,1,size(x,2)) ;
   ff = abs(fft(x)).^2 ;
   if ~isempty(ptrim),
      p = sum(ff(kf,:)) ;
      if ptrim<0,
         thr = prctile(p,-ptrim) ;
         kp = find(p<thr) ;
      else
         thr = prctile(p,100-ptrim) ;
         kp = find(p>thr) ;
      end
      P(:,k) = sum(ff(1:nfft/2,kp),2)/length(kp) ;      
   else
      P(:,k) = sum(ff(1:nfft/2,:),2)/size(x,2) ;
   end
end

P = P/(nfft^2) ;
slc = 3-10*log10(fs/nfft)-10*log10(sum(w.^2)/nfft) ;
SL = 10*log10(P)+slc ;
return

