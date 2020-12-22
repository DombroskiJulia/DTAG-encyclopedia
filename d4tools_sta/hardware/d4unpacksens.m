function    [A,M,p,t,fs]=d4unpacksens(fname)
%
%  [A,M,p,t,fs]=d4unpacksens(fname)
%

k = find(fname=='.') ;
if ~isempty(k),
   fname = fname(1:k-1) ;
end

[x,fs] = wavread([fname '.swv']) ;
nch = size(x,2) ;
if rem(nch,3)==0,
   nna = 3 ;
else
   nna = 5 ;
end
A=x(:,1:nch-nna)';
A=A(:);
A=reshape(A,3,[])';
M = x(:,nch-nna+(1:3)) ;
fs = [(nch-nna)/3 1 1 1]*fs ;

if nna>3,
   p = x(:,nch-1) ;
   t = x(:,nch)*2^15/4*0.03125 ;   % approx conversion to degrees C
else
   p = [] ;
   t = [] ;
   fs(3:4) = 0 ;
end

