function    CAL = tag233(date)
%
%     CAL = tag2XX([date])
%     Calibration file for tag2XX
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006
%     Calibration file created 6/11/09 JW Press, Accel, Mag.

CAL.TAG = 233 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [16.8 1349.3 1180.7] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [4.1295 -1.0774	
            -3.944 1.0908
            3.919 -1.1652] ;
%6/8/09 cal: mean = 1.0008; std = 0.074655
        
CAL.MCAL = [-86.8565 -17.2594
            -90.052	7.12876
            89.2191	-21.3347] ;
%6/8/09 cal: meancheck = 51.3786; StanDev = 5.0184
        
CAL.APC = [0 0 0] ;  % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                    % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                     % cross-axis sensitivity on A
           0 1 0 ;
           0 0 1] ;

CAL.MMBC = [0 0 0] ;             % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 0 0 ;           % cross-axis sensitivity on M
           0 1 0 ;
           0 0 1] ;

CAL.VB = [5 5] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF =  3.29;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.82;        % mb value in volts at TREF
