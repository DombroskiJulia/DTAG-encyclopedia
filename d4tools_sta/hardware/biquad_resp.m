function    [h,f] = biquad_resp(f0,q,f)
%
%    [h,f] = biquad_resp(f0,q,f)
%     f0 is cut-off frequency of each biquad.
%     q is the Q for each biquad. f0 and q can be vectors giving the cut-off
%     frequencies and Qs of multiple stages connected in series.
%     For a single pole, put q = 0.
%     f is the [lowest highest] frequency to compute the response for
%     or, if length(f)>2, f specifies the frequencies at which to evaluate
%     the response.
%     Returns:
%     h is the gain in dB at frequencies, f.

if nargin<3,
   f = [min(f0)/10,5*max(f0)] ;
end

if length(f)==2,
   f = logspace(log10(f(1)),log10(f(2)),1000)' ;
end
w = 2*pi*f ;
w0 = 2*pi*f0 ;
H = zeros(length(f),length(f0)) ;

for k=1:length(f0),
   if q(k)==0,
      H(:,k) = w0(k)*(w0(k) + j*w).^(-1) ;
   else
      H(:,k) = w0(k)^2*(w0(k)^2 + j*w0(k)/q(k)*w -w.^2).^(-1) ;
   end
end

h = sum(20*log10(abs(H)),2) ;
