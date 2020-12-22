function    Obs = proc_gpsbinfile(fname,kproc,dtype)
%
%    Obs = proc_gpsbinfile(fname,kproc,dtype)
%     Process a D3 or D4 GPS bin file

Obs = [] ;
[B,BH,H]=d3readbin(fname,[]);
if isempty(B),
   return
end

if nargin<2 || isempty(kproc),
   if iscell(B),
      kproc = 1:length(B) ;
   else
      kproc = 1 ;
   end
end

if isempty(kproc),
   return
end

if nargin<3,
   dtype = 4 ;
end

if dtype==4,
   [P,SNR,DEL,DOP] = fast_fdoppX(B,kproc,1,1) ;	% process a D4 gps bin file
else
   FD = [-42 -25]*1e3 ;
   [P,SNR,DEL,DOP] = fdoppX(B,kproc,0,1,FD) ;   % process a D3 gps bin file
end

T = d3datevec([BH(kproc).rtime]) ;
T(:,6) = T(:,6) + 1e-6*[BH(kproc).mticks]' ;  % time of grab

if size(P,1)<length(kproc),
   T = T(1:size(P,1),:) ;
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
