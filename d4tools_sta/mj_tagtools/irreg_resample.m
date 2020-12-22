function    [Xr,T] = irreg_resample(X,t)
%
%     [Xr,T] = irreg_resample(X,t)
%     Resample irregularly sampled sensor data.
%     X is the sensor signal to be resampled. Can have multiple columns
%     e.g., for a triaxial sensor.
%     t is the time of each sample in X. The average sampling rate should
%     be greater than 25 Hz. Outages (times between samples > 0.2s) are 
%     allowed.
%     Returns:
%     Xr is the sensor signal resampled to 25 Hz. Outages are filled with
%     NaN.
%     T is the time of each sample in Xr in terms of the original time
%     frame.
%
%     markjohnson@st-andrews.ac.uk

FS = 25 ;      % output sampling rate
FSINT = 100 ;  % internal intermediate sampling rate
df = FSINT/FS ;      % decimation factor
LIM = 0.2 ;
Ti = (min(t)+1:1/FSINT:max(t)-1) ;   % intermediate sample time vector
Xi = interp1(t,X,Ti,'pchip') ;
Xr = decdc(Xi,FSINT/FS) ;
T = min(Ti)+(0:size(Xr,1)-1)'/FS ;

% find large outages and replace with NaN
k = find(diff(t)>LIM) ;
for kk=k',
   kkk = find(T>t(kk) & T<t(kk+1)) ;
   Xr(kkk,:) = NaN ;
end
