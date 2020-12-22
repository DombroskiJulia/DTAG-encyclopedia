function    CAL = tag202(date)
%
%     CAL = tag202([date])
%     Calibration file for tag202
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     Based on Tag2_Stats.xls
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: May 2007

CAL.TAG = 202 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [0,1316.9,1207.8] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [-7.1 1.97 ;
            6.98 -1.420 ;
      	   -6.694 1.499 ] ;     % no Az cal available - possible bad channel

CAL.MCAL = [-103.57	-3.67	;
            97.57	18.55 ;
            -100.38	8.45 ] ;

CAL.APC = [0 0 0] ;                 % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                 % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                  % cross-axis sensitivity on A
           0 1 0 ;
           0 0 1] ;

CAL.MMBC = [0 0 0] ;          % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 0 0 ;           % cross-axis sensitivity on M
           0 1 0 ;
           0 0 1] ;

CAL.VB = [5 5] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF = 3.36 ;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF = 2.82 ;        % mb value in volts at TREF
