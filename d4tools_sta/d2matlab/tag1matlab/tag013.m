function    CAL = tag013(date)
%
%     CAL = tag013([date])
%     Calibration file for tag013
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: June 2007

CAL.TAG = 13 ;

CAL.TREF = 20 ;                             % temperature of calibration
CAL.TCAL = [-0.0158 60.0] ;                 % temperature sensor calibration
% converted from GOMCAL.m calibration numbers using:
% p_cal = [420 1.7044 0] ; CAL.PCAL = [0,1/p_cal(2),-p_cal(1)/p_cal(2)]
CAL.PCAL = [0,0.5867,-246.421] ;
CAL.PTC = 0 ;
CAL.Pi0 = [] ;                              % pressure bridge current
CAL.Pr0 = [] ;                              % current sensing resistor

% converted from GOMCAL.m a_cal calibration numbers using:
% CAL.ACAL = [1./a_cal(:,2),-a_cal(:,1)./a_cal(:,2)]
CAL.ACAL = [0.001593 -2.94 ;
            0.001615 -3.14 ;
      	   0.001395 -2.69 ] ;

% converted from GOMCAL.m m_cal calibration numbers using:
% CAL.MCAL = [1./m_cal(:,2),-m_cal(:,1)./m_cal(:,2)]
CAL.MCAL = [0.0963 -175.0096 ;
            0.0995 -208.3483 ;
            0.0894 -201.5564] ;

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

CAL.VB = [] ;              % battery voltage conversion to volts
CAL.PB = [] ;              % pb conversion to volts
CAL.PBTREF = [] ;          % pb value in volts at TREF
CAL.MB = [] ;              % mb conversion to volts
CAL.MBTREF = [] ;          % mb value in volts at TREF
