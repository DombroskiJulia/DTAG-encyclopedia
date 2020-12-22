function    showbzseq(RR)
%
%    showbzseq(RR)
%

cax = [-97 -37] ;       
figure(1),clf
ax1 = axes('position',[0.13 0.65 0.78 0.25]);
ax2 = axes('position',[0.13 0.11 0.78 0.44]);
tz = RR{1}{2}(1) ;

for k=1:length(RR),
   axes(ax1) ;
   tcl = RR{k}{2}-tz ;
   semilogy(tcl(1:end-1),diff(tcl),'.') ;
   hold on
   axes(ax2) ;
   imageirreg(tcl,RR{k}{1},RR{k}{3}');
   hold on
end

axes(ax1) ;
grid on
axis([0 max(tcl) 0.002 0.4]) ; 
ylabel('ICI, s')
set(gca,'YTick',[0.003 0.03 0.3],'YTickLabel',[0.003 0.03 0.3])

axes(ax2) ;
grid on
axis([0 max(tcl) min(RR{1}{1}) max(RR{1}{1})]) ; 
colormap(jet) ;
caxis(cax)
xlabel('Time, s')
ylabel('Distance, m')
