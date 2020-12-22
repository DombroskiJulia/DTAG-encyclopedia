function    [Rd,Ra] = analyse_fluking(F,p,fs,D)
%
%   [Rd,Ra] = analyse_fluking(F,p,fs,D)
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

Rd = NaN*zeros(length(D)-1,9) ;
Ra = NaN*zeros(length(D)-1,9) ;

for k=1:length(D)-1,
   tst = find(p>D(k),1)/fs ;
   ted = find(p>D(k+1),1)/fs ;
   if length([tst ted])<2, continue, end
   kfl = find(F(:,1)>=tst & F(:,1)<ted) ;
   if length(kfl)<=1,
      Rd(k,:) = [ted-tst (D(k+1)-D(k))/(ted-tst) length(kfl)/2 zeros(1,6)] ;
      continue
   end
   mr = 0.5*mean(1./F(kfl,2)) ;
   e = sum(F(kfl,2).^(-3)) ;
   ff = min(sum(F(kfl,2))/(ted-tst),1) ;
   mm = mean(F(kfl,4:6)) ;
   Rd(k,:) = [ted-tst (D(k+1)-D(k))/(ted-tst) length(kfl)/2 mr e ff mm] ;
end

for k=1:length(D)-1,
   tst = find(p>D(k+1),1,'last')/fs ;
   ted = find(p>D(k),1,'last')/fs ;
   if length([tst ted])<2, continue, end
   kfl = find(F(:,1)>=tst & F(:,1)<ted) ;
   if length(kfl)<=1,
      Ra(k,:) = [ted-tst (D(k+1)-D(k))/(ted-tst) length(kfl)/2 zeros(1,6)] ;
      continue
   end
   mr = 0.5*mean(1./F(kfl,2)) ;
   e = sum(F(kfl,2).^(-2)) ;
   ff = min(sum(F(kfl,2))/(ted-tst),1) ;
   mm = mean(F(kfl,4:6)) ;
   Ra(k,:) = [ted-tst (D(k+1)-D(k))/(ted-tst) length(kfl)/2 mr e ff mm] ;
end
