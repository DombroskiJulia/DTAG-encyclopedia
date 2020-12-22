dos('C:\tag\projects\low_noise_preamp\datax\ContAdc\contad32.exe 1000000 temp');
fp = fopen('temp.bin') ;
x = fread(fp,Inf,'ushort') ;
fclose(fp) ;
eval('temp') ;
x = ((MAX-MIN)/GAIN/2^NB)*x + MIN/GAIN ;
plot(x),grid

