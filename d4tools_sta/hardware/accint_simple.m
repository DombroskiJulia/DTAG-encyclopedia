f1 = 807 ;
f2 = 1000 ;

t1=(0:1/f1:1.001)';
t2=(0:1/f2:1)';
s=sin(2*pi*50*t1);
ylin=interp1(t1,s,t2,'linear');
Fs=fft(s.*hamming(length(s)));
Flin=fft(ylin.*hamming(length(ylin)));
figure(1),clf
plot((0:400)/length(s)*f1,20*log10(abs(Fs(1:401)))),grid
hold on
plot((0:500)/length(ylin)*f2,20*log10(abs(Flin(1:501))),'g')

k = nearest(t1,t2,[],-1);
yzoh=s(k);
Fzoh=fft(yzoh.*hamming(length(yzoh)));
plot((0:500)/length(yzoh)*f2,20*log10(abs(Fzoh(1:501))),'r')
figure(2),clf
plot([ylin(1:100),yzoh(1:100)]),grid

kr = find(k(2:end)==k(1:end-1));
yr = yzoh;
for kk=1:length(kr)-1,
   kg = (kr(kk)+1:kr(kk+1)-1) ;
   yr(kg) = yr(kg)+diff(yr(kr(kk)+1:kr(kk+1))).*(length(kg):-1:1)'/(length(kg)+1) ;
end
hold on
plot(yr(1:100),'r.-')
figure(1)
Fr=fft(yr.*hamming(length(yr)));
plot((0:500)/length(yr)*f2,20*log10(abs(Fr(1:501))),'m')
