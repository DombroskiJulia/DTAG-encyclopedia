function       gdB = getaudiogain(fname)
%
%     gdB = getaudiogain(fname)
%     Look through EVENT reports in a D3 xml file for AUDIO
%     gain settings.
%     fname can be the filename of a recording (with or without the
%      xml suffix or can be a xml structure read in with readd3xml.m
%
%     Returns the gain setting in dB. This should be added to the
%     base gain of the device to get the total gain. 
%
%     mark johnson
%     26 March 2016

gdB = [] ;

if nargin<1,
   help getaudiogain
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

if ~isfield(d3,'EVENT'),
   return
end

G = [] ;
for k=1:length(d3.EVENT),
   s = d3.EVENT{k} ;
   if ~isfield(s,'AUDIO'), continue, end
   s = s.AUDIO ;
   if ~isfield(s,'GAIN'), continue, end
   G = s ;
end

gdB = str2num(G.GAIN) ;
