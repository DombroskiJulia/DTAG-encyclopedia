function    d = dsi(T,P,fs)

%     d = dsi(T,P)         % P is a sensor structure
%     of
%     d = dsi(T,P,fs)      % P is a vector of depth measurements
%     Computes the dive shape index of a set of dives using data from a
%     pressure sensor structure and data generated from find_dives given in
%     structure T.
%
%     Inputs
%     P = pressure sensor structure
%     T = structure resulting from find_dives function
%     Outputs
%     d = dive shape index. A number ranging from 0-1 based on how v or
%     u-shaped a dive is. values closer to 1 are more u-shaped, whilst values
%     closer to 0 are more v shaped. 

d = [] ;
if nargin<2,
   help dsi
   return
end

if isstruct(P),
   fs = P.sampling_rate ;
   P = P.data ;
end

d = NaN*ones(length(T.start),1) ;

for ii=1:length(T.start),
   pp = P(round(T.start(ii)*fs):round(T.end(ii)*fs)) ;
   d(ii)=sum(pp)/(T.max(ii)*(length(pp)-1));
end
