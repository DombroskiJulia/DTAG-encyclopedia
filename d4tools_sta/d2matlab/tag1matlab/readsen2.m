function s = readsen2(sens_filename)
% function sens = readsen2(sensor_filename)
%
% for use with C version of tagread2, to read the sensor data from
% DTAG V1.1
%
% sens = [time pagenum ax ay az aa magx magy magz temp pres batt 
%           1      2    3  4  5  6   7    8    9   10   11   12
%          extin mbridge pbridge sws];
%           13     14       15    16
%
% possible error in endianness of time



f = fopen(sens_filename, 'r');
s = fread(f, [17 inf], 'ushort');
s = s';
%nn = find( s(:, 2) < 0);
%s(nn, 2) = s(nn, 2) + 65536 ;
s(:,1) = s(:,2)*65536 + s(:,1) ;   % time is four bytes -- endianness??
s = [s(:, 1) s(:, 3:17)];
fclose(f);
