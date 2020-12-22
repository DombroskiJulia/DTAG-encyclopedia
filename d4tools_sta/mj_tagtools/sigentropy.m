function    H = sigentropy(x,r)
%
%    H = sigentropy(x,r)
%

bins = min(x):r:max(x)+r ;
n = histc(x,bins) ;
p = n(1:end-1)/length(x) ;
k = find(p>0) ;
H = -sum(p(k).*log(p(k)))/log(2) ;
