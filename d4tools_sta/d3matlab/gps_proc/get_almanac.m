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

gpsdir = fileparts(which('get_almanac')) ;
datadir = [pwd '/temp'] ;
fname = sprintf('igr%04d%1d.sp3',w,d) ;
f = [datadir '/' fname] ;
if exist(f,'file'),
   return ;
end

for k=1:3,     % try three times in case of internet timeouts
   try
      s=ftp('garner.ucsd.edu','anonymous','info@animaltags.org');
      cd(s,'products');
      cd(s,sprintf('%04d',w));
      fnz = [fname '.Z'] ;
		%fprintf('getting %s...\n',fnz) ;
      L = mget(s,fnz,datadir);
      close(s);
		if ~isempty(L), break, end
   catch
      if k==3,
         fprintf('Unable to download almanac - check connection and try again\n') ;
         f = [] ;
         return ;
      end
   end
end

[n,e] = system([gpsdir '/7zip/7za.exe e ' L{1} ' -y -o' datadir]) ;
if n>0,
   disp(e) ;
   f = [] ;
else
   delete(L{1}) ;
end
