function    CAL = tag224(date)
%
%     CAL = tag224([date])
%     Calibration file for tag224
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006
%
%  4/1/09 - replaced pressure transducer with a 3000psi and recalibrated
%  SF, TH
% 6/19/09 recalibration by Jeremy and Steve

CAL.TAG = 224 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

% CAL.PCAL = [0.4048 132.8733 119.5006] ;   original (manatee) 300 psi xdcr cal
%CAL.PCAL = [-25.73 1343.74 1304.94];        % 4/1/09 3000psi xdcr cal 
CAL.PCAL = [-31.3836 1342.5791 1300.8932];  %6/19/09 calibration

CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

%CAL.ACAL = [4.0032 -1.127
%            -3.9507 1.0368
%            4.0285 -1.0491] ;
CAL.ACAL = [3.9944 -1.1126          %6/19/09 calibration
            -3.918 1.0479
            4.0259 -1.0452] ;

%CAL.MCAL = [-106.3636 6.6095
%            -107.2929 -3.2269
%            106.4208 25.2189] ;
CAL.MCAL = [-109.8482 13.07632      %6/19/09 calibration
            -112.6279 -5.376254
            110.7405 25.35759] ;

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
CAL.PBTREF =  2.948;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.29;        % mb value in volts at TREF

