function    x = fixoutage(x,fs,thr,t)
%
%    x = fixoutage(x,fs,thr,t)
%

x(find(any(x,2)==0),:) = NaN ;
if nargin<4,
   return
end

x(1:round(t*fs),:) = NaN ;
kd = find(any(abs(diff(x))>thr,2)) ;
for k=kd',
   x(k+(0:t*fs),:) = NaN ;
end
