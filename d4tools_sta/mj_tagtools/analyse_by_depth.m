function    [Rd,Ra] = analyse_by_depth(F,p,fs,D)
%
%   [Rd,Ra] = analyse_by_depth(F,p,fs,D)
%  Columns of Rd and Ra are:
%     duration
%     mean vertical velocity
%     sum(F)
%     std(F)

Rd = NaN*zeros(length(D)-1,4) ;
Ra = NaN*zeros(length(D)-1,4) ;

for k=1:length(D)-1,
   tst = find(p>D(k),1)/fs ;
   ted = find(p>D(k+1),1)/fs ;
   if length([tst ted])<2, continue, end
   kd = round(fs*tst):round(fs*ted) ;
   mm = mean(F(kd,:)) ;
   ss = mean(F(kd,:)) ;
   Rd(k,:) = [ted-tst (D(k+1)-D(k))/(ted-tst) mm ss] ;
end

for k=1:length(D)-1,
   tst = find(p>D(k+1),1,'last')/fs ;
   ted = find(p>D(k),1,'last')/fs ;
   if length([tst ted])<2, continue, end
   kd = round(fs*tst):round(fs*ted) ;
   mm = mean(F(kd,:)) ;
   ss = mean(F(kd,:)) ;
   Ra(k,:) = [ted-tst (D(k+1)-D(k))/(ted-tst) mm ss] ;
end
