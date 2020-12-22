function 	d4writeattr(did,CAL,initials)
%
%     d4writeattr(did,CAL,initials)
%

if ischar(did),
	aname = lower(did(isstrprop(did,'alphanum'))) ;
else
   aname = sprintf('%x',did(1)) ;
end

aname = ['attr_' aname(1:4) '_' aname(5:8)] ;
f=fopen([aname '.txt'],'r') ;

if f<=0,
   fprintf('Unable to read attribute file for tag %s %s\n',...
      aname(1:4),aname(5:8)) ;
		
	% TODO: give option to make a new attribute file based on a template
	%DEVID ffffffff
	%TIME 12:57:50 12-May-2017 UTC
	%f=fopen('attr_ffff_ffff.txt','r') ;
   return
end

fullname = which([aname '.txt']) ;

% get attributes line-by-line
S = {} ;
A = [] ;
while ~feof(f),
   ss = fgetl(f) ;
	if isempty(ss), break, end
	S{end+1} = ss ;
	A(end+1,:) = ss(1:2) ;
end
fclose(f) ;

% find attributes matching those in the CAL structure
flds = fieldnames(CAL) ;
for k=1:length(flds),
	if ~isfield(CAL.(flds{k}),'attr'),
		continue
	end
	attr = CAL.(flds{k}).attr ;
	kk = find(A(:,1)==attr(1) & A(:,2)==attr(2)) ;
	if isempty(kk),
		S{end+1} = char(attr) ;
		kk = length(S) ;
	end
	S{kk} = editattr(S{kk},CAL.(flds{k})) ;
end

if nargin<3 || isempty(initials),
	initials = 'UNKNOWN' ;
end

c = ['%LAST EDITED BY: ',initials,' AT ',datestr(clock)] ;
if A(end,1)=='%',	
	S{end} = c ;
else
	S{end+1} = c ;
end

f=fopen(fullname,'wt') ;
if f<=0,
   fprintf('Unable to write attribute file for tag %s %s\n',...
      aname(1:4),aname(5:8)) ;
   return
end

for k=1:length(S),
	if ~isempty(S{k}),
		fprintf(f,'%s\n',S{k}) ;
	end
end
fclose(f) ;
return


function	 s = editattr(s,cal) ;
%
switch s(1:2)
	case {'A8','A4','A2'}
		s = sprintf('%s,6,%d,%d,%d,%d,%d,%d',s(1:2),round(1000*cal.poly'/9.81)) 
	case 'MH'
		s = sprintf('%s,6,%d,%d,%d,%d,%d,%d',s(1:2),round(10*cal.poly')) 
	case {'PH','PL'}
		s = sprintf('%s,3,%d,%d,%d',s(1:2),round(10*cal.range),round(10*cal.poly)) 
	case {'SH','SL'}
		s = sprintf('%s,3,%d,%d,%d',s(1:2),round(cal.sens),round(cal.bandwidth/10)) 
	case 'GP'
	case 'VF'
	case 'BA'
end
return
	
