function      [v,t,bot] = kalmanbotest(D,p,fs,T,VALID)
%
%     [v,t,bot] = kalmanbotest(D,p,fs,T,VALID)
%     Estimate a smooth depth and depth rate to fit observed 
%     TWTT from whale to bottom in matrix D. Use echotool to get bottom
%     echo times. p is the whale depth in m, sampled at rate fs, Hz.
%     T is the output sampling interval in seconds. Default is 1 s.
%     Optional argument VALID is the number of seconds that a bottom
%     TWTT is considered valid. Default value is 20s. Gaps in the bottom
%     echoes of more than 2xVALID will not be interpolated.
%
%     Process is a 2-state Kalman filter estimating bottom depth and rate
%     of change, followed by a Rauch smoother.
%     Output:
%     v = [bottom_depth_rate, bottom_depth] in m/s and m.
%     t is the vector of cues corresponding to the estimates in v.
%     bot is a matrix of [traw,braw] where traw is the time of each echo
%     reported in D and braw is the corresponding raw bottom depth.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     December 2010

v = [] ;
if nargin<3,
   help kalmanbotest
   return
end

if nargin<4 | isempty(T),
   T = 1 ;
end

if nargin<5,
   VALID = 20 ;
end

GAP = VALID*2 ;
INT = VALID ;
if iscell(D),
   D = vertcat(D{:}) ;
end
[td,I] = sort(D(:,1)) ;
D = D(I,:) ;
t = D(1,1):T:D(end,1) ;
bot=p(round(fs*D(:,1)))+D(:,2)*1500/2;

r = 1.5^2 ;          % measurement noise cov. - this should be set equal to the noise power
                     % in the depth estimate, p, e.g., 0.05 m^2. was 0.005
q1 = (0.005*T)^2 ;   % speed state noise cov. - accounts for variations in speed, was 0.05
q2 = (0.15*T)^2 ;   % depth state noise cov. - accounts for errors in pitch angle, was 0.05
q2 = (0.05*T)^2 ;

% vector Kalman filter with 2 states: s and p

A = [1 0;T 1] ;         % state transition matrix
shatm = [0;bot(1)] ;      % starting state estimate
Q = [q1 0;0 q2] ;       % state noise matrix
H = [0 1] ;             % observation vector
Pm = [0.1 0;0 r] ;      % initial state covariance matrix:
                        % says how much we trust initial values of s and p?

skal = zeros(2,length(t)) ;    % place to store states
srau = skal ;
Ps = zeros(2,2,length(t)) ;
Pms = Ps ;

for k=1:length(t),             % Kalman filter
   if k>1,
      Pm = A*P*A' + Q ;      % update a priori state cov
      shatm = A*shat ;          % a priori state estimate
   end

   kk = find(D(:,1)>=t(k)-T/2 & D(:,1)<t(k)+T/2) ;
   n = length(kk) ;
   if n>0,
      bhat = shatm(1)*(D(kk,1)-t(k))+shatm(2) ;
      e = bot(kk)-bhat ;
      K = Pm*H'/(H*Pm*H'+r/n) ;    % compute kalman gain
      shat = shatm + K*mean(e) ;  % a posteriori state estimate
      shat(2) = max(shat(2),0) ;       % depth must always be positive
      P = (eye(2)-K*H)*Pm ;      % a posteriori state cov
   else
      shat = shatm ;
      P = Pm ;
   end

   skal(:,k) = shat ;         % store results of iteration
   Pms(:,:,k) = Pm ;
   Ps(:,:,k) = P ;
end

%v = skal' ;
%return

%Vh is P(T)
srau(:,length(t)) = shat ;

for k=length(t):-1:2,                % Kalman/Rauch smoother
   K = Ps(:,:,k-1)*A'*inv(Pms(:,:,k));   % smoother gain
   srau(:,k-1) = skal(:,k-1)+K*(srau(:,k)-A*skal(:,k-1)) ; % smooth state
end

v = srau' ;
k = skal' ;

kk = find(diff(D(:,1))>GAP) ;
for k=1:length(kk),
   kn = find(t>D(kk(k),1)+INT & t<D(kk(k)+1,1)-INT) ;
   v(kn,:) = NaN ;
end

bot = [D(:,1) bot] ;


