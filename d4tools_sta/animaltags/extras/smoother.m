function    y = smoother(x,n)

%     y = smoother(x,n)
%     Low pass filter a time series. This is a simplified way to use the 
%     fir_nodelay function. The low-pass filter length is chosen according to
%     the amount of smoothing required.
%
%     Inputs:
%     x is the time series and can be a vector or a matrix with a
%     signal in each column. 
%     n is the smoothing parameter - use a larger number to smooth more.
%        e.g., n=2 filters out frequencies above half of the Nyquist frequency
%        and so halves the bandwidth of the signal. n=10 will give 1/10th of the
%        original signal bandwidth.
%
%     Smoother uses a symmetric FIR filter of length 8n. The group delay is
%     removed so that y has no delay with respect to x.
%
%     markjohnson@st-andrews.ac.uk
%     Last modified: simplified to use fir_nodelay 6/2/18

nf = 8*n ;
fp = 0.5/n ;
if size(x,1)==1,
   x = x(:) ;
end

y = fir_nodelay(x,nf,fp) ;
