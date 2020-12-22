% Pick an appropriate deployment id. Usually you would follow the standard
% DTAG protocol of: 2-letter Latin species initials, 2-digit year, underscore,
% 3-digit Julian day of year, 1-letter animal of the day.
% Use julian_day() if you need to convert a date to a day number.
depid='rt19_127a' ;

% Make a name for the nc file that you are going to create. This should start 
% with the deployment id and then indicate what is in the file and the sampling 
% rate. There are no rules for how you indicate what is in the file but some
% ideas are here:
%	trk = position data from GPS
%	sens = all of the sensor data
%  p = depth data only
%  pAM = pressure, acceleration, magnetometer
%  aud = clips of audio
ncname = [depid 'sens5']; % 'sens5'

% Give the directory where the raw data is.
recdir=['F:\rt19\' depid] ;  % this makes a directory: 'E:\hs17\hs17_283b'

% Read in the raw data, for example using one of the following:
X = d3readswv_commonfs(recdir,depid,5);		% decimates to a common 5 Hz sampling rate
% or
X = d3readswv_commonfs(recdir,depid,25) ;		% decimates to a common 25 Hz sampling rate
% or
X = d3readswv(recdir,depid) ;		% decimates each channel by a factor of 5
% If you need to find out what the original sampling rates are of the different sensors, use:
X = d3readswv(recdir,depid,'info')

% In all cases, X will contain three fields:
%  X.x is the actual data in a cell array with one sensor channel per cell
%     To access the 8th sensor channel, you do X.x{8}
%     To access the first three sensor channels (assuming they are all the same size,
%     you do [X.x{1:3}]
%     If you used the 'info' option, X.x will be empty.
%  X.fs is a vector with the sampling rate for each sensor channel, in Hz
%  X.cn is a vector of the channel numbers - these are the id numbers that DTAGs use
%     to figure out what kind of data is in each sensor channel. Use d3channames(X) 
%     to find out which channels are present and in what order they are listed in X.x.
%     You can also do d3channames(recdir,depid) to see what sensors are in a dataset
%     before reading it in.

% Make an info structure for the deployment - put your own initials instead
% of 'xx'. Make sure that information about you and your study species is listed
% in the files: researchers.csv and species.csv. These should be in the 'user'
% directory in the tag tools and these are files that you maintain yourself. You
% may actually want to rename the user directory to something else so that it
% doesn't get overwritten when you download a new copy of the tag tools. Either
% way, make sure it is on the matlab path.
% The following line makes an info structure for a D4 tag deployed on a 'hs'
% (i.e., a harbour seal) by a person with initials 'xx':
info = make_info(depid,'D4',depid(1:2),'hv') ;

% Edit the fields in the info structure to give extra information, e.g., 
info.dephist_deploy_method = 'clamp' ;     % or 'suction cups' if on a whale
info.dephist_deploy_locality = 'Ningaloo Reef' ;
info.project_name = 'AIMS' ;
info.tagon=[2019,5,10,10,4,16];

% It may be easiest to make a script for each field trip that will generate
% an info structure like this:

% info = make_info(depid,'D4',depid(1:2),'sp');
% info.project_name = 'ONR Tag Design';
% info.project_datetime_start = '2018/06/04';
% info.project_datetime_end = '2018/06/10';
% info.dephist_deploy_locality = 'Cape Cod, Massachusetts';
% info.dephist_deploy_method = 'suction cup';
% info.dephist_deploy_location_lat = 41.7;
% info.dephist_deploy_location_long = -69.9;

% Generate sensor structures for each of the data types.
% Note that the sensor channels may change if your tag was recording a different
% set of sensors (e.g., ECG, light). Use d3channames if in doubt.
T = sens_struct(X.x{7},X.fs(7),depid,'temp') ;	% temperature
P = sens_struct(X.x{8},X.fs(8),depid,'press') ;	% pressure
A = sens_struct([X.x{1:3}],X.fs(1),depid,'acc') ;	% acceleration
M = sens_struct([X.x{4:6}],X.fs(4),depid,'mag') ; % magnetometer

S = sens_struct(S,5,depid,'spd') ; % speed
dot = sens_struct(dot,5,depid,'dot'); % prey density over threshold
dse = sens_struct(dse,5,depid,'dse'); 
tbf = sens_struct(tbf,5,depid,'tbf'); 

% get the calibration constants for this tag
CAL = d4findcal(recdir,depid) ;

T = apply_cal(T,CAL.TEMP) ;			% apply cal to the temperature
% The temperature measurement is internal to the tag and is not very
% accurate. It cannot be used as a water temperature measurement without
% careful calibration. It is however useful for compensating temperature
% effects in the sensors. This is why it has to be calibrated first.

P = apply_cal(P,CAL.PRESS,T) ;		% apply cal to the pressure

% Plot the pressure and check if it is correct when the animal surfaces.
% If not, do the following:
[P,pc] = fix_pressure(P,T);
% The calibration corrections are noted in P but you also need to add them
% to the calibration structure in case you want to do the calibration again
% for example, at a different sampling rate. 
CAL.PRESS.poly(2)=pc.poly(2);	% update the CAL for the pressure sensor offset
CAL.PRESS.tcomp=pc.tcomp;		% and the temperature compensation

% Plot the pressure again. If it is still not correct when the animal surfaces
% and the '0' pressure seems to be changing over time, do the following:
P1 = fix_offset_pressure(P,300,300);
% Plot P1 and adjust the last two numbers (300) up or down as required to
% make the surfacings look reasonable. See the help on fix_offset_pressure for
% guidance. When P1 looks good, rename it as P.

% Apply and check the calibration on the accelerometer as follows. This will
% try to improve the calibration based on the data. Note that auto_cal_acc does
% not implement any axis conversions, i.e., it ignores the accelerometer MAP. This
% is because the calibration polynomial in CAL.ACC works on the sensor axes not the
% tag axes. The MAP is applied in a later step.
[AA,ac] = auto_cal_acc(A,CAL.ACC) ;
% Plot AA or norm2(AA) to make sure it looks good. If it does, save the
% improved calibration:

CAL.ACC = ac ;

% Apply the calibration and map to get the final tag-frame accelerometer data:
A = apply_cal(A,CAL.ACC) ; A.frame='Animal';
M = apply_cal(M,CAL.MAG); M.frame='Animal';



% Once you have made changes to the CAL structure, save them to a cal file for this
% deployment:
save([depid 'cal.mat'],'CAL')
% You can retrieve this file later using CAL=d4findcal(depid);

% It is also a good idea to save the data you have got so far just in case something
% goes wrong. You can add more data later.
save_nc(ncname,P,T,A,M,S,dot,dse,info) ;

% Generate an RMS jerk vector with a sampling rate of e.g., 5 Hz. This takes some
% time to run because it reads the entire high-rate accelerometer data.
J = d3rmsjerk(recdir,depid,CAL.ACC.poly,5);
add_nc(ncname,spd,dot) ;

% GPS grab processing
% 1. Pre-process the grabs to get the pseudo-ranges. This can take a day or more
%    depending on the number of grabs and the speed of your computer.
d3preprocgps(recdir,depid) ;

% 2. Gather the results from the pre-processing into an OBS structure.
OBS = d3combineobs(recdir,depid) ;

% 3. Get estimates of the start position of the tag and its clock offset with respect
%    to GPS time. If you have good estimates for these already, proceed to step 4. 
%	  Most likely you know the rough start position (e.g., within 0.5 degree) but are
%	  not sure about the clock offset. In which case, do this:
[tc,rerr] = gps_timesearch(OBS,[lat,long],[-30 30],200) ;
% In this line, [-30 30] defines the clock offset time range to search, i.e., -30 to 30 
% seconds with respect to true time. This is plenty for normal clock offsets that come
% about from 
% tc is an estimate of the time offset between the tag clock and GPS time, in seconds.
% rerr is an estimate of the location error (in metres) that will result in the first
% GPS location if you use this clock offset. If rerr is less than a few hundred
% metres, give tc a try in step 4 below. If rerr is high, then either your starting
% position estimate is not good or you need to allow a larger/different time offset
% search. Either way, one of the following steps might be needed.

% If you don't know within +/- 2 degrees what the start position is, do the following:
check_sv_elevation(OBS,latr,longr,tc,THR) ;
% If you know the starting point within +/- 2 degrees (e.g., as a result of
% running check_sv_elevations, run the following:
find_start_point(OBS,latr,longr,tc,THR) ;
% This will tell you a likely starting point for the GPS track.
% Now you can try to get the time offset using gps_timesearch as above.

% 4. Run the GPS processor to compute the track. This can take several hours
%    if there were a lot of grabs.
[POS,N,gps] = gps_posns(OBS,[lat,long],tc,THR);

% 5. Save the result. First save all of the outputs in a .mat file.
save([depid 'trk.mat'],'POS','N','gps')
% Then generate a nc file for the GPS tracking data

gpst = etime(datevec(POS.T),repmat(get_start_time(info),size(POS.T,1),1)) ;
POS=sens_struct([POS.lat POS.lon],POS.T,depid,'pos');
save_nc([depid 'trk'],info,POS)	% info was defined at line 21 above
