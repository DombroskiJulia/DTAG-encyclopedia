loadprh('pw04_295b')
T=finddives(p,fs,400);
%ks=round(fs*T(1,1))+(210:550)';
%ks=round(fs*T(6,1))+(210:560)';
ks=round(fs*5012)+(0:408)';

%Ar=A*makeT([0 58 6.9]*pi/180);
Ar = A ;
Al=fir_nodelay(Ar,400,0.25/(fs/2)) ;
Ah=Ar-Al;

[V,D] = eig(Ah(ks,:)'*Ah(ks,:)) ;
[l,k] = min(diag(D)) ;
rr = sign(V(2,k))*asin(V(3,k));            % roll correction
yy = atan2(-V(1,k),V(2,k)) ;  % yaw correction

% constrain yy to +/- 90 degrees
if(abs(yy)>pi/2),
   yy = yy-sign(yy)*pi ;
end

[rr yy]*180/pi
AA=(Ah(ks,:)*makeT([0 rr yy]));
[Vc,Dc]=eig(AA'*AA) ; Vc(:,1)'
