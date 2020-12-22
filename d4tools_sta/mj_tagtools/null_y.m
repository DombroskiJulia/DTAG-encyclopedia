function [Mh,Q,pry] = null_y(Mh)
%
%  [Mh,Q,pry] = null_y(Mh)
%  EXPERIMENTAL!! CONSULT BEFORE USING
%  Minimize the rotation signal perpendicular to the x-z plane in
%  a section of high-pass filtered magnetometer data. This is done
%  by finding roll and yaw rotations that minimize the signal in
%  the y-axis of Mh.
%  Results:
%  Mh The corrected magnetometer data.
%  Q  The rotation matrix. This can be applied to other triaxial
%     measurements, e.g., Ah using Ah*Q.
%  pry   The pitch roll and yaw corrections (pitch correction is always 0)
%
%  markjohnson@st-andrews.ac.uk
%  Dec 2014

W = Mh'*Mh ;      % form outer product of Mh
[V,D] = eig(W) ;  % get eigenvalues and eigenvectors

% The eigenvector associated with the minimum eigenvalue of W
% should be the y-axis [0;1;0] if there is no residual roll or yaw. 
% Compute roll and yaw corrections to force it to be.
% We assume that W = Q*T where T is the outer produce of Mh on
% an ideally oriented tag and Q is the product of a roll and 
% yaw matrix.

rr = asin(V(3,1));            % roll correction
yy = atan2(-V(1,1),V(2,1)) ;  % yaw correction

% constrain yy to +/- 90 degrees
if(abs(yy)>pi/2),
   yy = yy-sign(yy)*pi ;
end

pry = [0 rr yy] ; 
Q = makeT(pry) ;              % the corresponding rotation matrix
Mh = Mh*Q ;                   % rotated Mh. This will now have its
           % minimum eigenvalue eigenvector parallel to the y axis
