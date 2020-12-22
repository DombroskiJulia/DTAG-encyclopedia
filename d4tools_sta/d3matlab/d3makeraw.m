function    d3makeraw(recdir,prefix)
%
%     d3makeraw(recdir,prefix)
%     Read swv files from long D3 deployments, interpolate over
%     GPS outages and save as raw matlab files, one per recording.
%
%     markjohnson@st-andrews.ac.uk
%     29 july 2015

suffix = 'swv' ;
% find recordings
[ct,ref_time,fs,fn,recdir] = d3getcues(recdir,prefix,suffix) ;
fnums = unique(ct(:,1)) ;     % get the file numbers

for k=1:length(fn),     % for each recording
   X = d3parseswv([recdir fn{k},'.',suffix]) ;  % read in swv files
   kl = find(X.fs==fs) ;      % find all the lowest rate channels
   xx = [X.x{kl}] ;            % make a low rate sensor matrix
   z = diff(all(xx==0,2)) ;    % find when all of the low rate channels are 0
   k1 = find(z>0) ;           % last points before outages
   k2 = find(z<0) ;           % last point of outages
   ovec = zeros(size(xx,1),1) ;
   for kk=1:length(k1),
      ovec(k1(kk)+1:k2(kk)) = 1 ;
   end  
   X.outage = ovec ;

   for kc=1:length(X.x),      % for each channel
   	xx = X.x{kc} ;
      kk1 = k1*X.fs(kc)/fs ;
      kk2 = k2*X.fs(kc)/fs ;
      for kk=1:length(kk1),
         xx(kk1(kk)+1:kk2(kk)) = interp1([0;kk2(kk)-kk1(kk)+1],[xx(kk1(kk));xx(kk2(kk)+1)],(1:kk2(kk)-kk1(kk))') ;
      end
      X.x{kc} = xx ;
   end


   st = ct(find(ct(:,1)==fnums(k),1),2) ;
   [dv X.start] = d3datevec(ref_time,st) ;
   matfn = [recdir fn{k},'swv.mat'] ;
   save(matfn,'X') ;
end
