function    [M,cal] = auto_cal_mag(M,varargin)

%     [M,cal] = auto_cal_mag(M,cal,fstr)        % M is a sensor structure
%		or
%     [M,cal] = auto_cal_mag(M,cal,fstr,T)		% M is a sensor structure
%		or
%     [M,cal] = auto_cal_mag(M,cal,fstr,T,tc)	% M is a sensor structure
%		or
%     [M,cal] = auto_cal_mag(M,fs,cal,fstr)     % M is a matrix
%		or
%     [M,cal] = auto_cal_mag(M,fs,cal,fstr,T)	% M is a matrix
%		or
%     [M,cal] = auto_cal_mag(M,fs,cal,fstr,T,tc)	% M is a matrix
%
%		Automatic calibration of magnetometer data.
%		Inputs:
%		M is the raw (uncalibrated) magnetometer data in a matrix or sensor structure.
%		fs is the sampling rate of M. This is only needed if M is not a sensor structure.
%		cal is the calibration structure for the magnetometer (usually CAL.MAG). If there
%		 is no existing calibration, use [] for cal.
%		fstr is the local magnetic field strength in uT. To allow for the field strength
%		 changing over long deployments, fstr can also be a two-column matrix. In which 
%		 case the first column is the time in seconds into the deployment, and the second 
%		 column is the corresponding magnetic field strength.
%		T is the tag temperature data in a vector or sensor structure. If T is a vector, it
%		 must have the same sampling rate as M. If T is a sensor structure, it can have a
%		 different sampling rate to M and will automatically be interpolated. If temperature
%		 compensation is not required, T and tc can be omitted.
%		tc is the optional time constant in seconds relating the temperature at the magnetometer
%		 to the temperature at the temperature sensor. This allows for a fast changing temperature
%		 sensor close to the outside surface of the tag. For small 300 m pressure sensors,
%		 tc should be about 100 s. For steel Keller pressure sensors, tc should be omitted.
%
%		Results:
%		M is the calibrated magnetometer data. M is at the same sampling rate as the input data.
%		 If a sensor structure was input, M will also be a sensor structure.
%		cal is the updated calibration structure with added fields for the calibrations inferred
%		 from the data.
%
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: July 2018


cal = [] ; fstr = [] ; T = [] ; tc = [] ;
TSEG = 24*3600 ;        % minimum cal segment length in seconds - should be at least 1 day

if nargin<2,
	help auto_cal_mag
	return
end
	
if isstruct(M),
	[Md,fsd] = sens2var(M) ;
	nin = 1 ;
else
	if nargin<2 || isstruct(varargin{1}),
		fprintf(' Sampling rate is required with matrix data\n') ;
		return
	end
	Md = M ;
	fs = varargin{1} ;
   fsd = fs ;
	nin = 2 ;
end

if nargin>nin,
	cal = varargin{nin} ;
end

if nargin>nin+1,
	fstr = varargin{nin+1} ;
   if length(fstr)>1 && size(fstr,2)~=2,
      fprintf('Field strength must have two columns: time (s) and strength (uT)\n') ;
      return
   end
else
	fstr = 1 ;
end

if isstruct(cal),
   if isfield(cal,'POLY'),
      cal.poly = cal.POLY ;
      cal = rmfield(cal,'POLY') ;
   elseif ~isfield(cal,'poly'),
      cal.poly = [1 0;1 0;1 0] ;  
   end
else
	if ~isempty(cal),
		fprintf('CAL must be a structure - check you are using auto_cal_mag correctly\n') ;
		return
	end
   cal.poly = [1 0;1 0;1 0] ;
end

if nargin>nin+2,
	T = varargin{nin+2} ;
	if isstruct(T),
		[T,ft] = sens2var(T) ;
		if ft~=fsd,
			T = interp2length(T,ft,fsd,size(Md,1)) ;
		end
	end
	if ~isfield(cal,'tref'),
		cal.tref = 20 ;
	end
end
	
if nargin>nin+3,
	tc = varargin{nin+3} ;
	if tc<10,			% minimum temperature time constant of 10 s
		tc = [] ;
	end
end

if ~isfield(cal,'tcomp'),
	cal.tcomp = [0;0;0] ;
end

if ~isfield(cal,'cross'),
	cal.cross = eye(3) ;
end

if fsd>5,
   df = ceil(fsd/5) ;
   Md = decdc(Md,fsd) ;
   fsd = fsd/df ;
end

[Md,crp] = crop(Md,fsd) ;
nseg = max(floor(size(Md,1)/fsd/TSEG),1) ;
kseg = [(0:nseg-1)*fsd*TSEG size(Md,1)] ;
tseg = crp(1)+kseg/fsd ;

