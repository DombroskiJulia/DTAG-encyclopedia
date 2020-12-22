function   J = d3rmsjerk(recdir,prefix,scf,fs)
%
%     J = d3rmsjerk(recdir,prefix,scf,fs)
%     Calculate the RMS norm-jerk of the entire full bandwidth
%     accelerometer data in a tag deployment. This functions reads
%     the raw data (swv files) hour-by-hour, computing first the 
%     norm-jerk at the full sensor bandwidth, and then taking the
%     RMS of this over successive blocks. The result is a time
%     series of RMS norm-jerk sampled at fs Hz. The averaging time 
%     for the RMS is 2/fs seconds and there is a 50% overlap between 
%     successive blocks.
%     Default output sampling rate if fs is not given is 5 Hz.
%
%     markjohnson@st-andrews.ac.uk
%     2 march 2018

if nargin<3,
   help d3rmsjerk
   return
end

if nargin<4,
	fs = 5 ;                % output sampling rate, Hz
end
	
LEN = 3600 ;               % analysis block length in secs

% get the sampling frequency
X = d3getswv([0 1],recdir,prefix) ;

% find the acceleration channels
ch_names = d3channames(X.cn) ;
cc = strfind(ch_names,'ACC') ;
cn = [] ;
for k=1:length(cc),
	if cc{k} == 1,
		cn(end+1) = k ;
	end
end
		
fsin = X.fs(cn(1)) ;
bl = 2*round(fsin/fs) ; 		% work out the block size
ovl = round(bl-fsin/fs) ;
len = (bl*round(LEN*fsin/bl))/fsin ; 	% make sure len is a multiple of bl
cue = 0 ;
Z = [] ;
J = [] ;

if size(scf,2)>1,
	if size(scf,1)==1,
		scf = scf' ;
	else
		scf = scf(:,1) ;
	end
end

if length(scf)==1,
	scf = scf*[1;1;1] ;
end

while 1,
   fprintf('Reading at cue %d\n', cue) ;
	X = d3getswv(cue+[0 len+(bl-ovl)/fsin],recdir,prefix) ;
	if isempty(X.x), break, end
	A = [X.x{cn}] ;
	jj = njerk(A.*repmat(scf(:)',size(A,1),1),fsin) ;
   [Y,Z] = buffer([Z;jj],bl,ovl,'nodelay') ;
   n = size(Y,2) ;
   J(end+(1:n)) = sqrt(mean(Y.^2))' ;  % J is at fs
   cue = cue+len ;
end
J = J(:) ;		% make sure J is a column vector
J(end+1) = J(end) ;     % add one measurement to equalize length of other sensors
J = sens_struct(J,fs,prefix,'jerk') ;
J.input_sampling_rate = fsin ;
J.rms_averaging_time = bl/fsin ;
J.cal_poly = [scf zeros(3,1)] ;
J.history = 'd3rmsjerk' ;
return
