function    y = smoother(x,n)
%
%    y = smoother(x,n)
%     Low pass filter a time series.
%     x is the time series and can be a vector or a matrix with a
%     signal in each column. 
%     n is the smoothing parameter - use a larger number to smooth more.
%        e.g., n=2 filters out frequencies above half of the Nyquist frequency
%        and so halves the bandwidth of the signal.
%
%     Smoother uses a symmetric FIR filter of length 8n. The group delay is
%     removed so that y has no delay with respect to x.
%
%     markjohnson@st-andrews.ac.uk

if nargin==2,
   nf = 8*n ;
   fp = 1/(2*n) ;
   h = fir1(nf,fp);
else
   n = 5 ;
   nf = 8*n ;
   fp = 1/(2*n) ;
   h=[-0.000000,-0.000442,-0.001061,-0.001964,-0.003163,-0.004539,-0.005807,-0.006534,-0.006179,-0.004169,0.000000,0.006662,0.015890,0.027439,0.040726,0.054866,0.068760,0.081212,0.091080,0.097418,0.099604,0.097418,0.091080,0.081212,0.068760,0.054866,0.040726,0.027439,0.015890,0.006662,0.000000,-0.004169,-0.006179,-0.006534,-0.005807,-0.004539,-0.003163,-0.001964,-0.001061,-0.000442,-0.000000];
end
noffs = floor(nf/2) ;
if size(x,1)==1,
   x = x(:) ;
end
y = filter(h,1,[x(nf:-1:2,:);x;x(end+(-1:-1:-nf),:)]) ;
y = y(nf+noffs-1+(1:size(x,1)),:);
