fbase = 'gt6034_' ;
dirn = '/tag/temp/' ;
fnames = dir([dirn fbase '*.gps']) ;

ref = [] ;
T = [] ;
nbad = 0 ;
for k=1:length(fnames),
   [B,BH,H]=d3readbin([dirn fnames(k).name],[]);
   if isempty(ref),
      ref = BH(1).rtime ;
   end
   tt=vertcat(BH(1:end).rtime)-ref+vertcat(BH(1:end).mticks)*1e-6; % dtag time of rx
   [BB,DV,POS]=catgps(B);
   % DV is gps time of rx
   dt = etime(DV,repmat(d3datevec(ref),size(DV,1),1));
   kk = find(dt>=0) ;    % exclude bad rx
   T(end+(1:length(kk)),1:2) = [dt(kk) tt(kk)] ;
   nbad = nbad+length(dt)-length(kk) ;
end
plot(T(:,1),T(:,2)-T(:,1),'.'),grid
fprintf('%d good receptions, %d bad receptions\n',size(T,1),nbad)
