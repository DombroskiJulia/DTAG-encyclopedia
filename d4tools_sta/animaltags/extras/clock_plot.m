function       [h,p,t] = clock_plot(N,nmax)

%    [h,p,t] = clock_plot(N,nmax)
%
%

G = [0.25 0.5 0.75] ;
C = exp(j*2*pi*(0:999)/1000);
%clf
h1 = plot(real(C),imag(C),'k-');
axis off,axis square
hold on
h2 = [] ;
for k=1:length(G),
   h2(k) = plot(G(k)*real(C),G(k)*imag(C),'k--');
end

tick = [0;-0.05];
h3 = []
h3(1) = plot([0;0],tick+1,'k') ;
h3(2) = plot(tick+1,[0;0],'k') ;
h3(3) = plot([0;0],-tick-1,'k') ;
h3(4) = plot(-tick-1,[0;0],'k') ;
set([h1 h2 h3],'LineWidth',1) ;
set(gca,'FontSize',11);

h4 = [] ;
P = [0;exp(-j*2*pi*(0:99)'/(100*length(N)))];
th = 2*pi*(0:length(N)-1)/length(N)-pi/2 ;
for k=1:length(N),
   p = N(k)/nmax*P*exp(-j*th(k)) ;
   h4(k) = patch(real(p),imag(p),'b');
end

%P = [0;exp(-j*2*pi*(0:99)'/(100*length(N(:,2))))];
%th = 2*pi*(0:length(N(:,2))-1)/length(N(:,2))-pi/2 ;
%for k=1:length(N(:,2)),
%p = N(k,2)/nmax*P*exp(-j*th(k)) ;
   %h4(k) = patch(real(p),imag(p),[17 17 17]);
%end 


str = {'0','6','12','18'} ;
offs = 0.05 ;
t = text([0;1+offs;0;-1-offs],[1+offs;0;-1-offs;0],str) ;
set(t,'FontSize',10)
set(t([1 3]),'HorizontalAlignment','center')
set(t(2),'HorizontalAlignment','left')
set(t(4),'HorizontalAlignment','right')
set(t([2 4]),'VerticalAlignment','middle')
set(t(1),'VerticalAlignment','bottom')
set(t(3),'VerticalAlignment','top')

h = [h1 h2 h3]
p = h4 ;
