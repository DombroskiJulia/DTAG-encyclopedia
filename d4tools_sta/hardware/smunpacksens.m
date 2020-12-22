function    [A,M,fs]=smunpacksens(fname)
%
%  [A,M,fs]=smunpacksens(fname)
%

[x,fs] = wavread(fname) ;
nch = size(x,2) ;
A=x(:,1:nch-3)';
A=A(:);
A=reshape(A,3,[])';
M = x(:,nch-2:end) ;
fs = [(nch-3)/3 1]*fs ;
