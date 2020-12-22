function    [rr,DV] = rotrange(P,pos)
%
%    [rr,DV] = rotrange(SVP,rpos)
%     Calculate the range and direction vector from a position
%     on earth in ECEF to satellites with ECEF positions in SVP. 
%     This function takes into account the fact that the earth
%     position moves a little over the time taken for the signal
%     to arrive from a satellite due to the earth's rotation.
%
we = 7.292115e-5 ;
v_light = 299792458 ;
DV = zeros(size(P,1),3) ;
rr = zeros(size(P,1),1) ;
for k=1:size(P,1),            % for each sv in P
   R = eye(3) ;
   done = 0 ; r = 0 ;
   while ~done,
      V = R*P(k,:)'-pos' ;		% vector from position to SV
      rnew = norm2(V) ;			% distance estimate to SV
      done = abs(rnew-r)<0.5 ;	% stop if distance estimate has not changed much
      r = rnew ;
      theta = rnew*we/v_light ;	% earth angle turned during propagation time
      R = [cos(theta) sin(theta) 0;-sin(theta) cos(theta) 0;0 0 1] ;	% rotation matrix
   end
   DV(k,:) = V'/r ;     % direction vector from receiver to SV
   rr(k) = r ;
end
return
