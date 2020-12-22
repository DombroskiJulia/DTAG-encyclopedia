function   t= mcolbar(cax,c,ctitle)
%
%    mcolbar(c,ctitle)
%

patch(repmat([0;0;1;1],1,64),repmat([0;1;1;0],1,64)+repmat((0:63),4,1),linspace(cax(1),cax(2),64)) ;
shading flat
axis([0 1 0 63])
caxis(cax) ;
set(gca,'XTick',[],'YTick',interp1(cax,[0 63],c),'YTickLabel',c,'FontSize',9)
set(gca,'YAxisLocation','right')
t = title(ctitle) ;
set(t,'Position',[-0.33 68 1])
set(t,'HorizontalAlignment','left')
box on
