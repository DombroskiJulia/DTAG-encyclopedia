function   depth2 = zoc2(depth)

%   depth2 = zoc2(depth)
%   Interactive zero-offset correction for depth data from biologging tags. 
%   User-defined surface points are marked over the course of the
%   deployment. Depth is corrected assuming the surface is a straight-line 
%   passing through these points.
%
%   Click surface points on display
%   When done press enter.
%
%   Input:
%   depth is a vector of depth samples in meters. The data can have any sampling rate.
%
%   Returns:
%   depth2 is a vector of the same length as the input but with the corrected
%     depths. The unit and sampling rate are the same as for the input.
%
%   Sascha Hooker sh43@st-andrews.ac.uk 6/2/18

clf
plot(depth); axis([0 size(depth,1) 0 20]); axis ij; hold on;
corrdep=[];
[x, y] = ginput(1); % Takes first ZOC depth (at start of deployment)
x=1;
while 1;
    [X, Y] = ginput(1);  %Takes consecutive ZOC depths along deployment
    if ~isempty(Y),
      corrdep=[corrdep linspace(y, Y, X-x)]; %builds linear connections between points
      plot(corrdep', 'r');  %Shows progress
      y=Y;x=X;
    else
      break
    end
end

if size(corrdep,2)>size(depth,1)  
    corrdep=corrdep(1:size(depth,1));  %If clicked past end of file will crop
else corrdep=[corrdep linspace(y, y, size(depth,1)-size(corrdep,2))]; %Else will fill in to end
end

depth2=depth-corrdep';  %Corrected depths
end
