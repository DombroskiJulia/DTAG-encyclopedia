function		[XX,cal,sigma] = spherical_ls(X,fstr,cal,method,T)

%		[X,cal,sigma] = spherical_ls(X,fstr,cal,method,T)
%		Least squares solver for spherical data used by auto_cal_acc and
%		auto_cal_mag.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: July 2018


if nargin<3,
	g = eye(3,4) ;
else
	g = [diag(cal.poly(:,1)),cal.poly(:,2)] ;
end

if nargin<4,
	method = 1 ; 
end
	
if nargin<5,
	T = [] ; 
end

if ~isfield(cal,'tref'),
	cal.tref = 20 ;
end

method = min(method,3) ;	% prevent temperature scale factor for now

nn = norm2(X) ;
sigma(1) = nanstd(nn)/nanmean(nn) ;
XX = X*g(:,1:3)+repmat(g(:,4)',size(X,1),1) ;	% apply initial cal

for k=1:4,
	[XX,g] = lssolve3(XX,g,method,T-cal.tref);		% solve for gain and/or cross
end

cr = inv(diag(diag(g)))*g(:,1:3) ;
g(:,1:3) = diag(diag(g))*0.5*(cr+cr') ;		% make sure cross terms are applied symmetrically

if nargin>=2 && ~isempty(fstr),
	scf = fstr/nanmean(norm2(XX)) ;
	XX = XX*scf ;
else
	scf = 1 ;
end

cal.cross = inv(diag(diag(g)))*g(:,1:3) ;
g(:,4) = inv(cal.cross)*g(:,4) ;
cal.poly = scf*[diag(g) g(:,4)] ;

if ~isempty(T),
	cal.tcomp = scf*inv(cal.cross)*g(:,5) ;
end

nn = norm2(XX) ;
sigma(2) = nanstd(nn)/nanmean(nn) ;

% below lines just to check that cal is correctly updated
%X = do_cal(X,1,cal,'nomap','T',T) ;
%nn = norm2(X) ;
%[sigma(2),nanstd(nn)/nanmean(nn)]	% should be the same
