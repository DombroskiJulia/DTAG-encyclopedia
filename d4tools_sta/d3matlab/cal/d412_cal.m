DEV = struct ;
DEV.ID='5D031932';
DEV.NAME='D412';
DEV.BUILT=[2014 9 12];
DEV.BUILDER='mj';
DEV.VHF = 218.8435 ;
DEV.HAS={'stereo audio','hf','ecg high rate'};
BBFILE = ['badblocks_' DEV.ID(1:4) '_' DEV.ID(5:8) '.txt'] ;
try,
   DEV.BADBLOCKS = readbadblocks(['/tag/projects/d3/private/badblocks/' BBFILE]) ;
catch,
   fprintf(' No bad block file\n') ;
end

TEMPR = struct ;
TEMPR.TYPE='ntc thermistor';
TEMPR.USE='conv_ntc';
TEMPR.UNIT='degrees Celcius';
TEMPR.METHOD='none';

BATT = struct ;
BATT.POLY=[6 0] ;
BATT.UNIT='Volt';

PRESS=struct;
PRESS.POLY=[3124 -121];
PRESS.METHOD='rough';
PRESS.LASTCAL=[];
PRESS.TREF = 20 ;
PRESS.UNIT='meters H20 salt';
PRESS.TC.POLY=[0];
PRESS.TC.SRC='BRIDGE';
PRESS.BRIDGE.NEG.POLY=[3 0];
PRESS.BRIDGE.NEG.UNIT='Volt';
PRESS.BRIDGE.POS.POLY=[6 0];
PRESS.BRIDGE.POS.UNIT='Volt';
PRESS.BRIDGE.RSENSE=200;
PRESS.BRIDGE.TEMPR.POLY=[314.0 -634.7] ;
PRESS.BRIDGE.TEMPR.UNIT='degrees Celcius';

ACC=struct;
ACC.TYPE='MEMS accelerometer';
ACC.POLY=[5.24 -2.64;4.93 -2.50;4.85 -2.40] ;
ACC.UNIT='g';
ACC.TREF = 20 ;
ACC.TC.POLY=[0;0;0];
ACC.TC.SRC='TEMPR';
ACC.PC.POLY=[0;0;0];
ACC.PC.SRC='PRESS';
ACC.XC=zeros(3);
ACC.MAP=[-1 0 0;0 1 0;0 0 1];
ACC.MAPRULE='front-right-up';
ACC.METHOD='flips';
ACC.LASTCAL=[2014 9 16];

MAG=struct;
MAG.TYPE='magnetoresistive bridge';
MAG.POLY=[788 44.9;788 107.2;788 35.5] ;
MAG.UNIT='microTesla';
MAG.TREF = 20 ;
MAG.TC.POLY=[0;0;0];
MAG.TC.SRC='BRIDGE';
MAG.PC.POLY=[0;0;0];
MAG.PC.SRC='PRESS';
MAG.XC=zeros(3);
MAG.MAP=[0 1 0;1 0 0;0 0 1];
MAG.MAPRULE='front-right-up';
MAG.METHOD='no cal';
MAG.LASTCAL=[0 0 0];
MAG.BRIDGE.NEG.POLY=[3 0];
MAG.BRIDGE.NEG.UNIT='Volt';
MAG.BRIDGE.POS.POLY=[6 0];
MAG.BRIDGE.POS.UNIT='Volt';
MAG.BRIDGE.RSENSE=20;
MAG.BRIDGE.TEMPR.POLY=[541.91 -459.24] ;
MAG.BRIDGE.TEMPR.UNIT='degrees Celcius';

ECG1.GAIN = 39.4 ;
ECG1.FREQ3dB = [1.5 1500] ;

CAL=struct ;
CAL.TEMPR=TEMPR;
CAL.BATT=BATT;
CAL.PRESS=PRESS;
CAL.ACC=ACC;
CAL.MAG=MAG;
CAL.ECG1=ECG1 ;

DEV.CAL = CAL ;
writematxml(DEV,'DEV','/tag/tag3/hardware/d412.xml')

