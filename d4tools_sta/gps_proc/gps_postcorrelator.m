function    [X,del,dop] = gps_postcorrelator(b,sv,CF,delay,fdop)
%
%    [X,del,dop] = gps_postcorrelator(b,sv,CF,delay,fdop)
%

FC = 1575.42e6 ;           % GPS L1 carrier frequency
FS = 1023e3*CF ;           % base-band sampling rate
wd = 2*pi*fdop/FS ;

g = interp(2*ca_code(sv)-1,CF);      % interpolate C/A code by factor of CF
%g = reshape(repmat(2*ca_code(sv)-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
ng = length(g) ;
M = zeros(ng,3) ;
delay = round(delay)-1+[-CF:CF] ;
for k=1:length(delay),
   M(:,k) = circ(g,delay(k)) ;
end

b = b.*exp(j*(0:length(b)-1)'*wd) ;      % doppler shift received signal
                                     % sign chosen to match fdoppsearchi_oa
[B,z] = buffer(b,ng,0,'nodelay') ;

X = zeros(length(delay),size(B,2)) ;
for k=1:size(B,2),
   X(:,k) = B(:,k)'*M ;
end

del = 0 ; dop = 0 ;
%gpsperf(X,sv,1,wd*FS/2/pi) ;
