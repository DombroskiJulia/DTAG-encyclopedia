clc; close all; clear all
a = instrfind; temp = find(~cellfun('isempty',strfind(get(a,'Status'),'open')));
if ~isempty(temp) fclose(a(temp)); end
global porta_ser
porta_ser = serial('com6');
porta_ser.BaudRate = 9600;
porta_ser.DataBits = 8;
porta_ser.Parity = 'none';
porta_ser.StopBits = 1;
porta_ser.FlowControl = 'none';
porta_ser.Terminator ='CR';
porta_ser.ReadAsyncMode='continuous';
fopen(porta_ser);
CR = char(13);

% reset BV4221
porta_ser.DataTerminalReady = 'off'; porta_ser.DataTerminalReady = 'on'; pause(1)
% send 2x CR
idn = query(porta_ser,''); pause(1);
idn = query(porta_ser,''); pause(1);
% set mode to I2C
idn = query(porta_ser,'I');
pause(.1)
% set I2C address to 0x14
idn = query(porta_ser,'A14');
for i = 1:2
    idn = query(porta_ser,''); pause(.1);
end
idn = query(porta_ser,'t100000');
idn = query(porta_ser,'H');
% reset transmission count
write_EEPROM_bytes(hex2dec('27'),[0,0,0,0,0,0])
pause(10);
% make 10 transmissions
for i = 1:10
    send_test_packet;
    pause(10)
end
read_EEPROM_bytes('verbose');
[out_str,out_cell,out_dec] = read_status_bytes('verbose');

fclose(porta_ser); delete(porta_ser);


