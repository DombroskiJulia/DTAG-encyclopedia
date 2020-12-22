function pasv(h)
% PASV Change to passive mode
%   PASV(FTP) changes the communication mode of FTP to passive mode.

% Idin Motedayen-Aval

% Make sure we're still connected.
connect(h)

if (nargin ~= 1)
    error('Incorrect number of arguments.')
end

h.jobject.enterLocalPassiveMode;

% There isn't an easier way to set the value of a StringBuffer.
h.passiveMode.setLength(0);
h.passiveMode.append('p');
