function [out_bytes,varargout] = send_test_packet
global porta_ser
verbose = 1;
CR = char(13);
preamble = 'FFFE2F';
msglen = '6';
PTTcode = '986E5D4';
%payload = '0123456789ABCD';
temp = double('Dtag3 TWIC test');
payload = [];
for u = 1:length(temp);
    payload = [payload,dec2hex(temp(u),2)];
end
temperature = 18;

% send 2x CR
fprintf(porta_ser,[CR,CR,CR])


% build message from parts
msg = [preamble,msglen,PTTcode,payload];
if verbose fprintf('Message to be sent is: %s %s %s %s %s\n',preamble,msglen,PTTcode,payload); end
temp_byte = round((2.5.*temperature) + 100);
% send message length
msglen = 2+(length(msg)/2);

cmd = [dec2hex(msglen,2),'01',dec2hex(temp_byte),msg];
cmd_script = [];
for i = 1:2:length(cmd)
    cmd_script = [cmd_script,cmd(i:i+1),CR];
end
cmd_script = [cmd_script,'p',CR,CR,CR];
% wake up board
fprintf(porta_ser,['s-15',CR,'g',CR,'p',CR,CR,CR])
% send message
fprintf(porta_ser,['s-14',CR])
pause(0.001);fprintf(porta_ser,lower(cmd_script))
fprintf(porta_ser,repmat(CR,[1,10]));

