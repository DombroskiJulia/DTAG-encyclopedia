function    [scl,RR] = echoenvdisp(Z,scf,offs,db)
%
%     [scl,RR] = echoenvdisp(Z,scf,offs,db)
%     Display echogram with a time axis rather than a click axis.
%     Z can be a strucure or a file name. Make Z using procbuzzes
%     or echogram
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  December 2006
%

if nargin<1,
    help echoenvdisp
    return
end

if nargin<2,
   scf = 1 ;
   offs = 0 ;
end

if isstr(Z),
   load(Z) ;
end

MAXICI = 1 ;               % make a gap when ICI is more than this
cax = [-93 -35] ;       
%df = 2 ;
%RdB = 20*log10(abs(decdc(Z.R,df))+eps) ;
%T = Z.T(1:2:end) ;

if nargin<4 | isempty(db),
   RdB = 20*log10(Z.R+eps) ;
else
   RdB = Z.R ;
end
T = Z.T ;

tcl = Z.BCL ;
k = [0;find(diff(tcl)>MAXICI);length(tcl)]' ;
hold off
for kk=1:length(k)-1,
   ind = k(kk)+1:k(kk+1) ;
   if length(ind)>3,
      imageirreg(tcl(ind),T*scf+offs,RdB(:,ind)');
   end
   hold on
end
hold off
grid on
axis xy
colormap(jet) ;
caxis(cax)
return
