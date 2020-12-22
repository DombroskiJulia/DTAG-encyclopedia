function       U6_logger(fname,dt)
%
%       U6_logger(fname,dt)
%

ljud_LoadDriver; % Loads LabJack UD Function Library
ljud_Constants; % Loads LabJack UD constant file
[Error ljHandle] = ljud_OpenLabJack(LJ_dtU6,LJ_ctUSB,'1',1); % Returns ljHandle for open LabJack
Error_Message(Error) % Check for and display any Errors

% Pre-initalize arrays
f = fopen(fname,'wt') ;
k = 0 ;

while(k<60) % For loop for time/dt iterations
    % Call eGet function to get AIN value
    [err x] = ljud_eGet(ljHandle,LJ_ioGET_AIN,0,0,0); 
    Error_Message(err)
    fprintf(f,'%f,%f',k,x) ;
    fprintf('%f,%f',k,x) ;
    pause (dt) %pause dt before next iteration   
    k = k+dt ;
end
fclose(f) ;
