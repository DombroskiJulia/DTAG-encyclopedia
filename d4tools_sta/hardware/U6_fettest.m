% -------------------------------------------------
% Simple Analog In
% This file calls the eGet function and returns the
% analog voltage from AIN0 on the U6. It also checks for 
% errors for each request. If an Error is detected the error
% code is displayed rather than the AIN0 voltage value.
% Error = 0 means no errors.
% -------------------------------------------------

clear global %Clears MATLAB global variables

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU6,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error) % Check for and display any Errors

% Set Device Resolution to 17. Greater than 16 equals max resolution
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_CONFIG,LJ_chAIN_RESOLUTION,17,0,0);
Error_Message(Error)

% Set Device Voltage Range to Bipolar 0-5 volts.
Error = ljud_AddRequest(ljHandle,LJ_ioPUT_AIN_RANGE,0,LJ_rgBIP5V,0,0);
Error_Message(Error)

V = (0:0.005:1)' ;
A = NaN*zeros(size(V,1),2) ;
for k=1:length(V),
   Error = ljud_ePut(ljHandle,LJ_ioPUT_DAC,0,V(k),0) ;
   Error = ljud_ePut(ljHandle,LJ_ioPUT_DAC,1,V(k)+3.3,0) ;
   [Error A(k,1)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,0,0,0) ;
   [Error A(k,2)] = ljud_eGet(ljHandle,LJ_ioGET_AIN,1,0,0) ;
   if Error>0,
      break
   end
end
   
Error_Message(Error)
R=[-A(:,1),A(:,2)-A(:,1)];
figure(1),clf
subplot(311)
plot(R(:,1),R(:,2)),grid
gR=diff(R(:,2))./diff(R(:,1));
subplot(312)
plot(R(1:end-1,1),-gR),grid
i = (3.3-R(1:end-1,2))/3.6 ;
subplot(313)
plot(i,-gR),grid

