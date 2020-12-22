function q = dcm2quat(T)
%
%   q = dcm2quat(T)
%   Give the quaternion associated with the rotation matrix T.
%   Output q is a n x 4 array.
%
%   Convention used for T is the following:
%   To rotate a basis, post multiply by T.
%   To transform a vector sensor measurement, pre-multiply by T'.
%
%   Anne Piemont
%   Created 13 Aug 2013
%   Last modified 12 Sep 2013
%  
q = zeros(size(T,3),4);
for k=1:size(T,3)
    [V,D] = eig(T(:,:,k));
    [~,col] = find(abs(D-1)<1e-10);
    if length(col)==3 % T(:,:,k) is the identity matrix
        q(k,:) = [1,0,0,0];
    else
        u = V(:,col)/norm(V(:,col)); % u=unit eigenvector associated with eigenvalue 1
        % build a new basis
        if u(1)==0 && u(2)==0
            v = [1;0;0];
        else
            v = [-u(2);u(1);0];
        end
        v=v/norm(v);
        w=cross(u,v); % [u,v,w] is a right-handed oriented triplet
        P = [u,v,w];
        R = P^-1*T*P; % R = [1,0,0;0,cos(theta),sin(theta);0,-sin(theta),cos(theta)]
        q(k,1) = 1/2*sqrt(1+trace(T(:,:,k))); % trace=1+2*cos(theta) and q(k,1)=cos(theta/2)
        q(k,2:4) = sign(R(3,2))*sqrt(1-(q(k,1))^2)*u'; % q(k,2:4)=sin(theta/2)*u 
     end;
end