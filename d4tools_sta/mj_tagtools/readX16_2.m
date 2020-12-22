function    [A,fs,N,cols] = readX16_2(fname)
%
%    [A,fs,N,cols] = readX16_2(fname)
%     Read a CSV file from a Gulf Data Concepts X16_2
%     logging accelerometer.
%     This is a rough and ready reader that skips the
%     header information in the file and just reads
%     the accelerometer and time values.
%     Note that the X16_2 does not sample at a completely fixed
%     rate. The script resamples the data to a regular time
%     grid but will put NaN in where there was a large (>2/fs)
%     gap in the data. This seems to happen every 15 s.
%
%     mark johnson, SMRU
%     mj26@st-andrews.ac.uk

N = [] ; cols = [] ;
fid=fopen(fname);
if fid<0,
   fprintf('Unable to open file - check name\n');
   return
end

C = textscan(fid,'%n%n%n%n','delimiter',',','commentStyle', ';');
N = horzcat(C{:}) ;
fclose(fid) ;
cols = {'time','Ax','Ay','Az'} ;

% now resample to an even time scale
dt = diff(N(:,1)) ;
T = median(dt) ;
K = find(dt>2*T) ;
N(K,2:4) = NaN ;
t = N(1,1):T:N(end,1) ;
A = interp1(N(:,1),N(:,2:4),t) ;
fs = 1/T ;
