function      [X,Y] = kalman_avp(t,p)
%
%     X = kalman_avp(t,p)
%     Estimate a smooth depth and depth rate to fit the observed depth, p, in m.
%     sampled at rate fs, Hz. Process is a 2-state Kalman
%     filter estimating vertical rate and depth, followed by a Rauch smoother.
%     Output:
%     X = vertical [acc speed position] in m/s2, m/s and m.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     November 2012

X = [] ; Y = [] ;
if nargin<2,
   help kalman_avp
   return
end

ts = diff(t) ;      % sampling intervals
r = 0.001 ;         % measurement noise cov. - this should be set equal to the noise power
                    % in the depth estimate, p, e.g., 0.05 m^2. was 0.005
q1 = (0.01*ts(1))^2 ;   % acceleration state noise cov. - accounts for variations in speed, was 0.05
q2 = (0.01*ts(1))^2 ;   % speed state noise cov. - accounts for variations in speed, was 0.05
q3 = (0.01*ts(1))^2 ;   % depth state noise cov. - accounts for errors in pitch angle, was 0.05

% vector Kalman filter with 3 states: a, v and p
A = repmat(eye(3,3),[1,1,length(ts)]) ;      % state transition matrix - add in sampling interval at each time step
A(2,1,:) = ts ;
A(3,2,:) = ts ;

shatm = [0;(p(2)-p(1))/ts(1);p(1)] ;      % starting state estimate
Q = diag([q1 q2 q3]) ;       % state noise matrix
H = [0 0 1] ;             % observation vector
Pm = diag([0.01 0.01 r]) ;     % initial state covariance matrix:
                        % says how much we trust initial values of a, v and p

skal = zeros(3,length(p)) ;    % place to store states
srau = skal ;
Ps = zeros(3,3,length(p)) ;
Pms = Ps ;

for k=1:length(p),             % Kalman filter
   if k>1,
      AA = A(:,:,k-1) ;
      Pm = AA*P*AA' + Q ;      % update a priori state cov
      shatm = AA*shat ;          % a priori state estimate
   end
   K = Pm*H'/(H*Pm*H'+r) ;    % compute kalman gain
   shat = shatm + K*(p(k)-H*shatm) ;  % a posteriori state estimate
   P = (eye(3)-K*H)*Pm ;      % a posteriori state cov

   skal(:,k) = shat ;         % store results of iteration
   Pms(:,:,k) = Pm ;
   Ps(:,:,k) = P ;
end

%Vh is P(T)
srau(:,length(p)) = shat ;

for k=length(p):-1:2,                % Kalman/Rauch smoother
   AA = A(:,:,k-1) ;
   K = Ps(:,:,k-1)*AA'*inv(Pms(:,:,k));   % smoother gain
   srau(:,k-1) = skal(:,k-1)+K*(srau(:,k)-AA*skal(:,k-1)) ; % smooth state
end

X = srau' ;
Y = skal' ;
