function   L = d3light(recdir,prefix,fs)
%
%     L = d3light(recdir,prefix,fs)
%     Perform noise cancellation and decimation on the light sensor
%     data for an entire full bandwidth tag deployment. This functions
%     reads the raw data (swv files) hour-by-hour, performs an interference 
%     reduction step at the full sensor bandwidth, and then decimates to
%     the requested output rate.
%     Default output sampling rate if fs is not given is 5 Hz.
%
%     markjohnson@st-andrews.ac.uk
%     12 march 2018

if nargin<3,
   help d3light
   return
end

if nargin<3,
	fs = 5 ;                % output sampling rate, Hz
end
	
len = 3600 ;               % analysis block length in secs

% get the sampling frequency
X = d3getswv([0 1],recdir,prefix) ;

% find the light (external) channel
ch_names = d3channames(X.cn) ;
cc = strfind(ch_names,'EXT') ;
cn = [] ;
for k=1:length(cc),
   if ~isempty(cc{k}),
      cn = k ;
      break
   end
end
if isempty(cn),
   fprintf('Light sensor not recorded in this deployment\n') ;
   return
end
		
fsin = X.fs(cn) ;
Z = round(fsin/fs) ; 		% work out the decimation factor
cue = 0 ;
L = [] ;

while 1,
   fprintf('Reading at cue %d\n', cue) ;
	X = d3getswv(cue+[0 len],recdir,prefix) ;
	if isempty(X.x), break, end
   [ll,Z] = decz(fix_light_sens(X.x{cn}),Z) ;
   L(end+(1:length(ll))) = ll ;
   cue = cue+len ;
end

ll = decz([],Z);
L(end+(1:length(ll))) = ll ;
L = L(:) ;		% make sure L is a column vector
L = sens_struct(L,fs,prefix,'light') ;
L.input_sampling_rate = fsin ;
L.decimation_factor = round(fsin/fs) ;
L.history = 'd3light' ;
return
