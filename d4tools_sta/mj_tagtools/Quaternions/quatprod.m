function Q = quatprod(p,q)
%
%   Q = quatprod(p,q)
%   Multiply quaternions.
%   Inputs p and q are quaternions i.e. n x 4 arrays.
%   Quaternions can be seen as an association of a scalar and a vector and
%   can be used to represent rotations - the vector being the axis and the
%   scalar being the angle.
%
%   Anne Piemont
%   Created 13 Aug 2013
%   Last modified 20 Aug 2013
%   
Q(:,1) = p(:,1).*q(:,1) - p(:,2).*q(:,2) - p(:,3).*q(:,3) - p(:,4).*q(:,4);
Q(:,2) = p(:,1).*q(:,2) + p(:,2).*q(:,1) + p(:,3).*q(:,4) - p(:,4).*q(:,3);
Q(:,3) = p(:,1).*q(:,3) - p(:,2).*q(:,4) + p(:,3).*q(:,1) + p(:,4).*q(:,2);
Q(:,4) = p(:,1).*q(:,4) + p(:,2).*q(:,3) - p(:,3).*q(:,2) + p(:,4).*q(:,1);
