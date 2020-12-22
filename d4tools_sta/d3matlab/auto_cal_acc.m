function    [A,cal] = auto_cal_acc(A,fs,cal)

%     [A,cal] = auto_cal_acc(A)					% A is a sensor structure
%		or
%     [A,cal] = auto_cal_acc(A,cal)				% A is a sensor structure
%		or
%     [A,cal] = auto_cal_acc(A,fs)				% A is a matrix
%		or
%     [A,cal] = auto_cal_acc(A,fs,cal)			% A is a matrix


if nargin<1,
	help auto_cal_acc
	return
end
	
if isstruct(A),
	[Ad,fsd] = sens2var(A) ;
	if nargin>1,
		cal = fs ;
	else
		cal = [] ;
	end
else
	if nargin<2 || isstruct(fs),
		fprintf(' Sampling rate is required with matrix data\n') ;
		return
	end
	if nargin<3,
		cal = [] ;
	end
	Ad = A ;
	fsd = fs ;
end

if fsd>5,
   df = ceil(fsd/5) ;
   Ad = decdc(Ad,fsd) ;
   fsd = fsd/df ;
end

fstr = 9.81 ;		% earth's gravitational acceleration in m/s2
Ad = crop(Ad,fsd) ;

if isempty(cal),
	cal.poly = [1 0;1 0;1 0] ;
else
	if isfield(cal,'POLY'),
		cal.poly = cal.POLY ;
		cal = rmfield(cal,'POLY') ;
	end
end

J = conv(ones(5,1),njerk(Ad,fsd)) ;
J = J(2+(1:size(Ad,1))) ;
nn = sum(~isnan(J)) ;
pp = min(10,max(1,5e6/nn)) ;
thr = prctile(J,pp) ;
k = find(J<thr) ;
AA = Ad(k,:) ;

[AA,cc,sigma] = spherical_ls(AA,fstr,cal,2) ;

% update CAL
if sigma(2)>=sigma(1),
	fprintf(' Deviation not improved (was %3.2f%%, now %3.2f%%) - check data\n',sigma*100) ;
	return
end

fprintf(' Deviation improved from %3.2f%% to %3.2f%%\n',sigma*100) ;
cal = cc;

% apply cal to the complete accelerometer signal

if isstruct(A),
	if ~isfield(A,'history') || isempty(A.history),
		A.history = 'auto_cal_acc' ;
	else
		A.history = [A.history ',auto_cal_acc'] ;
	end
end

A=do_cal(A,cal,'nomap');
