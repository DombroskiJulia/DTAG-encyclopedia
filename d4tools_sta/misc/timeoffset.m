function    t = timeoffset(x,fs,cl,OFFS,LIM)
%
%    t = timeoffset(x,fs,cl,OFFS,LIM)
%     x is the envelope computed from wav data using preproc_trials
%     fs is the corresponding sampling rate
%     cl is the click list for the dtag
%     OFFS is the rough time offset in seconds to search around
%     LIM is the temporal extent of the search in seconds
%

SLIM = 0.02 ;
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
xlabel('Time offset x-cl')
ylabel('Match quality')
X=extractcues(x,cl(:,1)*fs,round(fs*(SLIM*[-1 1]+t)));
subplot(212)
imagesc(t+(1:size(X))/fs-SLIM,1:size(X,2),20*log10(X)')
xlabel('Time offset Soundtrap-DTAG')
ylabel('Click number')
