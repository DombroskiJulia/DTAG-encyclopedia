function       t = get_start_time(info)

%       t = get_start_time(info)

if nargin<1,
   help get_start_time
   return
end

try
   t=datevec(info.dephist_device_datetime_start,info.dephist_device_regset) ;
catch
   fprintf(' Info structure does not contain valid start time\n') ;
end
