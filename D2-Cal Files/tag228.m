function    CAL = tag228(date)
%
%     CAL = tag228([date])
%     Calibration file for tag228
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006

%Last calibration:
%7/28/07, thurst 	(press only)
%3/17/08, thurst 	press, accel & mag
%6/25/08, thurst	corrected accel and mag signs

CAL.TAG = 228 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

%CAL.PCAL = [12.46 1332.2 1190.7] ;
%3/17/08 cal results:
CAL.PCAL = [7.75 1340.87 1195.61] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [4.0925 -1.1301
            -4.0068 1.1541
            4.0298 -1.0146];
%3/17/08 cal: meancheck = 1.0001; StanDev = 0.0136

CAL.MCAL = [-83.6232  21.4161
            -85.7423 -19.3577
            85.5521  -11.3534];
%3/17/08 cal: meancheck = 50.8960; StanDev = 1.3942

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

