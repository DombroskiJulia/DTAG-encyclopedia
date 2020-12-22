function [E,me] = ecg_test(X,k)
%
%  [E,me] = ecg_test(X,k)
%

ecg=X.x{12};
[E,z]=buffer(ecg(k),80,0,'nodelay');
me=mean(E,2);
E=E-repmat(me,1,size(E,2));
E=E(:);
std(E)
