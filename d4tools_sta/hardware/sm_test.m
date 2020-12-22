function    sm_test(port,V,t)

%   sm_test(port,V,t)
%

if nargin<1,
   help sm_test
   return
end

if nargin<2,
   V=[repmat((0:500:4000)',20,2)];
   V(:,3)=randn(180,1)>0;
end

if nargin<3,
   t = 1 ;
end

% test to make sure I understand the polynomial conversion coefficients
% COEF = single([89.6663970947265,-0.0542032003402,0.0000143271923,-0.0000000020766]) ;
% polyval(fliplr(COEF),0:500:4000)
% should give:
% [89.6664,65.8870,47.7138,33.5893,21.9560,11.2565,-0.0667,-13.5709,-30.8137]
HCOEF1 = {'3255B342','2D045EBD','D35E7037','1FB30EB1'} ;
HCOEF2 = {'3255B343','2E045EBD','D34E7037','1FB32EB1'} ;

t = max(t,1) ;
%V(:,3) = V(:,1)>1 ;
%V(:,1) = round((V(:,1)+40)*100) ;
%V(:,2) = round((V(:,2)+10)*1000) ;

% find and disable any old serial port and timer instances
v = instrfind('Type','serial','Status','open') ;
if ~isempty(v)
   fclose(v) ;
   delete(v) ;
end

v = timerfind('Running','on') ;
if ~isempty(v)
   stop(v) ;
end

% initialize the serial ports and timers
h = serial(port,'BaudRate',115200) ;
set(h,'InputBufferSize',1024) ;
try
   fopen(h) ;
catch
	fprintf('Unable to open port "%s": check it is connected and available',...
               get(h,'Name')) ;
   delete(h) ;
   return
end
pause(1)

fprintf('Connected to "%s"\n',port) ;
fwrite(h,13,'uchar')
pause(1)
fwrite(h,[abs('s-40 3 fe p') 13],'uchar')
pause(1)
fwrite(h,[abs('s-40 1 ff p') 13],'uchar')
pause(3)
% write to POLY register with depth and temp polynomials (two separate
% writes)
hc = reshape([lower(reshape(horzcat(HCOEF1{:}),2,16));repmat(' ',1,16)],1,[]) ;
mess = [abs(['s-2a 4 0 ' hc 'p']) 13] ;
fwrite(h,mess,'uchar') ;
pause(1)
hc = reshape([lower(reshape(horzcat(HCOEF2{:}),2,16));repmat(' ',1,16)],1,[]) ;
mess = [abs(['s-2a 4 1 ' hc 'p']) 13] ;
fwrite(h,mess,'uchar') ;
pause(1)
% write to CSR register with time
UT = datevec2posix ;    % get UNIX time
hd = [lower(reshape(dec2hex(UT),2,4));repmat(' ',1,4)] ;
ht = reshape(fliplr(hd),1,[]) ;
fwrite(h,[abs(['s-2a 0 1 ' ht 'p']) 13],'uchar')    % start recording
n = get(h,'BytesAvailable') ;
if n>0,
   fprintf(char(fread(h,n,'uchar'))')
else
   fprintf('No response from port\n');
   fclose(h) ;
   delete(h) ;
   return ;
end
pause(1) ;
D.h = h ;
D.V = V ;
D.k = 1 ;

timr = timer('TimerFcn',@writeport,'Period',t,...
             'ExecutionMode','fixedRate','UserData',D);
start(timr) ;
uiwait
stop(timr) ;
delete(timr) ;
fclose(h) ;
delete(h) ;
return


function    writeport(obj,eventdata)
%
D = get(obj,'UserData') ;
if D.k>size(D.V,1),
   stop(obj) ;
   return
end
v = D.V(D.k,:) ;
hd1 = reshape(fliplr([lower(reshape(dec2hex(v(1),4),2,2));repmat(' ',1,2)]),1,[]) ;
hd2 = reshape(fliplr([lower(reshape(dec2hex(v(2),4),2,2));repmat(' ',1,2)]),1,[]) ;
hd3 = [lower(dec2hex(v(3),2)) ' '] ;

fwrite(D.h,[abs(['s-2a 3 ' [hd3 hd1 hd2] 'p']) 13],'uchar')
fprintf('Env %d\n',D.k) ;
D.k = D.k+1 ;
set(obj,'UserData',D) ;
return
