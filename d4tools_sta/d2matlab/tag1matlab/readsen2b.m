function s = readsen2(filebase,startchip,endchip)
%
% function s = readsen2(filebase,[startchip,[endchip]])
%
% for use with C version of tagread2, to read the sensor data from
% DTAG V1.1
%
% Returns an nx16 matrix, each column of which is a sensor time series
% as follows:
%
% s = [time page  ax  ay  az  aa  magx magy magz temp
%        1    2    3   4   5   6    7    8    9   10
%      pres batt extin mbridge pbridge sws];
%       11   12    13    14      15     16
%
% Partan/Johnson, WHOI   1999
%

MAXCHIP = 16384 ;     % expected size of the output matrix
NSENS = 16 ;

switch nargin
    case 1, startchip = 0 ;
            endchip = 0 ;
            fname = filebase ;
    case 2, endchip = startchip ;
end
    
nchip = endchip-startchip+1 ;
s = zeros(MAXCHIP,NSENS) ;

n = 0 ;
for k=startchip:endchip,
    if(k~=0),
        fname = sprintf('%s_%02d.sen',filebase,k) ;
    end

    fprintf('reading %s...\n',fname) ;
    f = fopen(fname, 'r','l') ;
    ss = fread(f, [17 inf], 'ushort')' ;
    ss(:, 1) = ss(:,2)*65536 + ss(:,1) ;   % time is four bytes -- endianness??
    nn = find(ss(:, 2) < 0);
    ss(nn, 2) = ss(nn, 2) + 65536 ;
    s(n+(1:length(ss)),:) = [ss(:,1) ss(:,3:17)] ;
    n = n+length(ss) ;
    fclose(f);
end
