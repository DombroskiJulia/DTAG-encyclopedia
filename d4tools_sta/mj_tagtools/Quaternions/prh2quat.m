function q = prh2quat(p,r,h)
%
%   q = prh2quat(p,r,h) or q = prh2quat([p,r,h])
%   Give the quaternion associated with pitch, roll and heading.
%   Output q is a nx4 array.
%
%   Anne Piemont
%   Created 13 Aug 2013
%
if nargin==1
    h = p(:,3);
    r = p(:,2);
    p = p(:,1);
end
T=makeT(p,r,h);
q=dcm2quat(T);