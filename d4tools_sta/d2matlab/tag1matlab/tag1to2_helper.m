% Converting tag1 sensor data to high-rate PRH files
cd C:\tag\tag2\tagtools\tag1\matlab
[s,tagon] = readsen3('F:\pw03\pw03_074a\pw074a',1,4,1024);
% 
[n,fsa] = wavread16('F:\pw03\pw03_074a\pw074a04.wav','size');
fss = fsa/680 ;   % raw audio sampling rate

s=decdc(s,4);  % Use 4 for 64kHz data. Use 3 for 48kHz. Use 2 for 32kHz
fs = 16000/680 ;  % decimated sensor data rate
saveraw('pw03_074a',s,fs)

s=tag1to2(s);

tagon
savecal('pw03_074a','CUETAB',[])
% copy tagon when TAGON time is requested
      % pw03_074a used tag #11, 64kHz sampling
      % pw03_076a used tag #11, 64kHz sampling
      % pw03_076b used tag #13, 64kHz sampling
      % pw03_077a used tag #11, 32kHz sampling
      % pw03_077b used tag #13, 32kHz sampling
      % pw03_078a used tag #11, 32kHz sampling
      % pw03_078b used tag #13, 64kHz sampling
      % pw03_082a used tag #11, 32kHz sampling
      % pw03_082b used tag #13, 48kHz sampling
      % pw03_082c used tag #13, 48kHz sampling
      % pw03_082d used tag #11, 32kHz sampling
      % pw03_082e used tag #13, 48kHz sampling
% use normal tag2 toolpath to calibrate file from here on
