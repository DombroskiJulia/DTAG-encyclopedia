function    [x,fs,TF,TA]=d4_audio_test_signal
%
%     [x,fs,TF,TA]=d4_audio_test_signal
%

FL = 100 ;
FM = [3e3 20e3] ;
FU = 200e3 ;
NS = 26 ;
TMAX = 0.08 ;
TMIN = 0.012 ;
NCYC = 20 ;
G = 0.01 ;
FDIST = 10e3 ;
ADIST = [1;0.5;0.25;0.125] ;
TGAP = 0.05 ;
A = 0.5 ;
fs = 1000e3 ;     % use high sampling rate to minimize ZOH attenuation

F = [100 200 300 500 700 1e3 2e3 4e3 7e3 10e3 14e3 20e3 30e3:10e3:200e3]' ;
%F = logspace(log10(FL),log10(FU),NS)' ;
g = zeros(round(fs*G),1) ;
x = [] ;
TA = [] ;
dur = max(TMIN,min(TMAX,NCYC/FDIST)) ;
ns = round(fs*dur) ;
s = sin(2*pi*FDIST/fs*(1:ns)') ;
for k=1:length(ADIST),
   TA(end+1,:) = [(length(x)+[0 length(s)])/fs ADIST(k)] ;
   x = [x;s*ADIST(k);g] ;
end
x = [x;zeros(round(fs*TGAP),1)] ;
TF = [] ;
for k=1:length(F),
   dur = max(TMIN,min(TMAX,NCYC/F(k))) ;
   ns = round(fs*dur) ;
   s = A*sin(2*pi*F(k)/fs*(1:ns)') ;
   TF(end+1,:) = [(length(x)+[0 length(s)])/fs F(k)] ;
   x = [x;s;g] ;
end

fprintf('Signal length is %d samples. Max length is 1048574\n',length(x)) ;
x = afg3051_siggen(x,fs,'d4test.csv') ;
save d4_audio_test_sig x fs TF TA
