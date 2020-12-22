loadprh('md04_287a')
T=finddives(p,fs,400);
%ks=round(fs*T(1,1))+(431:966)';
%ks=round(fs*T(2,1))+(431:1000)';
%ks=round(fs*T(4,1))+(431:982)';
ks=round(fs*T(5,1))+(431:1006)';

%Ar=A*makeT([0 -0.7 9.6]*pi/180);
Ar = A ;
Al=fir_nodelay(Ar,400,0.25/(fs/2)) ;
Ah=Ar-Al;

[V,D] = eig(Ah(ks,:)'*Ah(ks,:)) ;
rr = sign(V(2,1))*asin(V(3,1));            % roll correction
yy = atan2(-V(1,1),V(2,1)) ;  % yaw correction

% constrain yy to +/- 90 degrees
if(abs(yy)>pi/2),
   yy = yy-sign(yy)*pi ;
end

[rr yy]*180/pi
AA=(Ah(ks,:)*makeT([0 rr yy]));
[Vc,Dc]=eig(AA'*AA) ; V(:,1)'
