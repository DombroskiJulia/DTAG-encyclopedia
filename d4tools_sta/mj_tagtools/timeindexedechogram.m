function    RR = timeindexedechogram(x,CL,T,F,df)
%
%     RR = timeindexedechogram(x,CL,T,F,df)
%     Compute an echogram with a time axis rather than a click axis.
%     Can be called in two ways:
%     Method 1:
%        x is the signal vector
%        CL is a vector of click cues in samples
%        T = [left right] are the times in samples to display with
%           respect to each click.
%        F = [lower upper] or [lower] defines a bandpass or high-pass filter
%           with 1 = Nyquist frequency
%     Method 2:
%        x is the tag name (tag type 2) or x{1}=recdir, x{2}=prefix (tag3)
%        CL is a vector of click cues in seconds
%        T = [left right] are the times in seconds to display with
%           respect to each click.
%        F = [lower upper] or [lower] defines a bandpass or high-pass filter
%           in Hz.
%     In both methods df is the decimation factor (integer>=1) to use in 
%        the range-axis.
%
%  markjohnson@st-andrews.ac.uk
%  March 2016
%

if nargin<4,
    help timeindexedechogram
    return
end

if nargin<5 | isempty(df),
   df = 1 ;
end

CH = 0 ;                   % which audio channel to analyse
fs = 1 ;                   % default sampling rate
if isstr(x) || iscell(x),
   tag = x ;
   cues = [min(CL)+min(T)-0.1 max(CL)+max(T)+0.1] ;
   if isstr(x),
      [x,fs] = tagwavread(tag,cues(1),diff(cues)) ;
   else
      [x,fs] = d3wavread(cues,tag{1},tag{2}) ;
   end
   F = F/(fs/2) ;
   CL = round(fs*(CL-cues(1))) ;
   T = round(fs*T) ;
end

% make analysis filter
if length(F)==1,
   b = fir1(50,F,'high') ;
else
   b = fir1(50,F) ;
end
a = 1 ;

if CH==0 & size(x,2)>1,
   scf = 1/size(x,2) ;
   x = mean(x,2) ;
   CH = 1 ;
end

if size(x,2)==1,
   CH = 1 ;
end

xf = filter(b,a,x(:,CH)) ;

% make selection indices - add extra points to make length divisible by df
if abs(df)>1,
   nex = mod(abs(df)-mod(T(2)-T(1)+1,abs(df)),abs(df)) ;
else
   nex = 0 ;
end

ki = T(1):(T(2)+nex) ;
kki = ki(1):ki(end)+500 ;
D = ki(1:abs(df):end)' ;
R = zeros(length(D),length(CL)) ;

if abs(df)>1,
   for k=1:length(CL),
      r = abs(hilbert(xf(round(CL(k))+kki))) ;
      if df>0,
         R(:,k) = max(reshape(r(1:df*length(D)),df,length(D)))' ;
      else
         R(:,k) = sqrt(mean(reshape(r(1:abs(df)*length(D)).^2,abs(df),length(D))))' ;
      end
   end
else
   for k=1:length(CL),
      R(:,k) = abs(hilbert(xf(CL(k)+ki))) ;
   end
end

RdB = 20*log10(R) ;
N = prctile(RdB(:),10) ;

if nargout==1,
   RR = {D/fs,CL/fs,RdB-N,N} ;
   return ;
end

figure(1),clf
imageirreg(CL/fs,D/fs,RdB'-N);
grid on
colormap(jet) ;
caxis([0 60])
return
