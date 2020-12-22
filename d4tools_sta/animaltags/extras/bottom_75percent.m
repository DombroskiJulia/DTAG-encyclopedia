function [bton,btoff] = bottom_75percent(p,fs,T)

%     [bton,btoff] = bottom_75percent(p,fs,T)   % p is a depth vector
%     or
%     [bton,btoff] = bottom_75percent(p,T)   % p is a sensor structure
%
%     Defines bottom time based on 75% of maximum depth of each dive.
%
%     Inputs:
%     p is depth or altitude time series in meters. p can be a sensor structure or
%		 a vector. p must be regularly sampled.
%     fs is the sampling rate of p in Hz.
%     T is a results structure or matrix from find_dives. Old versions of
%       find_dives return a matrix with a row per dive while new versions
%       return a structure. Both types of data are supported.
%
%     Returns:
%     bton is a vector of start times of the bottom phase in samples. 
%     btoff is a vector of end times of the bottom phase in samples.
%     
%     To convert these into times in seconds, divide them by the sampling rate of p.
%
%     Modified by rs232,26-Jan-2018
%     Improved help mj 6/2/18

bton=[]; btoff=[];
if nargin<2,
    help bottom_75percent
    return
end

if isstruct(p),
   T = fs ;
   [p,fs]=sens2var(p.data);
else
   if nargin<3,
      fprintf('Need to specify sampling rate if depth is a vector\n') ;
      return
   end
end

if isstruct(T)
   ndives=size(T.start,1);
   ds=T.start;
   de=T.end;
   pmax=T.max;
else
   ndives=size(T,1);
   ds=T(:,1);
   de=T(:,2);
   pmax=T(:,4);
end

ds=round(ds*fs);    % convert seconds to samples
de=round(de*fs);
bton=zeros(ndives,1); btoff=zeros(ndives,1);

% this is the bit that actually does the calculations:
for dn=1:ndives  %run for the number of dives  
   pdive = p(ds(dn):de(dn)) ;  % pick out samples in the dive
   bton(dn) = ds(dn)+find(pdive>0.9*pmax(dn),1)-1 ; % start of 'bottom'
   btoff(dn) = ds(dn)+find(pdive>0.9*pmax(dn),1,'last') ; % end of 'bottom'
   

end

