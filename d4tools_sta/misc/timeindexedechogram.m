function    RR=timeindexedechogram(x,CL,T,F,df)
%
%     RR = timeindexedechogram(x,CL,T,F,df)
%     Compute an echogram with a time axis rather than a click axis.
%     x is the signal vector
%     CL is a vector of click cues in samples
%     T = [left right] are the times in samples to display with
%        respect to each click.
%     F = [lower upper] or [lower] defines a bandpass or high-pass filter
%        with 1 = Nyquist frequency
%     df is the decimation factor (integer>=1) to use in the range-axis
%
%  marjjohnson@st-andrews.ac.uk
%  March 2016
%

RR = [] ; N = [] ;
if nargin<4,
    help timeindexedechogram
    return
end

if nargin<5 || isempty(df),
   df = 1 ;
end

CH = 0 ;                   % which audio channel to analyse

% make analysis filter
if length(F)==1,
   b = fir1(100,F,'high') ;
else
   b = fir1(100,F) ;
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

CL = round(CL+length(b)/2) ;
ki = T(1):(T(2)+nex) ;
kki = ki(1):ki(end)+500 ;
D = ki(1:abs(df):end)' ;
R = zeros(length(D),length(CL)) ;

if abs(df)>1,
   for k=1:length(CL),
      r = abs(hilbert(xf(CL(k)+kki))) ;
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

if nargout>=1,
   RR = {D,CL,RdB-N,N} ;
   return ;
end

figure(1),clf
imageirreg(CL,D,RdB'-N);
grid on
colormap(jet) ;
caxis([0 60])
return
