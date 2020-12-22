function    t = timeoffset_trials(x,fs,cl,OFFS,LIM)
%
%    t = timeoffset_trials(x,fs,cl,OFFS,LIM)
%     x and fs are from the Soundtrap wav data
%     cl is the click list for the dtag
%     OFFS is the rough time offset in seconds to search around
%     LIM is the temporal extent of the search in seconds
%

df = 4 ;
SLIM = 0.02 ;
x=buffer(x,2*df,df,'nodelay');
x=sqrt(mean(x.^2))' ;
fs = fs/df ;
X=extractcues(x,cl(:,1)*fs,round(fs*(LIM*[-1 1]+OFFS)));
s = sum(X.^2,2) ;
offs = (1:size(X,1))/fs-LIM+OFFS ;
figure(1),clf
subplot(211)
plot(offs,s),grid
[m,k] = max(s) ;
t = offs(k) ;
hold on
plot(t,m,'ro')
xlabel('Time offset Soundtrap-DTAG')
ylabel('Match quality')
X=extractcues(x,cl(:,1)*fs,round(fs*(SLIM*[-1 1]+t)));
subplot(212)
imagesc(t+(1:size(X))/fs-SLIM,1:size(X,2),20*log10(X)')
xlabel('Time offset Soundtrap-DTAG')
ylabel('Click number')
