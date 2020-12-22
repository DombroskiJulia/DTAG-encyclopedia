function    Obs = proc_gpsbinfile(fname,kproc,dtype)
%
%    Obs = proc_gpsbinfile(fname,kproc,dtype)
%     Process a D3 or D4 GPS bin file
%		Called by d3preprocgps
%

[B,BH,H]=d3readbin(fname,[]);
if ~iscell(B),
   B = {B} ;
end

if nargin<2 || isempty(kproc),
   kproc = 1:length(B) ;
end

if isempty(kproc) || isempty(BH),
   Obs = [] ;
   return
end

if nargin<3,
   dtype = 4 ;
end

P = [] ;
for k=1:3,      % try 3 times to run the gps decoder
    try
        if dtype==4,
            [P,SNR,DEL,DOP] = fast_fdoppX(B,kproc,1,1) ;	% process a D4 gps bin file
        else
            FD = [-42 -25]*1e3 ;
            [P,SNR,DEL,DOP] = fdoppX(B,kproc,0,1,FD) ;   % process a D3 gps bin file
        end
        break
    catch
        close all    % close all figures in case graphics is a problem
    end
end

if isempty(P),
   Obs = [] ;
   return
end

if isfield(SNR,'kproc'),
   kproc = vertcat(SNR.kproc) ;
end
T = d3datevec([BH(kproc).rtime]) ;
T(:,6) = T(:,6) + 1e-6*[BH(kproc).mticks]' ;  % time of grab

if size(P,1)~=length(kproc),
   keyboard
end

sv = (1:32)' ;
for k=1:size(P,1),
   Obs(k).sv = sv ;
   Obs(k).snr = P(k,:)' ;
   Obs(k).del = DEL(k,:)' ;
   Obs(k).dop = DOP(k,:)' ;
   Obs(k).T = T(k,:) ;
end
return
