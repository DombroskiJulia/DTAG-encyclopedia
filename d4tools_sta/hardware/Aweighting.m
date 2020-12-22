function    S = Aweighting(f)
%
%    S = Aweighting(f)
%     Returns the amplitude of an A-weighting filter at frequencies f in
%     Hz.
%     Source: Wikipedia

S = 1.259*12200^2*f.^4./((f.^2+20.6^2).*sqrt((f.^2+107.7^2).*(f.^2+737.9^2)).*(f.^2+12200^2)) ;
