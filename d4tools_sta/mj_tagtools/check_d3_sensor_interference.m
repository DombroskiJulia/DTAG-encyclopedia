[sseq,sch,n,nb]=make_sseq('e:/new/sseq80ma_v11.csv',0,'dtag3');
N=reshape(unpack(sseq,9),9,[])';
plot(0:79,circ(N(:,4)&N(:,5)&(N(:,6)==0),10),'.-'),grid
