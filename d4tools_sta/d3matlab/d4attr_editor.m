function    d4attr_editor(did)

%    d4attr_editor(did)
%		Edit a D4 attribute file. Danger: make sure you know what you are doing!
%		Please follow the instructions in d4attributes.pdf
%

attr = default_attr;

if ischar(did),
	aname = lower(did(isstrprop(did,'alphanum'))) ;
else
   aname = sprintf('%x',did(1)) ;
end

aname = ['attr_' aname(1:4) '_' aname(5:8)] ;
f = fopen([aname '.txt'],'r') ;

if f<=0,
   fprintf('Unable to find attribute file for tag %s %s\n',aname(6:9),aname(11:14)) ;
	if input('Do you want to create one y/n? ','s')~='y',
		return
	end
else
	attr = load_attr_file(f,attr) ;
end

figure;
t = attr_table(attr) ;
uiwait(gcf) ;
try
   dat = get(t,'Data') ;
catch
   return
end
attr = convert_table_data(attr,dat) ;
save_attr_file(aname,attr) ;
close(gcf)
return

function		attr = load_attr_file(f,attr)
%
while ~feof(f),
   ss = fgetl(f) ;
	if isempty(ss), break, end
   if ss(1) == '%', continue, end     % skip comments
	[fld,remn] = strtok(ss,',') ;
	if ~isempty(remn),
		val = sscanf(remn,',%d') ;
		if ~isempty(val),
			attr.(fld) = val ;
		end
	end
end
fclose(f) ;
return

function		save_attr_file(fname,attr)
%
f = fopen([fname '.txt'],'wt') ;
fprintf(f,'%%NAME D4 format attribute table\n') ;
fprintf(f,'%%DEVID %s\n',fname([6:9 11:14])) ;
fprintf(f,'%%TIME %s\n',datestr(now)) ;
fprintf(f,'%%DATA attribute,number,data\n') ;
afld = fieldnames(attr) ;
for k=1:length(afld),
	v = attr.(afld{k}) ;
	fprintf(f,'%s,%d',afld{k},v(1)) ;
	if v(1)>0,
		fprintf(f,',%d',v(2:end)) ;
	end
	fprintf(f,'\n') ;
end
fprintf(f,'%%ENDDATA\n') ;
fclose(f);
return

function		attr = default_attr
%
attr.PL = [3,20000,30000,0] ;
attr.PH = [3,10000,15000,0] ;
attr.A8 = [6,8000,0,8000,0,8000,0] ;
attr.A4 = [6,4000,0,4000,0,4000,0] ;
attr.A2 = [6,2000,0,2000,0,2000,0] ;
attr.AM = [1,1346] ;
attr.MH = [6,4800,0,4800,0,4800,0] ;
attr.MM = [1,258] ;
attr.BA = [2,500,120] ;
attr.SL = [3,-184,6000,15] ;
attr.SH = [3,-172,6000,15] ;
attr.GP = [1,0] ;
attr.VF = [2,0,0] ;
return

