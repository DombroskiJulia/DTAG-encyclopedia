function    CAL = tag229(date)
%
%     CAL = tag229([date])
%     Calibration file for tag229
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006

%Last calibration:
%7/28/07, thurst (pressure only)
%3/17/08, thurst pressure, accel & mag
%6/25/08, thurst	corrected accel and mag signs

CAL.TAG = 229 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

%CAL.PCAL = [-13.23 1332.3 1224.5] ;
%3/17/08 pressure cal:
CAL.PCAL = [-8.55 1340.48 1227.26] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [4.0108 -1.1142
            -3.9399 1.0313
            3.9379 -1.0771];
%3/17/08 cal: meancheck = 0.9885; StanDev = 0.0175

CAL.MCAL = [-72.9995 -0.6091
            -83.8938  1.2196
            90.7922 6.4513];
%3/17/08 cal: meancheck = 49.6742; StanDev = 3.1635

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

