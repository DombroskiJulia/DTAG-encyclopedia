function [p,r,h] = quat2prh(q)
%
%
%   [p;r;h]=quat2prh(q)
%   Give pitch, roll and heading corresponding to the same rotation as the
%   input quaternion.
%   Input q is a quaternion i.e. a nx4 array.
%   Outputs are in radians.
%
%   Anne Piemont
%   Created 13 Aug 2013
%   Last modified 21 Aug 2013
%   
for k=1:size(q,1)
    q(k,:) = q(k,:)/norm(q(k,:));
end;
p = asin(2*q(:,2).*q(:,4)-2*q(:,1).*q(:,3));
r = atan2(2*q(:,1).*q(:,2)+2*q(:,3).*q(:,4),q(:,1).^2-q(:,2).^2-q(:,3).^2+q(:,4).^2);
h = atan2(2*q(:,1).*q(:,4)+2*q(:,2).*q(:,3),q(:,1).^2+q(:,2).^2-q(:,3).^2-q(:,4).^2);