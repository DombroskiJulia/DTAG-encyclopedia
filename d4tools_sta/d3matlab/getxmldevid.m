function       [id,fullid] = getxmldevid(fname)
%
%     [id,fullid] = getxmldevid(fname)
%     Extract the DEVID sentence from a D3 xml file.
%     fname can be the filename of a recording (with or without the
%      xml suffix or can be a xml structure read in with readd3xml.m
%
%     Returns the short id as an 8 digit number and the
%     full id as a string. fname should not have a suffix.
%
%     mark johnson
%     29 October 2009

id = [] ; fullid = [] ;

if nargin<1,
   help getxmldevid
   return
end

if isstr(fname),
   if any(fname=='.'),
      fname = fname(1:find(fname=='.',1)) ;
   end
   d3 = readd3xml([fname '.xml']) ;
else
   d3 = fname ;
end

if isfield(d3,'DEVID')
   fullid = d3.DEVID ;
else,
   fprintf(' XML file missing or incomplete: %s.xml\n',fname) ;
   return
end

% parse id string
ss = fullid ;
Z = {} ;
while ~isempty(ss),
   [Z{end+1},ss] = strtok(ss,', ') ;
end

if length(Z)<4,
   id = hex2dec(horzcat(Z{1:2})) ;
else
   id = hex2dec(horzcat(Z{3:4})) ;
end
return
