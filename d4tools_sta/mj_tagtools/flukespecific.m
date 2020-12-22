function    [F,p,S]= flukespecific(Aw,Mw,fs,fc,thr)
%
%    [F,r,S] = flukespecific(Aw,Mw,fs,fc,thr)
%
%

n = round(5/8*fs/fc) ;
Mw = fir_nodelay(Mw,n,8*fc/(fs/2)) ;
n = round(5*fs/fc) ;
Mf = fir_nodelay(Mw,n,fc/(fs/2)) ;
Mt = Mw-Mf ;
qm = Mf(:,1).^2+Mf(:,3).^2 ;
V = [Mf(:,3) -Mf(:,1)].*repmat(1./qm,1,2) ;
p = real(asin(sum(V.*Mt(:,[1 3]),2))) ;
p(qm < 0.5*Mf(:,2)) = NaN ;

Af = fir_nodelay(Aw,n,fc/(fs/2)) ;
At = Aw-Af ;
S = At(:,1)-sin(p).*Af(:,3) ;
S(:,2) = At(:,3)+sin(p).*Af(:,1) ;

K = findzc(p,thr,fs/(fc*2)) ;
K(:,1) = (K(:,1)+K(:,2))/2 ;
K(:,2) = NaN ;
K(end+1,:) = [length(p)-1,NaN,0] ;

% find pk point in p after each zc
for k=1:size(K,1)-1,
   kk = floor(K(k,1)):ceil(min(K(k+1,1),K(k,1)+fs/fc)) ;
   pp = p(kk)*K(k,3) ;
   [m n] = max(pp) ;
   if n>1 & n<length(pp),
      K(k,2) = kk(1)+n-1+(pp(n-1)-pp(n+1))/(pp(n-1)+pp(n+1)-2*pp(n))/2 ;
   end
end

K = K(~isnan(K(:,2)),:) ;
F = NaN*ones(size(K,1)-2,6) ;
F(:,1:3) = [K(1:end-2,2)/fs (K(2:end-1,2)-K(1:end-2,2))/fs K(2:end-1,3)] ;
for k=1:size(K,1)-2,
   kk = round(K(k,2)):round(K(k+1,2)) ;
   F(k,4:6) = std([p(kk) S(kk,:)]) ;
end

F = F((F(:,2)>1/(8*fc)) & (F(:,2)<1/(2*fc)),:) ;
return
