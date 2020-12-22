function       [S,CR,nl] = kalmanechotracker(R,st,box,opts)
%
%     [S,CR,nl] = kalmanechotracker(R,st,box,OPTS)
%     EXPERIMENTAL !!
%     Propogate an echo trackline in an echogram from a start point. 
%     Process is a 2-state Kalman filter estimating opening speed and 
%     distance, followed by a Rauch smoother.
%     R is a cell array of: R{1}: range bin vector, R{2}: time bin vector
%        R{3}: image in dB
%     st is a point on the track to start from
%        st = [time index of start point, range of start point]
%     box is an optional bounding box for the track:
%        box = [min_time_index,max_time_index]
%     OPTS structure can contain:
%        .sigma acceleration standard deviation m/s^2
%        .winsz window size to search in m
%        .snr SNR threshold in dB
%        .maxout maximum number of consecutive outages before track is
%        abandoned
%        .measnoise measurement noise in m
%     Output: S has a row for each line in R that is tracked. Columns are:
%           1. line (click) number
%           2. time
%           3. kalman speed estimate
%           4. kalman range estimate
%           5. rauch speed estimate
%           6. rauch range estimate
%
%     mark johnson
%     Last modified: Sept 2010

OPTS.maxout = 3 ;
OPTS.sigma = 30 ;       % m/s2
OPTS.winsz = 0.12 ;     % m
OPTS.snr = 4 ;          % dB
OPTS.measnoise = 0.03 ; % m
OPTS.maxsnr = 100 ;     % dB

if nargin==4 & ~isempty(opts),
   OPTS = mergeopts(opts,OPTS) ;
end

D = R{1} ;     % distance to each row in the image
dinc = [mean(diff(D)) D(1)] ;      % assume equal distance bins in image
T = R{2} ;     % time of each column in the image
R = R{3} ;     % echo image length(D)xlength(T)

if nargin>=3 & ~isempty(box),
   % trim the image, time and range vectors to box the track
   box = sort(box) ;
   k = round(box(1)):round(box(2)) ;
   if length(k)<=1,
      S = [] ; CR = [] ; nl = [] ;
      return
   end
   R = R(:,k) ;
   T = T(k) ;
   st(1) = st(1)-k(1)+1 ;
else
   box = 1 ;
end

%nl = median(R(:))      % background noise level estimate
nl = prctile(R(:),25) ;
snrthr = OPTS.snr ;
R = R-(snrthr+nl) ;
R(R<0) = 0 ;
R(R>OPTS.maxsnr) = OPTS.maxsnr ;
st(1) = max(1,round(st(1))) ;

% work out the starting point and state
cr = findcentroid(R(:,st(1)),st(2),OPTS.winsz,dinc) ; 
if isnan(cr),
   fprintf('No clear echo at starting point\n') ;
   S = [] ; CR = [] ;
   return
end

Sst = [0;cr(1)] ;             % starting state: 0 speed, centroid position
P0 = 10*[1 0;0 cr(2)^2] ;     % starting covariance: speed is high, position is low

% first work kalman prediction back from the starting point if needed
if st(1)>1,
   td = diff(T(st(1)+1:-1:1)) ;
   [S,kend,Ps] = kalman_pred(td,R(:,st(1):-1:1),Sst,P0,OPTS,dinc) ;
   st(1) = st(1)-kend+1 ;
   P0 = Ps(:,:,kend) ;
   Sst = S(:,kend) ;
end

% forward kalman - rauch from the beginning of the track using the final state
% and covariance of the backwards kalman.
td = diff(T(st(1):end)) ;
td = [td(1);td] ;
%[S,kend,Ps,Pms,CR] = kalman_pred(td,R(:,st(1)+1:end),Sst,P0,OPTS,dinc) ;
[S,kend,Ps,Pms,CR] = kalman_pred(td,R(:,st(1)+0:end),Sst,P0,OPTS,dinc) ;
S = S(:,1:kend) ;
Sr = rauchsmooth(S,Ps,Pms,td(1:kend)) ;
%k = st(1)+(1:kend)';
k = st(1)-1+(1:kend)';
S = [k+box(1)-1 T(k) S' Sr'] ;
return


function    [S,k,Ps,Pms,CR] = kalman_pred(td,R,shat,P,OPTS,dinc)
%
% forward kalman predictor with 2 states: s and d
%

S = zeros(2,length(td)) ;        % place to store states
Ps = zeros(2,2,length(td)) ;
Pms = Ps ;
r = OPTS.measnoise^2 ;           % fixed echo ranging error
H = [0 1] ;                      % observation vector
Q = zeros(2) ;
A = eye(2) ;
CR = zeros(3,length(td)) ; ;
lastk = 0 ;

for k=1:length(td),             % Kalman filter
   A(2,1) = td(k) ;          % state transition matrix
   Q(1,1) = (OPTS.sigma*td(k))^2 ;   % state noise matrix
   Pm = A*P*A' + Q ;            % update a priori state cov
   shatm = A*shat ;             % a priori state estimate

   % get observation
   cr = findcentroid(R(:,k),shatm(2),OPTS.winsz,dinc) ;
   if cr(2)>OPTS.winsz/2,
      cr(1) = NaN ;
   end

   if ~isnan(cr(1)),                 % if there is a valid measurement in this block
      K = Pm*H'/(H*Pm*H'+r) ;    % compute kalman gain
      shat = shatm + K*(cr(1)-H*shatm) ;  % a posteriori state estimate
      P = (eye(2)-K*H)*Pm ;      % a posteriori state cov
      lastk = k ;
   else
      P = Pm ;
      shat = shatm ;
      if k-lastk>OPTS.maxout,
         k = lastk ;
         S = S(:,1:k) ;
         Pms = Pms(:,:,1:k) ;
         Ps = Ps(:,:,1:k) ;
         CR = CR(:,1:k) ;
         return
      end
   end
   S(:,k) = shat ;         % store results of iteration
   Pms(:,:,k) = Pm ;
   Ps(:,:,k) = P ;
   CR(:,k) = cr' ;
end
return


function    S = rauchsmooth(skal,Ps,Pms,td)
%
% backwards (Rauch) smoother
%

m = size(skal,1) ;
n = length(td) ;
S = [zeros(m,n-1) skal(:,end)] ;
Ap = [1 0;td(n) 1] ;
for k=n:-1:2,                % Kalman/Rauch smoother
   A = [1 0;td(k-1) 1] ;                        % state transition matrix
   K = Ps(:,:,k-1)*A'*inv(Pms(:,:,k));          % smoother gain
   S(:,k-1) = skal(:,k-1)+K*(S(:,k)-Ap*skal(:,k-1)) ; % smooth state
   Ap = A ;
end

return


function    c = findcentroid(x,p,winsz,scf)
%
%  find the centroid of x in a window of +/- winsz pixels around point p
%

p = (p-scf(2))/scf(1) ;             % convert to pixels
winsz = winsz/scf(1) ;
lhs = max(p-winsz,1) ;
rhs = min(p+winsz,length(x)) ;
k = round(lhs):round(rhs) ;
%xx = x(k).^2 ;
xk = x(k) ;
xx = 10.^(2*xk) ;
xx(xk==0) = 0 ;
if isempty(k) | max(xx)==0,
   c = NaN*[1 1 1] ;
   return ;
end
c = sum(xx.*k')/sum(xx) ;
tms = sum(xx.*(k'.^2))/sum(xx) ;
c(2) = scf(1)*sqrt(tms-c(1)^2) ;
c(1) = scf(1)*c(1)+scf(2) ;
c(3) = max(xk) ;
return

