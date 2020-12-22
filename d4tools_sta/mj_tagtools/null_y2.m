function [Ah,Q,pry] = null_y2(Ah)
%
%  [Ah,Q,pry] = null_y2(Ah)
%  EXPERIMENTAL!! CONSULT BEFORE USING
%  Minimize the dynamic signals perpendicular to the x-z plane in
%  a section of high-pass filtered accelerometer data. This is done
%  by finding roll and yaw rotations that minimize the signal in
%  the y-axis of Ah.
%
%  Results:
%  Ah The corrected accelerometer data.
%  Q  The rotation matrix. This can be applied to other triaxial
%     measurements, e.g., Mh using Mh*Q.
%  pry   The pitch roll and yaw corrections (pitch correction is always 0)
%
%  markjohnson@st-andrews.ac.uk
%  Aug 2015

W = Ah'*Ah ;      % form outer product of Mh
[V,D] = eig(W) ;  % get eigenvalues and eigenvectors
[l,k] = min(diag(D)) ;

% The eigenvector associated with the minimum eigenvalue of W
% should be the y-axis [0;1;0] if there is no residual roll or yaw. 
% Compute roll and yaw corrections to force it to be.
% We assume that W = Q*T where T is the outer product of Ah on
% an ideally oriented tag and Q is the product of a roll and 
% yaw matrix.

rr = sign(V(2,k))*asin(V(3,k));  % roll correction
yy = atan2(-V(1,k),V(2,k)) ;     % yaw correction

% constrain yy to +/- 90 degrees
if(abs(yy)>pi/2),
   yy = yy-sign(yy)*pi ;
end

pry = [0 rr yy] ; 
Q = makeT(pry) ;              % the corresponding rotation matrix
Ah = Ah*Q ;                   % rotated Ah. This will now have its
           % minimum eigenvalue eigenvector parallel to the y axis
