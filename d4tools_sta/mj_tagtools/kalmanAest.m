function      [v,k,balpha] = kalmanAest(Aw,Mw,fs,balpha)
%
%     [v,k] = kalmanAest(Aw,Mw,fs)
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
   help kalmanAest
   return
end

r = 1*[0.001 0.001] ;  % measurement noise cov. - this should be set equal to the noise power
                     % in the depth estimate, p, e.g., 0.05 m^2. was 0.005
Q = 0.001*eye(3) ;

% normalize the magnetometer
if nargin<4,
   balpha = kalmanBest(Aw,Mw,fs) ;
end
Mw = Mw.*repmat(balpha(:,1).^(-1),1,3) ;

% make the target vector
Y = [balpha(:,2)./balpha(:,1) Aw] ;
aexsq = (norm2(Aw)-1).^2 ;

% vector Kalman filter with 3 states: Ahat

shat = Aw(1,:)' ;      % starting state estimate
P = 0.01*eye(3) ;       % initial state covariance matrix:
                        % says how much we distrust initial value of A
n = size(Aw,1) ;
skal = zeros(3,n) ;    % place to store states
srau = skal ;
Ps = zeros(3,3,n) ;
Pms = Ps ;

for k=1:n,             % Kalman filter
   Pm = P + Q ;      % update a priori state cov
   R = diag([r(1) (r(2)+aexsq(k))*ones(1,3)]) ;
   H = [Mw(k,:);eye(3)] ;             % observation matrix
   K = Pm*H'*inv(H*Pm*H'+R) ;    % compute kalman gain
   shat = shat + K*(Y(k,:)'-H*shat) ;  % a posteriori state estimate
   shat = shat/norm2(shat) ;       % A must be unit norm
   P = (eye(3)-K*H)*Pm ;      % a posteriori state cov

   skal(:,k) = shat ;         % store results of iteration
   Pms(:,:,k) = Pm ;
   Ps(:,:,k) = P ;
end

%Vh is P(T)
srau(:,n) = shat ;

for k=n:-1:2,                % Kalman/Rauch smoother
   K = Ps(:,:,k-1)*inv(Pms(:,:,k));   % smoother gain
   shat = skal(:,k-1)+K*(srau(:,k)-skal(:,k-1)) ; % smooth state
   srau(:,k-1) = shat/norm2(shat) ;       % A must be unit norm
end

v = srau' ;
k = skal' ;
