function [theta,u] = quatanglevect(q)
%
%   theta = quatangle(q)
%   Give the angle of rotation associated with the input quaternion.
%   Input q is a quaternion i.e. a nx4 array.
%   Quaternions can be seen as an association of a scalar and a vector and
%   can be used to represent rotations - the vector being the axis and the
%   scalar being the angle.
%
%   Output theta is in radians.
%
%   Anne Piemont
%   Created 13 Aug 2013
%   Last modified 21 Aug 2013
%
v = sqrt(q.^2*[1;1;1;1]);
theta = 2*acos(q(:,1)./v);
u = sin(theta/2).^(-1)*[1,1,1].*q(:,2:4)./(v*[1,1,1]);
u(isnan(u)) = 0; % case sin(theta/2)=0