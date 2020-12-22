function    [Xr,T] = shorter_resample(X,t)
%
%     [Xr,T] = shorter_resample(X,t)
%
%

FS = 50 ;      % output sampling rate
df = 10 ;      % nominal decimation factor - input rate should be about FS*df
LIM = 0.01 ;
T = (min(t)+1:1/FS:max(t)-1) ;   % output sample time vector
S = -2*df:2*df ;              % filter sample indices
H = fir1(4*df,0.8/df) ;     % decimation filter
Xr = NaN*zeros(length(T),size(X,2)) ;   % space for the output data
for kk=1:length(T),
   k = find(T(kk)<t,1) ;
   if isempty(k), break, end
   [m,offs] = min(abs(t(k-1:k)-T(kk))) ;
   s = (k+offs-2)+S ;
   if max(diff(t(s)))<LIM,
      Xr(kk,:) = H*X(s,:) ;
   end
end
