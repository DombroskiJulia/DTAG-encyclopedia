function    x = readcchex(fname,N)
%
%     x = readcchex(fname,[N])
%     Read hexadecimal data from a text file produced by
%     Code Composer using options 'file->data->save'
%     If argument N is given, only read the first N
%     values in the file. Otherwise read all of the values.
%     Returns the data as an integer vector in x.
%
%     mark johnson
%     majohnson@whoi.edu
%     Last modified: 27 May 2006


if nargin<1,
   help readcchex
   return
end

f = fopen(fname,'rt') ;
if f<0,
   fprintf('Unable to open file %s\n',fname) ;
   return ;
end

hdr = fgetl(f) ;
v = zeros(5,1) ;
for k=1:5,
   [ss hdr] = strtok(hdr) ;
   v(k) = hex2dec(ss) ;
end

if nargin<2 | N>v(5),
   N = v(5) ;
end

x = zeros(N,1) ;
for k=1:N,
   ll = fgetl(f) ;
   x(k) = hex2dec(ll(3:end)) ;
end

fclose(f)