function t = attr_table(attr)
%
ascf = 1000/9.81 ;
dat =  {'Pressure sensor','low gain','full scale',attr.PL(2)/10,'m';...
        '','','gain',attr.PL(3)/10,'m/U';
        '','','offset',attr.PL(4)/10,'m';...
        '','high gain','full scale',attr.PH(2)/10,'m';...
        '','','gain',attr.PH(3)/10,'m/U';...
        '','','offset',attr.PH(4)/10,'m';...
        'Accelerometer','2g','x-axis gain',attr.A2(2)/ascf,'m/s2/U';
        '','','x-axis offset',attr.A2(3)/ascf,'m/s2';...
        '','','y-axis gain',attr.A2(4)/ascf,'m/s2/U';
        '','','y-axis offset',attr.A2(5)/ascf,'m/s2';...
        '','','z-axis gain',attr.A2(6)/ascf,'m/s2/U';
        '','','z-axis offset',attr.A2(7)/ascf,'m/s2';...
        '','4g','x-axis gain',attr.A4(2)/ascf,'m/s2/U';
        '','','x-axis offset',attr.A4(3)/ascf,'m/s2';...
        '','','y-axis gain',attr.A4(4)/ascf,'m/s2/U';
        '','','y-axis offset',attr.A4(5)/ascf,'m/s2';...
        '','','z-axis gain',attr.A4(6)/ascf,'m/s2/U';
        '','','z-axis offset',attr.A4(7)/ascf,'m/s2';...
        '','8g','x-axis gain',attr.A8(2)/ascf,'m/s2/U';
        '','','x-axis offset',attr.A8(3)/ascf,'m/s2';...
        '','','y-axis gain',attr.A8(4)/ascf,'m/s2/U';
        '','','y-axis offset',attr.A8(5)/ascf,'m/s2';...
        '','','z-axis gain',attr.A8(6)/ascf,'m/s2/U';
        '','','z-axis offset',attr.A8(7)/ascf,'m/s2';...
        '','','map',attr.AM(2),'map number';...
        'Magnetometer','','x-axis gain',attr.MH(2)/10,'uT/U';
        '','','x-axis offset',attr.MH(3)/10,'uT';...
        '','','y-axis gain',attr.MH(4)/10,'uT/U';
        '','','y-axis offset',attr.MH(5)/10,'uT';...
        '','','z-axis gain',attr.MH(6)/10,'uT/U';
        '','','z-axis offset',attr.MH(7)/10,'uT';...
        '','','map',attr.MM(2),'map number';...
        'Sound','low gain','sensitivity',attr.SL(2),'dB re U/uPa';...
        '','','high -3dB freq',attr.SL(3)/100,'kHz';...
        '','','low -3dB freq',attr.SL(4)*10,'Hz';...
        '','high gain','sensitivity',attr.SH(2),'dB re U/uPa';...
        '','','high -3dB freq',attr.SH(3)/100,'kHz';
        '','','low -3dB freq',attr.SH(4)*10,'Hz';...
        'Battery','','capacity',attr.BA(2),'mAhr';...
        '','','charge time',attr.BA(3),'mins';...
        'GPS','','version',attr.GP(2),'';...
        'VHF','','frequency',attr.VF(2)+attr.VF(3)/1000,'MHz';...
        } ;
columnname =   {'Sensor','Config','Attribute','Value','Unit'};
columnformat = {'char','char','char','bank','char'};
columneditable =  [false false false true false]; 
t = uitable('Units','normalized','Position',...
            [0.025 0.1 0.95 0.85], 'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', columneditable,...
            'ColumnWidth',{100,'auto','auto','auto'},...
            'FontSize',8,...
            'RowName',[]);
         
uicontrol('Units','normalized','String', 'Save',...
        'Position', [0.25 0.025 0.15 0.05],...
        'Callback', 'uiresume(gcbf)');
uicontrol('Units','normalized','String', 'Cancel',...
        'Position', [0.6 0.025 0.15 0.05],...
        'Callback', 'close(gcbf)');
return
 
function  attr = convert_table_data(attr,dat)
%
ascf = 1000/9.81 ;
d = horzcat(dat{:,4}) ;
attr.PL(2:end) = round(d(1:3)*10) ;
attr.PH(2:end) = round(d(4:6)*10) ;
attr.A2(2:end) = round(d(7:12)*ascf) ;
attr.A4(2:end) = round(d(13:18)*ascf) ;
attr.A8(2:end) = round(d(19:24)*ascf) ;
attr.AM(2) = round(d(25)) ;
attr.MH(2:end) = round(d(26:31)*10) ;
attr.MM(2) = round(d(32)) ;
attr.SL(2:end) = round([d(33) d(34)*100 d(35)/10]) ;
attr.SH(2:end) = round([d(36) d(37)*100 d(38)/10]) ;
attr.BA(2:3) = round(d(39:40)) ;
attr.GP(2) = round(d(41)) ;
attr.VF(2:3) = [floor(d(42)) rem(d(42),1)/1000] ;
return
