function T = quat2dcm(q)
%
%   T = quat2dcm(q)
%   Give the rotation matrix corresponding to the input quaternion.
%   Input q is a quaternion i.e. a nx4 array.
%   To rotate a basis, post multiply by T.
%   To transform a vector sensor measurement, pre-multiply by T'.
%
%   Anne Piemont
%   Created 13 Aug 2013
%   Last modified 21 Aug 2013
%
T = zeros(3,3,size(q,1));
for k = 1:size(q,1)
    qu = q(k,:)/norm(q(k,:)); % unit quaternion
    T(1,1,k) = qu(1)^2 + qu(2)^2 - qu(3)^2 - qu(4)^2;
    T(1,2,k) = 2*qu(2)*qu(3) - 2*qu(1)*qu(4);
    T(1,3,k) = 2*qu(1)*qu(3) + 2*qu(2)*qu(4);
    T(2,1,k) = 2*qu(1)*qu(4) + 2*qu(2)*qu(3);
    T(2,2,k) = qu(1)^2 - qu(2)^2 + qu(3)^2 - qu(4)^2;
    T(2,3,k) = 2*qu(3)*qu(4) - 2*qu(1)*qu(2);
    T(3,1,k) = 2*qu(2)*qu(4) - 2* qu(1)*qu(3);
    T(3,2,k) = 2*qu(1)*qu(2) + 2*qu(3)*qu(4);
    T(3,3,k) = qu(1)^2 - qu(2)^2 - qu(3)^2 + qu(4)^2;
end
