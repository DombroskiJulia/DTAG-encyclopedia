function    [B,th] = wb_beampattern(A,F,theta)
%
%    [B,th] = wb_beampattern(A,F,theta)
%    Compute the broadband beam pattern of a piston with aperture radius A (in m)
%    at frequencies F (in Hz) and over the range of off-axis angles -theta to
%    theta (in radians). The beampattern is averaged over a frequency range
%    from F(1) to F(2).
%    B is the magnitude squared beam pattern at each off-axis angle th.
%

if nargin<3,
   theta = pi ;
end

c = 1500 ;
th = linspace(-theta,theta,1000)' ;
f = linspace(F(1),F(2),100) ;
x = sin(th)*(A/c*2*pi*f) ;
B = sum(abs(besselj(1,x')./x').^2)' ;
B = B*(1/max(B)) ;