if size(fstr,2)==2,
   if fstr(1,1)>0,  % make sure first field strength value applies to start of data 
      fstr = [0 fstr(1,2);fstr] ;
   end
   if fstr(end,1)<tseg(end),     % and last value extends to end
      fstr(end+1,:) = [tseg(end),fstr(end,2)] ;
   end
   % interpolate field strengths to middle of each time segment
   fstr = interp1(fstr(:,1),fstr(:,2),tseg(1:end-1)+0.5*diff(tseg)) ;
else
	fstr = repmat(fstr,length(tseg)-1,1) ;
end

J = conv(ones(5,1),njerk(Md,fsd)) ;
J = J(2+(1:size(Md,1))) ;     % magnetometer rate of change averaged over ~1s
if ~isempty(T) 
	if ~isempty(tc),
		T = remove_nan(T) ;  % remove all the NaNs in T - they will mess up the filter
		pf = 1/(fsd*tc) ;  % pole frequency of a one-pole low-pass filter
		Td = filter(pf,[1 -(1-pf)],T,T(1)) ;
		Td = crop_to(Td,fsd,crp) ;
		cal.tconst = tc ;
	else
		Td = crop_to(T,fsd,crp) ;
	end
end

Poly = zeros(3,2,length(kseg)-1) ;
Cross = zeros(3,3,length(kseg)-1) ;
Tcomp = zeros(3,length(kseg)-1) ;
sigma = zeros(length(kseg)-1,2) ;

if exist('CHECK','var'),
	clf
	K={};
end

for k=1:length(kseg)-1,
	kk = kseg(k)+1:kseg(k+1) ;
	if ~isempty(T),
		[cc,ss,MM,kj] = cal_seg(J(kk),Md(kk,:),fstr(k),cal,Td(kk)) ;
	else
		[cc,ss,MM,kj] = cal_seg(J(kk),Md(kk,:),fstr(k),cal,[]) ;
	end
	% update CAL
	if ss(2)>=ss(1),	% if no improvement in deviation...
		ss(2) = ss(1) ;
		cc = cal ;		% continue with old cal
	end
	Poly(:,:,k) = cc.poly ;
	Cross(:,:,k) = cc.cross ;
	Tcomp(:,k) = cc.tcomp ;
	sigma(k,:) = ss ;
	
	if exist('CHECK','var'),
		plot(kj+kk(1)-1,norm2(MM),'.');hold on
		K{k}=[kj+kk(1)-1 norm2(MM)];
	end
end

if size(sigma,1)==1,
	% only one segment in the calibration
	if sigma(2)>=sigma(1),
		fprintf(' Deviation not improved from %3.2f%% - check data\n',sigma(1)*100) ;
		return
	end
	fprintf(' Deviation improved from %3.2f%% to %3.2f%%\n',sigma*100) ;
	cal = cc ;
else
	% more than one segment in the calibration
	sbad = sigma(:,2)>=sigma(:,1) ;
	if any(sbad),
		fprintf(' Deviation not improved in %d of %d segments\n',sum(sbad),size(sigma,1)) ;
		if all(sbad),
			return
		end
	end
	fprintf(' Mean deviation improved from %3.2f%% to %3.2f%% over %d segments\n',mean(sigma)*100,size(sigma,1)) ;
	cal.tseg = [0 tseg(2:end-1)] ;
	cal.poly = Poly ;
	cal.cross = Cross ;
	cal.tcomp = Tcomp ;
end

% apply cal to the complete magnetometer signal

if isstruct(M),
	if ~isfield(M,'history') || isempty(M.history),
		M.history = 'auto_cal_mag' ;
	else
		M.history = [M.history ',auto_cal_mag'] ;
	end
end

if ~isempty(T),
   if isstruct(M),
   	M=do_cal(M,cal,'nomap','T',T);
   else
   	M=do_cal(M,fs,cal,'nomap','T',T);
   end
else
   if isstruct(M),
      M=do_cal(M,cal,'nomap');
   else
      M=do_cal(M,fs,cal,'nomap');
   end
end

if exist('CHECK','var'),
	for k=1:length(K),
		S = K{k} ;
		Md = crop_to(M,crp);
		nn = norm2(Md.data(S(:,1),:)) ;
		plot(S(:,1),nn,'g.')
		[nanstd(S(:,2))/nanmean(S(:,2)) nanstd(nn)/nanmean(nn) nanmean(abs(nn-S(:,2)))/nanmean(nn)]
	end
end
return


function		[cc,sigma,MM,k] = cal_seg(JJ,MM,fstr,cal,TT)
%
%
nn = sum(~isnan(JJ)) ;
pp = min(25,max(1,5e6/nn)) ;
thr = prctile(JJ,pp) ;
k = find(JJ<thr) ;
MM = MM(k,:) ;

if ~isempty(TT),
	TT = TT(k) ;
end
	
[MM,cc,sigma] = spherical_ls(MM,fstr,cal,3,TT) ;
return
