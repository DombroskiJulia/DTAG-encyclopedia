function [timedate,depth,light,temp,fs] = inputdivedata(fname)

% [timedate,depth,light,temp,fs] = inputdivedata(filename)
% INPUTDIVEDATA reads comma separated file (day, mo, yr, hr, min, sec,
% depth, temp, light) and generates vector data outputs of
% sensor data.
%
% Inputs:
% filename is the name of the file containing the data including the
%   full directory path if the file is not on the Matlab path e.g.,
%     'C:\tag\practical2\w4553.csv or 'w4553.csv'
%
% Outputs
% timedate vector of Matlab date numbers for each data point
% depth    Pressure (depth) vector in meters
% light    Light sensor data vector
% temp     Temperature sensor data vector in degrees Celcius
% fs       is the sampling rate of the data in Hz
%
% About the example data: Data was obtained from a female Antarctic fur seal (‘w4553.csv’),
% recaptured after an 8-day foraging trip, on Bird Island, South Georgia.  The tag was set 
% to sample depth, temperature and light sensors at 1 Hz (i.e. once every second).  These 
% data were retrieved as a hexadecimal file (i.e. base 16) and converted using HexDecode 
% (Wildlife Computers) to a csv file.

if nargin<1
    help inputdivedata
    return
end

% Read in CSV file & extract data
dat=csvread(fname);
yr=dat(:,3); mo=dat(:,2); day=dat(:,1); hr=dat(:,4); min=dat(:,5); sec=dat(:,6);
depth=dat(:,7);
temp=dat(:,8);
light=dat(:,9);
timedate = datenum(yr, mo, day, hr, min, sec);
fs = 1./(mean(diff(timedate))*24*3600) ;    % calculate the effective sensor sampling rate
