function CAL = d4readattr(did,psel,accsel,audsel)
%
%     CAL = d4readattr(did,psel,accsel,audsel)
%

if ischar(did),
	aname = lower(did(isstrprop(did,'alphanum'))) ;
else
   aname = sprintf('%x',did(1)) ;
end

aname = ['attr_' aname(1:4) '_' aname(5:8)] ;
f=fopen([aname '.txt'],'r') ;

if f<=0,
	CAL = [] ;
   fprintf('Unable to find attribute file for tag %s %s\n',...
      aname(6:9),aname(11:14)) ;
   return
end

% get attributes line-by-line
s = [] ;
while ~feof(f),
   ss = fgetl(f) ;
	if isempty(ss), break, end
   if ss(1) == '%', continue, end     % skip comments
   s(end+(1:length(ss)+1)) = [ss,','] ;
end
fclose(f) ;
s = s(1:end-1) ;		% delete trailing comma

if nargin<2,
	psel = 2 ;		% default pressure setting is high range
end
	
if nargin<3,
	accsel = 8 ;	% default accelerometer setting is 8g
end

if nargin<2,
	audsel = 2 ;	% default audio setting is high gain
end

CAL = d4decodeattr(char(s),psel,accsel,audsel) ;
