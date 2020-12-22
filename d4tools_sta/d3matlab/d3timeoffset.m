function    t = d3timeoffset(recdir,depid,suffix1,suffix2)

%    t = d3timeoffset(recdir,depid,suffix1,suffix2)
%
%

if nargin<4,
   help d3timeoffset
   return
end

[ct,ref_time1] = d3getcues(recdir,depid,suffix1) ;
[ct,ref_time2] = d3getcues(recdir,depid,suffix1) ;
t = ref_time1 - ref_time2 ;
