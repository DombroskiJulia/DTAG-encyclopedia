function    [p,t,rr,L] = refineposn(svp,p,del,t)
%
%    [p,t,rr] = refineposn(svp,clkerr,p,del)
%     svp is sv information from svposns
%     clkerr is sv clock errors in seconds
%     p is starting estimate of receiver position in ECEF
%     del is code delays in chips
%
%     p is the refined position in ECEF
%     t is the time offset estimate
%     rr is the RMS pseudo-range residual in meters
%     L is the pseudo-range errors for each sv

C = 299792458 ;
if nargin<4,
   t = 0 ;
end

THR = C*512/1023e3 ;
FSCALE = C*0.001 ;

% TODO: need to check that tropospheric delay correction is correct
pr_corrs = -2.4./sin(svp(:,7)) - svp(:,8)*C ;

pr = C*del(:)/1023e3 ;

[r,DD] = rotrange(svp(:,1:3),p) ;
rc = r + t*C + pr_corrs ;
L = moddiff(rc,FSCALE,THR,pr) ;
A = [DD -ones(size(svp,1),1)] ;
dR = pinv(A)*L ;
p = p+dR(1:3)' ;
t = t+dR(4)/C ;

r = rotrange(svp(:,1:3),p) ;
rc = r + t*C + pr_corrs ;
L = moddiff(rc,FSCALE,THR,pr) ;
rr = sqrt(sum(L.^2)) ;
%fprintf('Prange residual %f m RMS\n',rr) ;
return


function    L = moddiff(r,lim,thr,pr)
%
L = mod(r,lim)-pr ;
m = L(1) ;
for k=2:length(L),
   dv = L(k)+[0 -lim lim] ;
   [mm nn] = min(abs(dv-m)) ;
   L(k) = dv(nn) ;
   m = mean(L(1:k)) ;
end
return

% old way of doing it - fails if the time offset is close
% to +/- thr.

function    L = moddiff1(r,lim,thr,pr)
%
L = mod(r,lim)-pr ;
kf = L>thr ;
L(kf) = L(kf)-lim ;
kf = L<-thr ;
L(kf) = L(kf)+lim ;
return
