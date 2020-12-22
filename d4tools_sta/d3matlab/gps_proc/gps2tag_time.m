function    t = gps2tag_time(gT,start_time)

%    t = gps2tag_time(gT,start_time)

if isstruct(start_time),
   start_time = get_start_time(start_time) ;
end

if length(start_time)==1,
   start_time = datevec(gT) ;
end

t = etime(datevec(gT),repmat(start_time,size(gT,1),1)) ;
