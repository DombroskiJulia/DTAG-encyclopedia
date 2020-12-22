function    CL = alignbuzzclicks(x,CL,T,F)
%
%     CL = alignbuzzclicks(x,CL,T,F)
%     Compute an echogram with a time axis rather than a click axis.
%     x is the signal vector
%     CL is a vector of click cues in samples
%     T = [left right] are the times in samples to display with
%        respect to each click.
%     F = [lower upper] or [lower] defines a bandpass or high-pass filter
%        with 1 = Nyquist frequency
%
%  marjjohnson@st-andrews.ac.uk
%  March 2016
%

if nargin<4,
    help alignbuzzclicks
    return
end

CH = 0 ;                   % which audio channel to analyse
if length(T)==1,
   T = abs(T)*[-1 1] ;
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

CL = round(CL) ;
T = round(T) ;
k1 = T(1):T(2)+500 ;
k2 = 1:T(2)-T(1) ;
xf = filter(b,a,x(:,CH)) ;
R = zeros(length(k2),length(CL)) ;
for k=1:length(CL),
   r = abs(hilbert(xf(CL(k)+k1))) ;
   R(:,k) = r(k2) ;
end

R = 20*log10(R) ;
M = max(R)-10 ;
P = zeros(length(CL),1) ;
for k=1:length(CL),
   P(k) = find(R(:,k)>M(k),1) ;
end
CL = round(CL+P-mean(P)) ;
