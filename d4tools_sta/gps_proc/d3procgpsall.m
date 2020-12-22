function    OBS = d3procgpsall(B,BH,H,kproc)
%
%    OBS = d3procgpsall(B,BH,H)
%

FD = [-42 -25]*1e3 ;
if nargin<4,
   kproc = 1:length(B) ;
end

[P,SNR,DEL,DOP] = fdoppX(B,kproc,0,1,FD) ;    % get SV observations
T = d3datevec([BH(kproc).rtime]) ;
T(:,6) = T(:,6) + 1e-6*[BH(kproc).mticks]'-0.032 ; % time of start of grab

sv = (1:32)' ;
for k=1:length(kproc),
   OBS(k).sv = sv ;
   OBS(k).snr = P(k,:)' ;
   OBS(k).del = DEL(k,:)' ;
   OBS(k).dop = DOP(k,:)' ;
   OBS(k).T = T(k,:) ;
end

SNR = horzcat(OBS.snr) ;
N = sum(SNR>150) ;
