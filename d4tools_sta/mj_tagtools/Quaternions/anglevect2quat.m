function q = anglevect2quat(theta,u)
%
%   q = anglevect2quat(theta,u)
%   Give the unit quaternion corresponding to a rotation of angle theta
%   around axis u.
%   Inputs: theta is in radians and u is a n x 3 array.
%
%   Anne Piemont
%   Created 14 Aug 2013
%   Last modified 21 Aug 2013
%
if length(theta)~=size(u,1)
    help anglevect2quat
    return;
end;
u = u./sqrt(u.^2*ones(3)); %make unit vector
u(isnan(u)) = 0;
q = [cos(theta/2),sin(theta/2)*[1,1,1].*u];