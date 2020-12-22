function [out_bytes,varargout] = write_EEPROM_bytes(addr,bytes)
global porta_ser
verbose = 0;
CR = char(13);
fprintf(porta_ser,[CR,CR,CR])
% wake up board
fprintf(porta_ser,['s-15',CR,'g',CR,'p',CR,CR,CR])
% read EEPROM
fprintf('Write EEPROM:\n')
cmd = [dec2hex(length(bytes)+2,2),CR,'03',CR,dec2hex(addr,2),CR];
for i = 1:length(bytes)
    cmd = [cmd,dec2hex(bytes(i),2),CR];
end
cmd = [cmd,CR];
fprintf(porta_ser,['s-14',CR]);
fprintf(porta_ser,[lower(cmd),'p',CR]);



