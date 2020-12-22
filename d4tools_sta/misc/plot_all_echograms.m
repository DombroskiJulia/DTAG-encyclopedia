function    plot_all_echograms(tag,bzn)
%
%    plot_all_echograms(tag)
%
rdir = '/tag_data/data' ;
fkey = '_ex*.mat' ;
ffmt = '_ex%d.mat' ;
figfmt = '%s_bz%d' ;
ddir = [rdir '/' tag '/'] ;
if nargin<2,
   fnames = dir([ddir tag fkey]) ;
   bzn = [] ;
else
   fnames(1).name = sprintf('tag_ex%d.mat',bzn(1)) ;
end

loadprh(tag) ;
J = njerk(A,fs) ;
for k=1:length(fnames),
   if length(bzn)<k,
      bzn(k) = sscanf(fnames(k).name,[tag ffmt]);
   end
   figure(1),clf
   subplot(211)
   plot_echogram(tag,bzn(k)) ;
   xlim = get(gca,'XLim') ;
   subplot(212)
   plott(J,fs,0);
   axis([bzn(k)+xlim 0 800]);
   figname = sprintf(figfmt,tag,bzn(k)) ;
   print('-djpeg99',[ddir figname]) ;
end
