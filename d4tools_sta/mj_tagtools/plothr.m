function    ihi = plothr(H)
%
%   ihi = plothr(H)
%

ihi=diff(H(:,1));
ihi(H(:,2)<0)=NaN;
plot(H(1:end-1,1),ihi,'.-'),grid
plot(H(1:end-1,1),medianfilter(ihi,3),'.-'),grid
ihi(:,2) = H(1:end-1,1) ;
