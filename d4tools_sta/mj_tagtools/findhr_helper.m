 X=d3readswv('E:\GitteECGtagdata\Fr14_106a','Fr14_106a');
 ecg=X.x{6};
 fs=X.fs(6);
 [y,yfs] = ecgcleanup2(ecg,fs);
 
 % select the part of the trial you want
 st = 1000 ;   % start time
 ed = 1500 ;   % end time
 k=yfs*st:yfs*ed;
 H=findhr(-y(k),yfs);
 
 % correct the heart beat times to be referenced to start of tag
 H(:,1) = H(:,1)+st ;
 ihi = plothr(H) ;
 save animal_x_hr H
 
 % to continue editing H:
 H=findhr(-y(k),yfs,[],H);
 
