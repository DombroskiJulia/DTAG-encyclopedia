function    daynightplot(timedate,depth,sst,srt)
%
%    daynightplot(timedate,depth,sst,srt)
%     Plot a multi-day dive profile with grey patches when it is nighttime.
%     timedate is a vector of Matlab date numbers
%     depth is a same-sized vector of dive depths
%     sst is the sunset time in hour of day (0-24 hours)
%     srt is the sunrise time in hour of day (0-24 hours)


daynum = timedate-floor(timedate(1)) ;
ndays = ceil(max(daynum))+1 ;
x = repmat([(sst-24)*[1 1] srt*[1 1]]'/24,1,ndays)+repmat([0:ndays-1],4,1) ;
ylims = [min(depth)-10 max(depth)+10] ;
y = repmat([ylims(2:-1:1) ylims]',1,ndays) ;
m = patch(x,y,0.6*[1 1 1]) ;   % Grey patches to show nighttime periods
alpha(0.5) ;                     % makes patches transparent
set(m,'EdgeColor','none')
hold on
plot(daynum, depth, 'b')
axis ij
axis([0 ndays-1 ylims])
