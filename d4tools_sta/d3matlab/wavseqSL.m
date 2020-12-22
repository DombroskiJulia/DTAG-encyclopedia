function    [SL,f,T] = wavseqSL(recdir,prefix,cues,nfft,len,freqr,ptrim)
%
%    [SL,f,T] = wavseqSL(recdir,prefix,cues,nfft,len,freqr,ptrim)
%     Compute the SL in blocks of len seconds from a sequence of wav files. 
%     The wav files must all have filenames with the same prefix followed by 
%     increasing (but not necessarily sequential) numbers. 
%     recdir is the recording directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%     cues = [start_cue end_cue], cues are in seconds with respect
%        to the start first sample in the first file in the sequence.
%
%     If freqr and plim are specified, calculate the spectral
%     power between freqr(1) and freqr(2) Hz for each nfft-length 
%     interval within each len block. Select the largest (or
%     smallest if ptrim is negative) ptrim percent of spectra according
%     to the power in this band. Mean the power in this subset of
%     spectra.
%     If freqr and ptrim are not given, just average the power spectra
%     over each len block.
%
%     Assumptions:
%     This code assumes that the wav files are contiguous, i.e., there is
%     no gap between successive files. If the recordings come from
%     Soundtraps, make sure the 'zero fill dropouts' option is selected 
%     in the tools menu of Soundtrap Host.
%
%     Examples:
%        wavseqSL('f:/hp14/hp14_226b','',[2000 2010],1024,10,[8e3 16e3],-10);
%
%     modified 12 April 2017
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

SL = [] ; f = [] ;
if nargin<3,
   help wavseqSL ;
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

cue = cues(1) ;
endcue = cues(2) ;
nov = nfft/2 ;
% get the sampling frequency
[x,fs] = wavseqread(cue+[0 0.1],recdir,prefix) ;
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

for k=1:N,
   fprintf('Reading at cue %d\n', round(cue)) ;
   x = wavseqread(cue+[0 len],recdir,prefix) ;
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

