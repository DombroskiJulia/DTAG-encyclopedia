function    f = get_almanac(w,d)
%
%    get_almanac(w,d)
%     If an almanac for the gps week w and day d is not
%     already available in the data directory, this function
%     attempts to download one from a GPS data repository
%     and uncompress it.
%     Returns the filename if successful, empty otherwise.
%
%     Note: this function needs -
%     1. a patch to the FTP functionality in Matlab. See
%     the README file in the gps_proc directory.
%     2. uncompressor executable 7za.exe which should be
%     in the gps_proc directory.

gpsdir = '/tag/matlab/gps/gps_proc' ;
datadir = 'data' ;
fulldir = [gpsdir '/' datadir] ;
fname = sprintf('igr%04d%1d.sp3',w,d) ;
f = [fulldir '/' fname] ;
if exist(f,'file'),
   return ;
end

for k=1:3,     % try three times in case of internet timeouts
   try
      s=ftp('garner.ucsd.edu','anonymous','mj26@st-andrews.ac.uk');
      %pasv(s) ;
      cd(s,'products');
      cd(s,sprintf('%04d',w));
      fnz = [fname '.Z'] ;
      mget(s,fnz,fulldir);
      close(s);
   catch
      if k==3,
         fprintf('Unable to download almanac - check connection and try again\n') ;
         f = [] ;
         return ;
      end
   end
end

oname = [fulldir '/' fnz] ;
[n,e] = system([gpsdir '/7za.exe e ' oname ' -y -o' fulldir]) ;
if n>0,
   disp(e) ;
   f = [] ;
else
   delete(oname) ;
end
