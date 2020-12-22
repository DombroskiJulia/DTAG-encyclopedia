function    [Y,G] = lssolve3(X,G,method,T)

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
%           4 = offset, gain and cross-terms, and temperature scaling
%		T is an optional vector of temperature measurements corresponding
%		 to each row of X. T must be a column vector with the same number
%		 of rows as X. If T is not given, no temperature compensation is
%		 performed.
%
%		Returns:
%		X is the improved data matrix after calibration errors have been
%		 corrected.
%		G is a matrix of calibration corrections. The first three columns
%		 form a 3x3 matrix of gains and cross-terms. If method=1, this
%		 matrix will be the identity matrix. If method=2, the matrix will
%		 be diagonal. The next column of G is a vector of offsets. If a 
%		 temperature vector is given, G will have an additional two columns
%		 containing the temperature scale factor and temperature offset for
%		 each axis. If an input G is given, the output G will contain both 
%		 the input and output calibrations as a single compound calibration.
%
%		The function uses a locally linearized least-squares formulation 
%		so should be run iteratively several times until converged. 
%		See spherical_ls.m for an example.
%
%		markjohnson.st-andrews.ac.uk
%		21 May 2018

Xscf = 2*nanmean(abs(X(:))) ;  % X scaling to control condition
X = X*(1/Xscf) ;

if nargin<2 || isempty(G),
	G = eye(3,4) ;
end
	
if nargin<3 || isempty(method),
	method = 1 ;
end

if nargin<4,
	T = [] ;
end
	
kg = find(all(~isnan(X),2)) ;
norig = size(X,1) ;
X = X(kg,:) ;
bsq = sum(X.^2,2) ;
XX = [2*X ones(length(kg),1)];      
if ~isempty(T),
	Tu = T(kg) ;
   mT = mean(Tu) ;
   T = Tu-mT ;     % pivot the temperature to keep condition down
   Tscf = 1/mean(abs(T)) ;
   T = Tscf*T ;
   if method==4,
      XX = [2*X.^2.*repmat(T,1,3) 2*X.*repmat(T,1,3) XX] ;
   else
   	XX = [2*X.*repmat(T,1,3) XX] ;
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
   if length(H)>=9,     % this part needs to be fixed for temperature pivoting
   	if size(G,2)>4,
         G(:,5) = R*G(:,5)+H(1:3) ;
         G(:,6) = R*G(:,6)+H(4:6) ;
      else
         G(:,5) = H(1:3) ;
         G(:,6) = H(4:6) ;
      end
      X = X + X.*(T*H(1:3)') + T*H(4:6)' ;
      H = H(7:end) ;
   else                 % end need for fixing
      H(1:3) = H(1:3)*Tscf ;  % correct for temperature scaling
   	if size(G,2)>4,
         G(:,5) = R*G(:,5)+H(1:3) ;
      else
         G(:,5) = H(1:3) ;
      end
      X = X + Tu*H(1:3)' ;
      H = H(4:6)-H(1:3)*mT ;  % correct for temperature mean removal
   end
end

G(:,4) = R*G(:,4)+H(1:3) ;
X = X + repmat(H(1:3)',length(kg),1);
Y = repmat(NaN,norig,3) ;
Y(kg,:) = X ;
return
