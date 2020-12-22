function   [Gy,CAL,fs]=d3calgyro(X,CAL)


% find gyroscope channels in X
[ch_names,descr,ch_nums,type] = d3channames(X.cn) ;
kg = find(strcmp(type,'gyro'));


C = CAL.GYRO ;
s = [X.x{kg}] ;
fsin = X.fs(kg(1)) ;

fs=fsin;

CAL.POLY(:,1)=[0.040424;0.038011;0.040424];
CAL.POLY(:,2)=0;

xaxisgyrorad=((s(:,1))/CAL.POLY(1,1));
yaxisgyrorad=((s(:,2))/CAL.POLY(2,1));
zaxisgyrorad=((s(:,3))/CAL.POLY(3,1));
Gy=[xaxisgyrorad,yaxisgyrorad,zaxisgyrorad]; %MATRIX WITH THE RADIANS AFTER CALIBRATING THEM


Gy=apply_cal(s,CAL.GYRO);
end


%%%do i have to do something like its down that has been done for p, A and
%%%M calibration?



% function    CAL = time_select(p,fs,CAL)
% %
% %
% figure(1),clf
% plott(p,fs*3600)
% xlabel('Time, hours')
% zoom off
% fprintf(' Select left and right limits in Fig 1 by positioning cursor and typing l or r\n') ;
% fprintf(' Press any other key to end\n')
% 
% Tl = 0 ;
% Tr = length(p)/fs ;
% if isfield(CAL,'CALTIMESPAN'),
%    Tl = min(Tr,max(Tl,CAL.CALTIMESPAN(1))) ;
%    Tr = min(Tr,max(Tl,CAL.CALTIMESPAN(2))) ;
% end
% hold on
% hl = plot([1;1]*Tl/3600,get(gca,'YLim'),'g') ;
% set(hl,'LineWidth',1.5) ;
% hlm = plot(Tl/3600,mean(get(gca,'YLim')),'g>') ;
% set(hlm,'MarkerSize',12,'MarkerFaceColor','g') ;
% 
% hr = plot([1;1]*Tr/3600,get(gca,'YLim'),'r') ;
% set(hr,'LineWidth',1.5) ;
% hrm = plot(Tr/3600,mean(get(gca,'YLim')),'r<') ;
% set(hrm,'MarkerSize',12,'MarkerFaceColor','r') ;
% 
% done = 0 ;
% while ~done,
%    [x,y,s] = ginput(1) ;
%    s = char(s) ;
%    switch char(s),
%       case 'l'
%          Tl = min(Tr,max(0,x*3600)) ;
%          set(hl,'XData',Tl/3600*[1 1]) ;
%          set(hlm,'XData',Tl/3600) ;
%       case 'r'
%          Tr = min(length(p)/fs,max(Tl,x*3600)) ;
%          set(hr,'XData',Tr/3600*[1 1]) ;
%          set(hrm,'XData',Tr/3600) ;
%       otherwise done = 1 ;
%    end
% end
% 
% CAL.CALTIMESPAN = [Tl,Tr] ;
% CAL.CALTIMESPANUNIT = 'seconds' ;
% return
