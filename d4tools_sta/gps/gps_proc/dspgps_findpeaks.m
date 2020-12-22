function    [P,D] = dspgps_findpeaks(X)

%    P = dspgps_findpeaks(X)
%

P = zeros(3,1) ;
D = zeros(3,1) ;
for k=1:3,
   [P(k) D(k)] = max(X) ;  % find next maximum in the accumulator
   X(ndel) = 0 ;
end
