function [s,d] = readsen3(filebase,startchip,endchip,nblocks)
%
% function [s,d] = readsen3(filebase,[startchip,[endchip, [nblocks]]])
%
% for use with C version of tagread2x/tagread3, to read the sensor data from
% DTAG V1.1
%
% Input arguments:
% filebase: base filename (or complete filename if it is only argument)
%	    NOTE: base filename must include all characters prior to
%	    chip number, including underscores. e.g. filebase='tag7_'
%	    would correspond to filename 'tag7_01.sen' for chip 1, etc.
% startchip,endchip,nblocks: starting and ending chip numbers, and
%	    number of blocks per chip (nblocks defaults to 1024).
%
%
% Returns:
% s, an nx16 matrix, each column of which is a sensor time series
% as follows:
%
% s = [time page  ax  ay  az  aa  magx magy magz temp
%        1    2    3   4   5   6    7    8    9   10
%      pres batt extin mbridge pbridge sws];
%       11   12    13    14      15     16
%
% d, the six-element tag start time [year,mon,day,hour,min,sec].
% 
% To get the six-element time at any point n in the tag sensor record, do
% datevec( datenum([1900, 0, 0, 0, 0, s(n,1)]) )
%
% Partan/Johnson, WHOI   1999, minor revision 2001.


NSENS = 16 ;

switch nargin
	case 1,	startchip = 0 ;
		endchip = 0 ;
		nblocks = 0 ;
		fname = filebase ;
	case 2,	endchip = startchip ;
		nblocks=1024 ;
	case 3,	nblocks=1024 ;
	% case 4: everything is specified
end

MAXCHIP = (32/2)*nblocks ;	% number of sensor readings per chip 
nchip = endchip-startchip+1 ;
s = zeros(MAXCHIP*nchip,NSENS) ;

n = 0 ;
for k=startchip:endchip,
    if(k~=0),
        fname = sprintf('%s%02d.sen', filebase, k) ;
    end

    fprintf('reading %s...\n',fname) ;
    f = fopen(fname, 'r','l') ;
    ss = fread(f, [17 inf], 'ushort')' ;
    fclose(f);

    ss(:, 1) = ss(:,2)*65536 + ss(:,1) ;
    s(n+(1:length(ss)),:) = [ss(:,1) ss(:,3:17)] ;
    n = n+length(ss) ;
end

% s(1,1) is the tag start time in seconds since 1900
% Matlab's datenum is the Julian date from the base year (i.e. number of
% days from 1900, in this case). datevec converts it back to a 6-element time.
d = datevec( datenum([1900, 0, 0, 0, 0, s(1,1)]) );

