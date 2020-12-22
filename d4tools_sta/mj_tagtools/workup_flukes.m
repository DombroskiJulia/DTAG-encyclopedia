T = finddives(p,fs,500) ;
OB = obda(A,fs,0.2) ;
F = {} ;
%D = [0 50 100 500] ;
D = [0 200 400] ;
Rd = [] ; Ra = [] ;
Od = [] ; Oa = [] ;
for k=1:size(T,1),
   kk = round(fs*T(k,1)):round(fs*T(k,2)) ;
   [F{k},rr,S] = flukespecific(Aw(kk,:),Mw(kk,:),fs,0.2,2/180*pi) ;
   [rd,ra] = analyse_fluking(F{k},p(kk),fs,D) ;
   [od,oa] = analyse_by_depth(OB(kk),p(kk),fs,D) ;
   Rd = [Rd;rd] ;
   Ra = [Ra;ra] ;
   Od = [Od;od] ;
   Oa = [Oa;oa] ;
end

%  Columns of Rd and Ra are:
%     duration
%     mean vertical velocity
%     number of full fluke strokes
%     mean fluke rate when fluking
%     sum fluke rate cubed
%     fraction of time fluking
%     mean rms rotation
%     mean rms surge
%     mean rms heave
