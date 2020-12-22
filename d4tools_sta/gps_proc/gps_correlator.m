function    [X,del,dop] = gps_correlator(b,sv,CF,FD)
%
%    [X,del,dop] = gps_correlator(b,sv,CF,FD)
%

FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
if length(FD)==2,
   fstep = 300/FS ;           % Doppler step
   wd = 2*pi*(FD(1)/FS:fstep:FD(2)/FS) ;     % doppler test frequencies in rad/s
else
   wd = 2*pi*FD/FS ;
end

g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of CF
%g = reshape(repmat(2*ca_code(sv)-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
ng = length(g) ;
M = zeros(ng,ng) ;
M(:,1) = g ;
for k=1:ng-1,
   M(:,k+1) = circ(g,k) ;
end

X = zeros(ng,length(wd)) ;
for k=1:length(wd),
   cc = b(1:ng).*exp(j*(0:ng-1)'*wd(k)) ;  % doppler shift received signal
                                     % sign chosen to match fdoppsearchi_oa
   X(:,k) = abs(cc'*M)'.^2 ;
end

gpsperf(X,sv,1,wd*FS/2/pi) ;
