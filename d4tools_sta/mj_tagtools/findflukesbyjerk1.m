function    [jk,K,GL] = findflukesbyjerk1(Aw,fs,fl,TH,tmax)
%
%     [jk,K,GL] = findflukesbyjerk1(Aw,fs,fl,TH,tmax)
%     EXPERIMENTAL: may change without notice!!
%     Produce the jerk signal (low-pass filtered
%     to fl Hz) and look for zero-crossings with hysteric threshold 
%     levels of +/- TH m/s^3. Zeros-crossings more than tmax
%     seconds apart are discarded.
%     Fluking rate is estimated over Tf(1) second bins spaced
%     at Tf(2) seconds.
%     e.g., for pilot whales use fl=2, TH=2, tmax=2.5, Tf=[5,1]
%
%     Returns: jk - the filtered jerk in m/s^3
%     K = [Kst,Ked,S], where Kst and Ked are the cues to the start
%     and end of each zero-crossing (i.e., the two threshold crossings)
%     and S is the sign of the zero-crossing.
%     fr = [meanfr_ingroup,fl/sec,fraction_fluked,time] is a matrix
%     of fluke-rate results. meanfr_ingroup is the mean of the 
%     instantaneous fluking rates, fl/sec is the number of flukes in
%     the interval divided by interval length (i.e., irrespective
%     of the proportion of time without fluking in the interval),
%     fraction_fluked is the proportion of the interval in which
%     there is fluking and time is the time in seconds of each
%     measurement.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     17 January 2008

if nargin<3,
   help findflukesbyjerk
   return
end

if size(Aw,2)<3,
   jk = diff(Aw(:,1))*fs*9.81 ;
else
   jk = diff(Aw(:,3))*fs*9.81 ;
end

jk = fir_nodelay(jk,4*fs/fl,fl/(fs/2)) ;

K = findzc(jk,TH,tmax*fs/2) ;

% find glides - any interval between zeros crossings greater than tmax
k = find(K(2:end,1)-K(1:end-1,2)>fs*tmax) ;
glk = [K(k,1)-1 K(k+1,2)+1] ;

% shorten the glides to only include sections with jerk < TH
glc = round(mean(glk,2)) ;
for k=1:length(glc),
   kk = glc(k):-1:glk(k,1) ;
   glk(k,1) = glc(k) - find(abs(jk(kk))>=TH,1)+1 ;
   kk = glc(k):glk(k,2) ;
   glk(k,2) = glc(k) + find(abs(jk(kk))>=TH,1)-1 ;
end

% convert sample numbers to time in seconds
K = [mean(K(:,1:2),2)/fs K(:,3)] ;               
GL = glk/fs ;
GL = GL(find(GL(:,2)-GL(:,1)>tmax/2),:) ;
