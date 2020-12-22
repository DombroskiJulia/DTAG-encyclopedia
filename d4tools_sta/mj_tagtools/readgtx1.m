function    [PP,starttime] = readgtx1(fname,fs)
%
%    [P,starttime] = readgtx1(fname,fs)
% Read and extract data from an EXTGPS text file containing NMEA sentences.
% fname is the filename. fs is the nominal audio sampling rate for the recording.
% Lines starting with % are ignored as comments. The following NMEA
% sentences are supported. All other sentences are ignored.
%
% $DTCLK,n*
%   n is the number of ADC samples since the start of recording corresponding to
%   the time in the following $GPRMC and $GPGGA sentences plus one second.
%
% $DTCNT,n*
%   n is the number of ADC samples since the start of recording corresponding to
%   the time in the preceding $GPRMC and $GPGGA sentences plus one second.
%
% $GPRMC,hhmmss,A,latitude,N,longitude,W,sog,cog,yymmdd,decl,W,*checksum
%   time is in UTC.
%   latitude and longitude are in ddmm.mmmm where dd = degrees, mm=minutes
%   and the following letter N/S or W/E specifies the hemisphere.
%   decl is the magnetic declination and the following letter W or E
%   specifies the direction (this letter may be missing in some sentences - default
%   value is east?)
%
% $GPGGA,hhmmss,latitude,N,longitude,W,quality,num_sats,hdop,height,M,geoidal_height,M,,*checksum
%   quality: 0=no fix, 1=non-differential fix, 2=differential fix
%   num_sats: number of satellites received (%d)
%   hdop: hozizontal dilution of precision (%f)
%   height above mean sea level (%f) (this may not be given)
%   geoidal height (%f) (this may not be given)
%
% $GPGLL,latitude,N,longitude,W,hhmmss,status,mode,*checksum
%   status: A=valid position, V=warning
%   mode: A=autonomous, D=differential, E=estimated, N=data invalid
%
% Returns:
%     P.gpstime
%     P.latitude
%     P.longitude
%     P.cuetime
%     P.diffsamples
%     P.starttime
%
% cuetime is the number of seconds since tagon according to the tag clock.
% gpstime is the GPS second-of-day
% latitude and longitude are in decimal degrees with -ve indicating W or S, respectively.
% NaN is used whenever a field value is unknown or if the GPS strings indicate an invalid
% value.
%
% starttime is the back-calculated GPS date and time of the first ADC sample:
%  [yr mon day hr min sec]
%
% mark johnson, WHOI
% majohnson@whoi.edu
% last modified: April 2008

PP = [] ; starttime = [] ;

if nargin<1,
	help readgtx1
	return
end

if nargin<2,
   fs = 1 ;
end

f = fopen(fname,'rt') ;
if f<0,
   fprintf(' Unable to open file - check name\n') ;
   return
end

Pwidth = 4 ;
P = NaN*zeros(1000,Pwidth) ;    % allocate some space for P
V = NaN ;
goodcnt = 0 ;
n = 0 ;
while 1,
   s = fgetl(f) ;
   if s==-1,
      done = 1 ;
      break ;
   end

   % find where the NMEA message is on the line
   ks = max(findstr(s,'$')) ;
   ke = min(findstr(s,'*')) ;

   % check if this is a legitimate NMEA sentence
   if ~isempty(s) & length([ks ke])==2 & ke>ks,
      % which NMEA sentence is it?
      s = s(ks:ke) ;
      [mess,ss] = strtok(s(2:end),',') ;
      switch mess,
         case {'DTHDR','DTERR'}                % do nothing for the header
         case {'DTCLK','DTCNT'},
            nn = str2double(strtok(ss,',')) ;
            if ~isempty(nn),
               if isequal(mess,'DTCLK'),
                  V = nn ;                   % set the state
               elseif length(V)==3 & all(~isnan(V)) & goodcnt>1,
                  n = n+1 ;
                  P(n,:) = [V(1:3)+[1,0,0] nn] ;
                  V = NaN ;
               end
            else
               V = NaN ;
            end

         otherwise
            x = nmeaparse(s) ;
            if all(~isnan(x.position)) & all(~isnan(x.time(4:6))),
               if length(V)==1 & ~isnan(V),        % there was a prior DTCLK
                  n = n+1 ;
                  P(n,:) = [x.time(4:6)*[3600;60;1]-1,x.position,V] ;
                  V = NaN ;
               else
                  V = [x.time(4:6)*[3600;60;1],x.position] ;
               end
               goodcnt = goodcnt+1 ;
            else
               goodcnt = 0 ;
            end
      end
   end

   if n==size(P,1),
      P(end+(1:1000),:) = NaN ;
   end
end

fclose(f) ;

if n==0,
   return
end

k = 1:n ;
PP.gpstime = P(k,1) ;
PP.latitude = P(k,2) ;
PP.longitude = P(k,3) ;
PP.cuetime = (P(k,4)-1)/fs ;
PP.diffsamples = [NaN;diff(P(k,4))] ;

m = min(n,3) ;
initialfs = diff(P([1 m],4))/diff(P([1 m],1)) ;
st = P(1,1)-P(1,4)/initialfs ;
PP.starttime = st ;
starttime = [floor(st/3600) floor(rem(st,3600)/60) rem(st,60)] ;
return
