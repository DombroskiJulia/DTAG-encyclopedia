function		CAL = d4decodeattr(s,psel,accsel,audsel)
%
%     CAL = d4decodeattr(s,psel,accsel,audsel)
%
%     markjohnson@st-andrews.ac.uk
%     last modified: 2/3/18
%     - improved compatibility with animaltags tools

sensors = {'PRESS','TEMP','ACC','MAG','AUDIO'} ;
CAL = [] ;
for k=1:length(sensors),
   X = sens_struct([],1,'',sensors{k});
   c = struct('unit',X.unit,'type',X.type) ;
   c.unit_name = X.unit_name ;
   c.unit_label = X.unit_label ;
   if isfield(X,'axes'),
      c.axes = X.axes ;
   end
   CAL.(sensors{k}) = c ;
end

if isstruct(psel) || psel==1,
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
         CAL.PRESS.range = P(1)/10 ;
         CAL.PRESS.poly = P(2:3)/10 ;
         CAL.PRESS.tref = 20 ;
         CAL.PRESS.tcomp = 0 ;
         CAL.PRESS.tcompsrc = 'temp' ;
			CAL.PRESS.attr = pkey ;
         if isstruct(psel),
            if P(2)>=100,
               CAL.PRESS.poly = [1 0] ;
            else
               CAL.PRESS.poly = [1+P(2)/100 P(3)/100] ;
            end
            CAL.PRESS.builtin = psel ;
            CAL.TEMP.builtin = psel ;  % pressure sensor includes temp sensor
         end
      case acckey
         r = 9.81*reshape(P/1000,2,3)' ;
         CAL.ACC.range = accsel*10 ;
         CAL.ACC.poly = r ;
         CAL.ACC.map = eye(3) ;
         CAL.ACC.tref = 20 ;
         CAL.ACC.tcomp = zeros(3,1) ;
         CAL.ACC.tcompsrc = 'temp' ;
			CAL.ACC.attr = acckey ;
      case 'AM'
         CAL.ACC.map = decodemap(P(1)) ;
      case 'MH'
         r = reshape(P/10,2,3)' ;
         CAL.MAG.range = 400 ;
         CAL.MAG.poly = r ;
         CAL.MAG.tref = 20 ;
         CAL.MAG.tcomp = zeros(3,1) ;
         CAL.MAG.tcompsrc = 'temp' ;
			CAL.MAG.attr = 'MH' ;
      case 'MM'
         CAL.MAG.map = decodemap(P(1)) ;
      case audkey
         CAL.AUDIO.sens = P(1) ;
         CAL.AUDIO.sens_unit = 'dB re U/uPa' ;
         CAL.AUDIO.bandwidth = sort(P(2:3)*10) ;
			CAL.AUDIO.attr = audkey ;
   end
end

if isfield(CAL.TEMP,'builtin'),
   CAL.TEMP.poly = [1 0] ;
else
   CAL.TEMP.poly = [2^15/4*0.03125 0] ;
end
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
