function    [G,Y] = spherical_cal(X,n,method,V)
%
%     [G,Y] = spherical_cal(X)
%		or
%     [G,Y] = spherical_cal(X,n)
%		or
%     [G,Y] = spherical_cal(X,n,method)
%		or
%     [G,Y] = spherical_cal(X,n,method,V)
%		Deduce the calibration constants for a triaxial field sensor,
%		such as an accelerometer or magnetometer, based on movement data.
%		This can be used to do a 'bench' calibration of a sensor or to
%		adjust a calibration for field data.
%
%		Inputs:
%     X is the segment of triaxial sensor data to calibrate. It must
%		 be a 3-column matrix. X can come from any triaxial field sensor
%		 and can be in any unit and any frame.
%     n is the target field magnitude e.g., 1.0 for accelerometer 
%      data using g as the unit. n is in the required units.
%     method selects the calibration procedure from the following
%		 options. The default is to calibrate for offset and scaling only.
%      'gain' adjust gain of axes 2 and 3 relative to 1.
%      'cross' adjust gain and remove cross-axis correlations
%		V is a vector or matrix of explanatory variables, e.g., pressure or
%		 temperature. V must have the same number of rows (samples) as X.
%
%		Results:
%     G is the calibration structure containing fields POLY, CROSS
%		 and AUX.
%     Y is the matrix of converted sensor values
%
%		The function reports the residual and the axial balance of the data.
%		A low residual e.g., <5% indicates that the data can be calibrated
%		well and there is not much noise. The axial balance indicates whether
%		the movement in X is suitable for data-driven calibration. If the
%		movement covers all directions fairly equally, the axial balance will
%		be high. A balance <20% may lead to unreliable calibration. For bench
%		calibrations, a high axial balance is achieved by rotating the sensor
%		through the full 3-dimensions.
%		Sampling rate and frame of Y are the same as the input data so Y
%		has the same size as X. The units of Y are the same as the units used for n. 
%		If n is not specified, the units of Y are the same as for the input data.
%		It is a good idea to low-pass filter and/or remove outliers from
%		the sensor data before using this function to reduce errors from 
%		specific acceleration and sensor noise. 
%
%		Example:
%		 C = spherical_cal()
% 	    returns: C=?.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

G = []; Y=[];
if nargin<1,
	help spherical_cal
	return
end

if nargin<2,
	n = [] ;
end
	
if nargin<3,
	method = [] ;
end
		
if nargin<4,
	V = [] ;
else		% remove offset and normalize V to avoid condition problems 
   if isempty(n),
      vs = [mean(V);1./std(V)] ;
   else
      vs = [mean(V);n./std(V)] ;
   end
	V = repmat(vs(2,:),size(V,1),1).*(V-repmat(vs(1,:),size(V,1),1)) ;
end

% remove any rows in X and V with NaNs
k = find(all(~isnan(X),2)) ;
X = X(k,:) ;
if ~isempty(V),
   V = V(k,:) ;
end

nv1 = 3*(1+size(V,2)) ;		% number of variables for offset
nv2 = nv1+2 ;					% number of variables for gain and offset
nv3 = nv2+3 ;					% number of variables for gain, offset and cross

% start by estimating offsets using linear least squares. This ensures
% that the iterative search starts fairly close to a solution.
bsq = sum(X.^2,2) ;
XX = [2*X ones(size(X,1),1)];
R = oprod(XX) ;
P = sum(repmat(bsq,1,4).*XX) ;
H = -inv(R)*P' ;
offs = H(1:3) ;
X = X+repmat(offs',size(X,1),1) ;

% now try up to three calibration scenarios using simplex search
C = zeros(nv3,3) ;
C(1:nv1,1) = fminsearch(@(c) ccost(c,X,V),zeros(nv1,1)) ;		% offset only cal

if strcmp(method,'gain') | strcmp(method,'cross'),
	C(1:nv2,2) = fminsearch(@(c) ccost(c,X,V),C(1:nv2,1)) ;	% offset and gain cal
end

if strcmp(method,'cross'),
	C(:,3) = fminsearch(@(c) ccost(c,X,V),C(:,2)) ;		% offset, gain and cross cal
end

[m,k] = min(ccost(C,X,V)) ;  		% pick the best performer
C = C(:,k) ;
[Y,C] = appcal(X,V,C) ;		% apply the calibration
nn = norm2(Y) ;
fprintf('Residual: %2.1f%%\n',100*std(nn)/mean(nn)) ;
R = oprod(Y) ;
fprintf('Axial balance: %2.1f%%\n',100/cond(R)) ;

if ~isempty(n),
   sf = n/mean(nn) ;
   Y = Y*sf ;
else
	sf = 1 ;
end

G.poly = [(1+C(:,end-1))*sf (offs+C(:,1))*sf] ;
G.cross = 0.5*[2 C(1,end) C(3,end);C(1,end) 2 C(2,end);C(3,end) C(2,end) 2] ;
if ~isempty(V),
	G.aux = (C(:,1+(1:size(V,2))).*repmat(vs(2,:),3,1))*sf ;
	G.auxoffs = vs(1,:) ;
end
return


function		p = ccost(C,X,V)
for k=1:size(C,2),
	n = sqrt(sum(appcal(X,V,C(:,k)).^2,2)) ;
	p(k) = std(n)/mean(n) ;
end
return


function    [Y,C] = appcal(X,V,C)
% C is a vector of up to 8+3*size(V,2) parameters
% Only the first of these may be provided - the remainder are 0.
nc = 8+3*size(V,2) ;
C(length(C)+1:nc) = 0 ;
C = [C(1:end-5);0;C(end+(-4:0))] ;		% add the col1 fixed gain of 0
C = reshape(C,3,[]) ;
%	At this point:
%	C(:,1) are the offsets for each column of X
%	C(:,1+(1:size(V,2))) are the multipliers for the auxiliary vectors (the columns of V)
%	C(:,end-1) are the gain adjustments for each column of X (column 1 is always 0)
%	C(:,end) are the cross terms

Y = X*diag(1+C(:,end-1))+repmat(C(:,1)',size(X,1),1) ;
for k=1:size(V,2),
	Y	= Y + V(:,k)*C(:,k+1)' ;
end
xcm = 0.5*[2 C(1,end) C(3,end);C(1,end) 2 C(2,end);C(3,end) C(2,end) 2] ;
Y = Y*xcm ;
return


function    R = oprod(A)
R = zeros(size(A,2)) ;
for k=1:size(A,1),
   R = R+A(k,:)'*A(k,:) ;
end
