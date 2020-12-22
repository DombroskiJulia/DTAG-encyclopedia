function [bton,btoff] = bottom_smoothdiff(p,fs,T)
%
%     [bton,btoff] = bottom_smoothdiff(p,fs,T)   % p is a depth vector
%     or
%     [bton,btoff] = bottom_smoothdiff(p,T)   % p is a sensor structure
%
%     Defines bottom time based on when the vertical speed goes to zero. 
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
    help bottom_smoothdiff
    return
end

if isstruct(p),
   T = fs ;
   [p,fs]=sens2var(p);
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
else
   ndives=size(T,1);
   ds=T(:,1);
   de=T(:,2);
end

if fs<1,
   speed = diff(p) ;    % no smoothing for very low rate data
else
   speed = smoother(diff(p),fs);    % vertical speed in meters per sample, 0.5 Hz bandwidth
end

ds=round(ds*fs);    % convert seconds to samples
de=round(de*fs);
bton=zeros(size(T,1),1); btoff=zeros(size(T,1),1);

for dn=1:size(T.start,1);  %run for the number of dives 
   speeddive = speed(ds(dn):de(dn)-2) ;  % pick out samples in the dive, avoiding the very end
   bton(dn) = ds(dn)+find(speeddive<=0,1)-1 ; % start of 'bottom'
   btoff(dn) = de(dn)-find(flipud(speeddive)>=0,1)+1 ; % end of 'bottom'
end
