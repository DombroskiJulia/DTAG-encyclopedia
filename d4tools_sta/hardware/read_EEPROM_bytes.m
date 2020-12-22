function [out_bytes,varargout] = read_EEPROM_bytes(varargin)
global porta_ser
verbose = 0;
CR = char(13);
for i = 1:nargin
    switch varargin{i}
        case 'verbose'
            verbose = 1;
    end
end
fprintf(porta_ser,[CR,CR,CR])
% read EEPROM
fprintf('Read EEPROM:\n')
fprintf(porta_ser,['s-14',CR])
pause(0.01);fprintf(porta_ser,['1',CR])
fprintf(porta_ser,['2',CR,'p',CR])
pause(0.1);fprintf(porta_ser,['s-15',CR,'g-47',CR,'p',CR])
z = ''; count = 0;
while isempty(findstr(z,',')) & count < 50
    z = fgetl(porta_ser);
    count = count +1;
end
out_text = z(6:end);
tmp = regexp(out_text,'([^ ,:]*)','tokens');
out_cell = cat(2,tmp{:});
out_dec = hex2dec(out_cell);
if verbose & length(out_text)>1
    fprintf('Bytes_read:%s\n',out_text);
    tmp = out_dec(1); fprintf('TWIC_EE_POT0:[0x%X] %d\n',tmp,tmp);
    tmp = out_dec(2); fprintf('TWIC_EE_POT1:[0x%X] %d\n',tmp,tmp);
    tmp = out_dec(3); 
    if bitget(tmp,1) t='10 bit'; else t='7 bit'; end
    if bitget(tmp,2) t=[t,' I2C']; else t=[t,' SMBUS']; end
    fprintf('TWIC_EE_I2C_STYLE:[0x%X] %d (%s)\n',tmp,tmp,t);
    tmp = out_dec(4); fprintf('TWIC_EE_I2C_ADDRESS:[0x%X] %d\n',tmp,tmp);
    tmp = out_dec(21); fprintf('TWIC_VCO_LOW:[0x%X] %d (%1.2fV)\n',tmp,tmp,tmp.*0.008);
    tmp = out_dec(22); fprintf('TWIC_VCO_HIGH:[0x%X] %d (%1.2fV)\n',tmp,tmp,tmp.*0.008);    
    tmp = out_dec(23); fprintf('TWIC_EE_OSC_WARM:[0x%X] %d (%dms)\n',tmp,tmp,tmp*10);
    tmp = out_dec(24); fprintf('TWIC_EE_T2_COUNT:[0x%X] %d \n',tmp,tmp);
    tmp = out_dec(25); fprintf('TWIC_EE_T2_LOOP:[0x%X] %d \n',tmp,tmp);
    
    tmp = out_dec(26); fprintf('TWIC_EE_HARDWARE:[0x%X] %d \n',tmp,tmp);
    tmp = out_dec(27); fprintf('TWIC_EE_SERIAL_NUMBER:[0x%X] %d \n',tmp,tmp);
    tmp = out_dec(28); fprintf('TWIC_EE_SOFTWARE_MAJOR:[0x%X] %d \n',tmp,tmp);
    tmp = out_dec(29); fprintf('TWIC_EE_SOFTWARE_MINOR:[0x%X] %d \n',tmp,tmp);
    tmp = out_dec(30); fprintf('TWIC_EE_SOFTWARE_MINOR_MINOR:[0x%X] %d \n',tmp,tmp);
    
    tmp =  [out_cell{40:43}]; fprintf('TWIC_EE_TX_TOTAL:[0x%s] %d \n',tmp,hex2dec(tmp));
    tmp =  [out_cell{44:45}]; fprintf('TWIC_EE_TX_NO_TRANSMIT:[0x%s] %d \n',tmp,hex2dec(tmp));
    
    tmp = out_dec(46); fprintf('TWIC_EE_COLD_BATTERY_TEMPERATURE:[0x%X] %d \n',tmp,tmp);
    tmp = out_dec(47); fprintf('TWIC_EE_DEPASSIVIZATION_VOLTAGE:[0x%X] %d (%1.2fV)\n',tmp,tmp,(tmp*0.016));
    tmp = out_dec(48); fprintf('TWIC_EE_LOW_TEMP_VOLTAGE:[0x%X] %d (%1.2fV)\n',tmp,tmp,(tmp*0.016));
end