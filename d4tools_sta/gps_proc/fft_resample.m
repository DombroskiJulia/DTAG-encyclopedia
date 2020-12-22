function y = fft_resample(x,h)
%  Decimate x by 8*1023/1024 using FIR filter h
%  Produce 2048 output samples.
%  Process: take nh samples of x and apply filter
%           skip 8 samples
%           every 128 times through, skip back 1 sample
nh = length(h) ;
y = zeros(2048,1) ;
ks = 0 ;
for k=1:2048,
   y(k) = h*x(ks+(1:nh)) ;
   ks = ks+8-(rem(k,128)==0) ;
end
return
