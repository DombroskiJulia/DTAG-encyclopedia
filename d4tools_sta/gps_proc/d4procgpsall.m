function    OBS = d4procgpsall(B,BH,H,kproc)
%
%    OBS = d4procgpsall(B,BH,H,kproc)
%

%FD = [-8 8]*1e3 ;
if nargin<4,
   kproc = 1:length(B) ;
end

%[P,SNR,DEL,DOP] = fast_fdoppX(B,kproc,1,1) ;    % get SV observations
[P,SNR,DEL,DOP] = fdoppX(B,kproc,1,1) ;    % get SV observations
T = d3datevec(vertcat(BH(kproc).rtime)) ;
T(:,6) = T(:,6) + 1e-6*[BH(kproc).mticks]' ; % time of start of grab
OBS = [] ;
sv = (1:32)' ;
for k=1:length(kproc),
   OBS(k).sv = sv ;
   %OBS(k).snr = P(:,k) ;
   %OBS(k).del = DEL(:,k) ;
   %OBS(k).dop = DOP(:,k) ;
   OBS(k).snr = P(k,:)' ;
   OBS(k).del = DEL(k,:)' ;
   OBS(k).dop = DOP(k,:)' ;
   OBS(k).T = T(k,:) ;
end

%SNR = horzcat(OBS.snr) ;
%N = sum(SNR>150) ;
