function    Ar = acc_resample(A)
%
%   Ar = acc_resample(A)
%

kr = find(all(A(2:end,:)==A(1:end-1,:),2));
[mean(diff(kr)) min(diff(kr)) max(diff(kr))]
Ar = A;
for kk=1:length(kr)-1,
   kg = (kr(kk)+1:kr(kk+1)-1) ;
   Ar(kg,:) = Ar(kg,:)+diff(Ar(kr(kk)+1:kr(kk+1),:)).*repmat((length(kg):-1:1)'/(length(kg)+1),1,3) ;
end
