[B,BH,H]=d3readbin(ldf([],'bin'),[]);
grab_spec(B,(1:4),1,1); %%% calculate the difference between dBs at 3 and 5 MHz
[P,SNR]=fast_fdoppX(B,1+[1:4 7:10 13:16 19:22],1);
gpsperfrep(SNR) % output column 1 n > 200 column 2 n> 500 column 3 mean SV level
