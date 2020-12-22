function    BCL = buzzclickcontext(BCL,CL,intervl,ar)

%    BCL = buzzclickcontext(BCL,CL,intervl,ar)
%     ar = 0 intervl is relative to start and end of BCL
%     ar = 1 intervl is absolute

if nargin<4 | isempty(ar),
   ar = 0 ;
end

minsp = 2e-3 ;
tstart = min(BCL(:,1)) ;
tend = max(BCL(:,1)) ;

if ar==0,
   kpre = find(CL>tstart+intervl(1) & CL<tstart-minsp) ;
   kpost = find(CL<tend+intervl(2) & CL>tend+minsp) ;
else
   kpre = find(CL>intervl(1) & CL<tstart-minsp) ;
   kpost = find(CL<intervl(2) & CL>tend+minsp) ;
end

BCL = sort([CL(kpre,1);BCL(:,1);CL(kpost,1)]) ;
