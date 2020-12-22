function      [v,k] = kalmanBest(Aw,Mw,fs)
%
%     [v,k] = kalmanBest(Aw,Mw,fs)
%     Estimate a smooth depth and depth rate to fit the observed depth, p, in m.
%     sampled at rate fs, Hz. Process is a 2-state Kalman
%     filter estimating vertical rate and depth, followed by a Rauch smoother.
%     Output:
%     v = [depth_rate, depth] in m/s and m.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     November 2010

v = [] ;
if nargin<3,
   help kalmanBest
   return
end

r = [0.02 1] ;       % measurement noise cov. - this should be set equal to the noise power
                     % in the b and alpha estimates
q1 = (0.03/fs)^2 ;   % b state noise cov. - accounts for variations in field intensity
q2 = (0.03/fs)^2 ;   % alpha state noise cov. - accounts for errors in field inclination

% target functions
Y = [norm2(Mw) Mw.*Aw*[1;1;1]] ;
aexsq = (norm2(Aw)-1).^2 ;

% vector Kalman filter with 2 states: b, alpha

% transition and observation matrices are eye(2)
shat = mean(Y)' ;      % starting state estimate
Q = [q1 0;0 q2] ;       % state noise matrix
P = cov(Y) ;         % initial state covariance matrix:
                   % says how much we distrust initial values of b and alpha

n = size(Mw,1) ;
skal = zeros(2,n) ;    % place to store states
srau = skal ;
Ps = zeros(2,2,n) ;
Pms = Ps ;

for k=1:n,             % Kalman filter
   Pm = P + Q ;      % update a priori state cov
   R = [r(1) 0;0 r(2)+aexsq(k)] ;
   K = Pm*inv(Pm+R) ;    % compute kalman gain
   shat = shat + K*(Y(k,:)'-shat) ;  % a posteriori state estimate
   P = (eye(2)-K)*Pm ;      % a posteriori state cov

   skal(:,k) = shat ;         % store results of iteration
   Pms(:,:,k) = Pm ;
   Ps(:,:,k) = P ;
end

%Vh is P(T)
srau(:,n) = shat ;

for k=n:-1:2,                % Kalman/Rauch smoother
   K = Ps(:,:,k-1)*inv(Pms(:,:,k));   % smoother gain
   srau(:,k-1) = skal(:,k-1)+K*(srau(:,k)-skal(:,k-1)) ; % smooth state
end

v = srau' ;
k = skal' ;
