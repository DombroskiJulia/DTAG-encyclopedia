function    L = get_click_levels(recdir,prefix,CL,tframe,filt)

%    L = get_click_levels(recdir,prefix,CL,tframe,filt)
%		Get the RMS level of clicks in a click list using a 95% energy 
%		duration. This may take a long time if CL contains many 1000 clicks.
%
%		Inputs:
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%		CL is a click list e.g., produced by d3findallclicks. If there
%		 are multiple columns, only the first column will be processed.
%		 Numbers in this column should be the time in seconds of the start
%		 time of each click.
%		tframe is the time in seconds before and after each click cue
%		 to extract. This should be chosen to bracket the click with only
%		 a little noise on either side.
%		filt is the highpass (if a scalar) or bandpass (if 2 element vector)
%		 filter to apply to the sound before computing the RMS level.
%		
%		Returns:
%		L is a vector with the same column size as CL containing the RMS
%		 levels of each click. The units are the same as the audio units
%		 i.e., L is not in dB. Use 20*log10(L) to get dB.
%
%		markjohnson@st-andrews.ac.uk
%		24 Sept. 2018

if nargin<5,
   help get_click_levels
   L = [] ;
   return
end

N = 1000 ;
ETHR = 0.025 ;    % 95% energy window

L = repmat(NaN,size(CL,1),1) ;
k = 0 ;
while 1,
   n = min(size(CL,1)-k,N) ;
   fprintf('Processing %d-%d of %d clicks\n',k+1,k+n,size(CL,1)) ;
   kk = k+(1:n) ;
   [X,fs] = d3lookupcues(CL(kk,1),recdir,prefix,'wav',tframe,filt) ;
   X = cumsum(squeeze(X(:,1,:)).^2) ;
   EN = X.*repmat(X(end,:).^(-1),size(X,1),1) ;
   D = sum((EN>ETHR) & (EN<(1-ETHR))) ;
   L(kk) = sqrt(X(end,:)./D)' ;
   k = k+n ;
   if k>=size(CL,1), break, end
end
