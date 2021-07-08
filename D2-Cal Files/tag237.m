function    CAL = tag237(date)
%
%     CAL = tag237([date])
%     Calibration file for tag237
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006
%     Modified: 12 April 2011; by Michele from Feb 2010 calibration


CAL.TAG = 237 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

%CAL.PCAL = [9.93 1322.94 1140.17] ;
CAL.PCAL = [-12.214 1298.3 1157.9201] ;  
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

%CAL.ACAL = [4.02  -0.95
 %           -3.92 1.13
  %          4    -1.06] ;
CAL.ACAL = [4.0128 -1.0688
            -4.0053 1.0841
            4.1448 -1.1252] ;

%CAL.MCAL = [-89.44  -3.32
 %           -89.53  5.18
  %          91.59   -2.27] ;
CAL.MCAL = [-82.642 1.28921
            -83.9081 6.48889
            85.601 -2.36259];

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

