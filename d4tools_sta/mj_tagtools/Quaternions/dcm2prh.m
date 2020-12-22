function [p,r,h] = dcm2prh(T)
%
%   prh = dcm2prh(T)
%   Give pitch, roll and heading corresponding to the input rotation matrix.
%
%   Convention used for T is the following:
%   To rotate a basis, post multiply by T.
%   To transform a vector sensor measurement, pre-multiply by T'.
%   
%   Outputs are in radians.
%
%   Anne Piemont
%   Created 13 Aug 2013
%   Last modified 21 Aug 2013
%
p = zeros(size(T,3),1);
r = zeros(size(T,3),1);
h = zeros(size(T,3),1);

for k=1:size(T,3)
    p(k) = asin(T(3,1,k));
    r(k) = atan2(T(3,2,k),T(3,3,k));
    h(k) = atan2(T(2,1,k),T(1,1,k));
end