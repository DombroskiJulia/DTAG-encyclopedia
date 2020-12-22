load md_templates
s=real(Trc);         % 1.7 ms block
nreps = 1000 ;
np = 0.03 ;
q = 0.5 ;
n=sqrt(np)*randn(length(s),nreps);
x=repmat(s,1,nreps)+n;
 
d = signalpwrdur(x, np, q)' ;
dd = zeros(nreps,1) ;
for k=1:nreps,
   dd(k)=length(choosewindow(x(:,k),q,np));
end
plot(dd,d,'.'),grid
[10*log10(sum(s.^2)/np) q sum(abs(dd-d)<=2)/nreps]

% Results:
% E2NO, dB     q     % of durations with 2 samples of choosewindows
% 23           0.5   88%
% 23           0.65  76%
% 23           0.75  58%
%
% 28           0.75  99%
% 28           0.85  87%
%
% 33           0.75  100%
% 33           0.85  100%
% 33           0.95  82%
% 
