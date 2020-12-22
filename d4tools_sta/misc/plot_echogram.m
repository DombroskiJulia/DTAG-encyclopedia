function    plot_echogram(x,fs,cl,rmax)
%
%   plot_echogram(x,fs,cl)
%

if nargin>=2 && ischar(x),
   tag = x ;
   cue = fs ;
   fbase = ['/tag_data/data/' tag '/' tag '_'] ;
   fenv = sprintf('%sex%d.mat',fbase,cue) ;
   fcl = sprintf('%sbz%dcl.mat',fbase,cue) ;
   load(fenv) ;
   try
      load(fcl) ;
   catch
      cl = getclick_trials(x,fs) ;
   end
end
if nargin<4,
   rmax = 8 ;
end

[X cl]=extractcues(x,cl(:,1)*fs,round(fs*[-0.0001 rmax/750]));
R = 20*log10(X) ;
NL = prctile(R(:),1)
imageirreg(cl/fs,(1:size(X(:,2)))'*750/fs-0.0001*750,R'-NL,1),axis xy
colormap('jet')
caxis([0 60])
