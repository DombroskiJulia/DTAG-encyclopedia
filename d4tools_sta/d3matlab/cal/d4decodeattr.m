function		CAL = d4decodeattr(s,psel,accsel,audsel)
%
%	CAL = d4decodeattr(s,psel,accsel,audsel)
%

CAL = [] ;

if psel==1,
   pkey = 'PL' ;
else
   pkey = 'PH' ;
end
acckey = sprintf('A%d',accsel) ;
if audsel==1,
   audkey = 'SL' ;
else
   audkey = 'SH' ;
end

s(s=='_') = '-' ;

% parse attribute lines
while length(s)>0,
   [A,s] = strtok(s,',');
   [n,s] = strtok(s,',');
   n = str2num(n) ;
   P = zeros(1,n) ;
   for kk=1:n,
      [pp,s] = strtok(s,',');
      P(kk) = str2num(pp) ;
   end
   switch A
      case pkey
         CAL.PRESS = struct('range',P(1)/10,'unit','decibar','poly',P(2:3)/10,'tref',20) ;
         CAL.PRESS.tc = struct('src','tempr','poly',0) ;
      case acckey
         r = 9.81*reshape(P/1000,2,3)' ;
         CAL.ACC = struct('range',accsel*10,'unit','m/s2','poly',r,'map',eye(3),'tref',20) ;
         CAL.ACC.tc = struct('src','tempr','poly',zeros(3,1)) ;
      case 'AM'
         CAL.ACC.map = decodemap(P(1)) ;
         CAL.ACC.rule = 'LTU' ;
      case 'MH'
         r = reshape(P/10,2,3)' ;
         CAL.MAG = struct('range',400,'unit','uT','poly',r,'tref',20) ;
         CAL.MAG.tc = struct('src','tempr','poly',zeros(3,1)) ;
      case 'MM'
         CAL.MAG.map = decodemap(P(1)) ;
         CAL.MAG.rule = 'LTU' ;
      case audkey
         CAL.AUDIO = struct('unit','dB re V/uPa','sens',P(1),'range',P(2:3)*10) ;
   end
end
CAL.TEMPR.poly = [2^15/4*0.03125 0] ;
return


function     M = decodemap(p)
%
%
MKEY = [1 0 0;0 1 0;0 0 1;1 0 0;-1 0 0;0 -1 0;0 0 -1;-1 0 0]' ;
xmap = floor(p/256) ;
ymap = floor(rem(p,256)/16) ;
zmap = rem(p,16) ;
M = [MKEY(:,xmap+1) MKEY(:,ymap+1) MKEY(:,zmap+1)] ;
return
