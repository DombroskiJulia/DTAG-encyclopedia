function    BAD = readbadblocks(fname)
%
%    BAD = readbadblocks(fname)
%     Read a bad block file generated by a D3 device.
%     BAD is a 2-column matrix with chip number and block number
%     as the two columns.

xx = readcsv(fname,'%',-1);
BAD = [str2num(strvcat(xx{:,1})) str2num(strvcat(xx{:,2}))];