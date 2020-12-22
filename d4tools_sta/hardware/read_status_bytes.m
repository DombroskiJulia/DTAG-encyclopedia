function [out_bytes,varargout] = read_status_bytes(varargin)
global porta_ser
verbose = 0;
CR = char(13);
n = 45;
for i = 1:nargin
    switch varargin{i}
        case 'verbose'
            verbose = 1;
    end
end
fprintf(porta_ser,[CR,CR,CR])
pause(1)
% wake up board
fprintf(porta_ser,['s-15',CR,'g',CR,'p',CR,CR,CR])

% read status bytes
if verbose; fprintf('Reading status...\n'); end
fprintf(porta_ser,['s-15',CR,'g-',num2str(n),CR,'p',CR])
y = ''; count = 0;
while isempty(findstr(y,',')) & count < 20
    y = fgetl(porta_ser);
    count = count +1;
end
out_bytes = y(6:end);
    tmp = regexp(out_bytes,'([^ ,:]*)','tokens');
    out_cell = cat(2,tmp{:});
    out_dec = hex2dec(out_cell);
    
if nargout > 1
    varargout{1} =out_cell;
end

if nargout > 2
    varargout{2} = out_dec;
end

if verbose & length(out_dec)>14
    fprintf('Bytes_read:%s\n',out_bytes);
    n_tx = sum(out_dec(1:4)'.*(2.^[0,8,16,24])); fprintf('Transmitt count: %d\n',n_tx);
    bat_V = out_dec(5).*0.016;  fprintf('Battery voltage during last transmission: %1.2fV\n',bat_V);
    bat_I = out_dec(6).*4;  fprintf('Battery current during last transmission: %dmA\n',bat_I);
    reflct_V = out_dec(7).*0.008;  fprintf('Reflection voltage: %1.2fV\n',reflct_V);
    osc_V = out_dec(8).*0.008;  fprintf('Oscilattor voltage: %1.2fV\n',osc_V);
    sw_M = out_dec(9); sw_m = out_dec(10); sw_l = out_dec(11); fprintf('Software version: %d.%d%c\n',sw_M,sw_m,sw_l);
    hw_V = out_dec(12);fprintf('TWIC hardware version: %d.%d\n',round(hw_V/16),bitand(hw_V,15));
    sizeTx = out_dec(13);fprintf('Last message size: %d bytes\n',sizeTx);
    lastMsg = [out_cell{14:13+sizeTx}];fprintf('Last message: %s\n',lastMsg); 
end