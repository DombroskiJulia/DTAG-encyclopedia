function    [RI,t]=residence_index(tag,cues,R)
%
%     [RI,t]=residence_index(tag,cues,R)
%     Estimate the residence index (RI) of a tagged whale.
%     The RI follows the definition in Johnson et al. Proc
%     Royal Soc. 2008, namely, the amount of time that the
%     animal is within a sphere of radius R meters divided
%     by R. A large residence index implies that the whale
%     is circling to stay in the same area.
%     tag is the name of the tag deployment, e.g., 'md05_285a'
%     cues is a vector of start time and end time over
%     which to calculate RI.
%     R is the radius of the sphere in m. Default is 20 m.
%     R can be a vector with several radii.
%     Returns:
%     RI is the residence index at time points in vector t.
%
%     markjohnson@st-andrews.ac.uk
%     7 October 2012

T = 5 ;        % time step to use

if nargin<3 || isempty(R),
   R = 20 ;
end

loadprh(tag,0,'p','fs','pitch','head') ;
kk = round(fs*cues(1)):round(fs*cues(2)) ;

% estimate the track of the whale using Kalman estimated speed
trk = ptrack(pitch(kk),head(kk),p(kk),fs,1/T) ;

% make a vector of sampling moments
t = (kk(1)/fs+T:T:kk(end)/fs-T)' ;
kcue = round(fs*(t-cues(1)))+1 ;
trkcue = trk(kcue,:) ;
nt = length(kk) ;
RI = NaN*zeros(length(kcue),length(R)) ;

for kk=1:length(kcue),
   % find the distance to the track point at each sampling moment
   r = norm2(trk-repmat(trkcue(kk,:),nt,1)) ;
   RI(kk,:) = sum(r<R)/(fs*R) ;
end   
