function    [Y,G] = lssolve3ext(X,G,method,T)

%     [X,G] = lssolve3(X)
%	   or
%     [X,G] = lssolve3(X,G)
%	   or
%     [X,G] = lssolve3(X,G,method)
%	   or
%     [X,G] = lssolve3(X,G,method,T)
%
%		Inputs:
%		X is a 3-column data matrix representing measurements of a
%		 field vector (i.e., a constant norm). X may be affected by
%		 various calibration errors and by additive noise.
%		 The objective of this function is to infer the calibration
%		 errors in X so as to return an improved estimate of the
%		 correct field vector measurements. 
%		G is the initial calibration matrix that was used to generate
%		 the incoming X. If X is uncalibrated, put [] for G.
%		method selects different calibration correction options from:
%				1 = offset only (the default if G is not given)
%				2 = offset and gain
%				3 = offset, gain and cross-terms
%		T is an optional vector of covariate measurements corresponding
%		 to each row of X. T must be a column vector with the same number
%		 of rows as X. If T is not given, no additional compensation is
%		 performed.
%
%		Returns:
%		X is the improved data matrix after calibration errors have been
%		 corrected.
%		G is a matrix of calibration corrections. The first three columns
%		 form a 3x3 matrix of gains and cross-terms. If method=1, this
%		 matrix will be the identity matrix. If method=2, the matrix will
%		 be diagonal. The next column of G is a vector of offsets. If a 
%		 covariate vector or matrix T is given, G will have an additional 
%      column for each column of T giving the multiplier for that covariate
%      in each axis of M. If an input G is given, the output G will contain 
%		 both the input and output calibrations as a single compound calibration.
%
%		The function uses a locally linearized least-squares formulation 
%		so may need to be run iteratively several times until converged. 
%		See spherical_ls.m for an example.
%
%		markjohnson.st-andrews.ac.uk
%		21 May 2018

Xscf = 2*nanmean(abs(X(:))) ;  % X scaling to control condition
X = X*(1/Xscf) ;
	
if nargin<3 || isempty(method),
	method = 1 ;
end

if nargin<4,
	T = [] ;
end
	
if nargin<2 || isempty(G),
	G = eye(3,3) ;
end

if size(G,2)<4+size(T,2),
   G(:,end+1:4+size(T,2)) = 0 ;
end

kg = find(all(~isnan(X),2)) ;
norig = size(X,1) ;
X = X(kg,:) ;
bsq = sum(X.^2,2) ;
XX = [2*X ones(length(kg),1)];        % regressor for dc offsets and magnitude
if ~isempty(T),
	Tu = T(kg,:) ;
   mT = mean(Tu) ;
   T = Tu-repmat(mT,size(Tu,1),1) ;   % pivot the covariates to keep condition down
   Tscf = 1./mean(abs(T)) ;
   T = repmat(Tscf,size(T,1),1).*T ;
   for k=1:size(T,2),
      XX = [2*X.*repmat(T(:,size(T,2)-k+1),1,3) XX] ;
   end
end	

if method>1,
   XX = [2*X(:,1:2).^2 XX];
   if method>=3,
      XX = [2*[X(:,1).*X(:,2) X(:,1).*X(:,3) X(:,2).*X(:,3)] XX];
   end
end

% formulate and solve the least squares equation
RR = XX'*XX ;
%[cond(RR) sum(XX.^2)]
c = cond(RR) ;
if c>1e6,
   fprintf(' Warning: condition is poor (%e), results may be unreliable\n',c) ;
end
P = sum(repmat(bsq,1,size(XX,2)).*XX) ;
H = -inv(RR)*P' ;
R = eye(3) ;

% interprete the results
if method>1,
   if method>=3,
		% distribute the cross-terms between the axes:
		% the distribution is done so as to allow G to be factored
		% into a diagonal gain matrix and a symmetric cross-term matrix
		% to match the way that cross-terms are applied by do_cal
		gg = 1+[H(4:5);0] ;
		cc = H(1:3)./[gg(1)+gg(2);gg(1)+gg(3);gg(2)+gg(3)] ;
      R = R + [0 cc(1:2)';cc(1) 0 cc(3);cc(2:3)' 0] ;
		H = H(4:end) ;
   end
   R = diag(1+[H(1:2);0])*R ;
	H = H(3:end) ;
   X = X*R ;
   G(:,1:3) = G(:,1:3)*R ;
end

H = H*Xscf ;
X = X*Xscf ;
if ~isempty(T),
   H = reshape(H(1:end-1),3,[]) ;
   D = H(:,end) ;          % dc offsets
   H = H(:,1:end-1).*repmat(Tscf,3,1) ;  % correct for temperature scaling
   for k=1:size(H,2),
      G(:,4+k) = R*G(:,4+k)+H(:,k) ;
      X = X + Tu(:,k)*H(:,k)' ;
      D = D-H(:,k)*mT(k) ;  % correct for temperature mean removal
   end
else
   D = H(1:3) ;
end

G(:,4) = R*G(:,4)+D ;
X = X + repmat(D',length(kg),1);
Y = repmat(NaN,norig,3) ;
Y(kg,:) = X ;
return
