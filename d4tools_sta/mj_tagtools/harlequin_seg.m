function    harlequin_seg(tag,cue,win,center)
%
%    harlequin_seg(tag,cue,win,center)
%     Draw harlequin plot for pitch-roll-heading excerpts. The
%     excerpts extend from cues+win(:,1) to cues+win(:,end). If a
%     4th argument is given, it is used as an offset with respect
%     to win to center the tracks.
%     Note: uses a fixed speed. Change CS in the script to adjust this.
%     As tracklets are coloured by roll, only tracklets with |pitch|<80
%     degrees are drawn.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 5 January, 2007

if nargin<3,
   help harlequin_seg
   return
end

CS = 1.5 ;                       % nominal speed in m/s
cue = cue(:) ;
LPF = 0.5 ;                   % movement low-pass filter cut-off in Hz

if nargin<4 | isempty(center),
   center = 0 ;
end

if length(center)~=length(cue),
   center = center(1)+0*cue ;
end

if any(center<win(1) | center>win(2)),
   fprintf('Argument center must be within display window win\n')
   return
end

loadprh(tag,0,'p','fs','Mw','Aw') ;

kcue = round(cue*fs) ;
kwin = win*fs ;
kc = round(fs*(center-win(1)))+1 ;

[b a] = butter(2,LPF/(fs/2)) ;         % movement low-pass filter
Af = filtfilt(b,a,Aw) ;                % smooth accelerometry
Mf = filtfilt(b,a,Mw) ;                % smooth magnetometry
D = extractcues(p,kcue,kwin) ;          % get depth extract
AA = extractcues(Af,kcue,kwin) ;        % get acceleration extract
MM = extractcues(Mf,kcue,kwin) ;        % get magnetometer extract

% extract smoothed pitch and heading
PP = zeros(size(AA,1),size(AA,3)) ;
HH = PP ; 

for kk=1:size(AA,3),
   [pp,rr] = a2pr(AA(:,:,kk)) ;           % pitch and roll
   HH(:,kk) = m2h(MM(:,:,kk),pp,rr) ;     % heading
   PP(:,kk) = pp ; 
end

% make horizontal tracklets
HTR = cumsum(cos(PP).*exp(j*HH))*CS/fs ;

% center tracks and depths on center point
for k=1:length(kc),
   HTR(:,k) = HTR(:,k)-HTR(kc(k),k) ;
   DD(:,k) = D(:,k)-D(kc(k),k) ;
end

W.TRACK = HTR ;
W.DEPTH = DD ;
W.PITCH = PP ;
W.HEAD = HH ;

% make display
% x-axis is easting, y-axis is northing
hold off,plot3(0,0,0),grid
hold on
for kk=1:length(kcue),
   h1 = plot3(imag(HTR(:,kk)),real(HTR(:,kk)),DD(:,kk)) ;
   set(h1,'Color',0.5*[1 1 1],'LineWidth',1) ;
end

for kk=1:length(kcue),
   hh = plot3(imag(HTR(1,kk)),real(HTR(1,kk)),DD(1,kk),'ko') ;
   set(hh,'MarkerSize',5,'LineWidth',1.5) ;
end

SZE = max(max(abs([DD imag(HTR(:,kk)) real(HTR(:,kk))]))) ;
axis(1.1*SZE*[-1 1 -1 1 -1 1])
set(gca,'ZDir','reverse')
