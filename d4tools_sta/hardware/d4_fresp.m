function    [R,FF,XD,XF] = d4_fresp(fname,T)
%
%     [R,FF,XD,XF] = d4_fresp(fname,T)
%     Plots the distortion and frequency response of a D4 tag
%     from a test signal recordings.
%     fname is the filename containing the test signal recording.
%     T is the start time in the recording to start looking
%      for a test signal.
%
%     Procedure:
%     Connect the signal generator to HPH+ and AGND via
%     a 4.7nF capacitor.
%     Use a 50 Ohm shunt on the signal generator or set it to Hi-Z load in
%     UTIL menu.
%     Signal generator plays ARB waveform (d4test.csv)
%     at 1000 kHz (rate).
%     For LOW GAIN use amplitude = 300 mVpp
%     For HIGH GAIN use amplitude = 75 mVpp
%     Make sure to record for a few seconds longer than
%     the 10s MUTE interval (e.g., 4 flashes of the orange led).
%
%     Example:
%     d4_fresp(ldf,12);
%
%     markjohnson@st-andrews.ac.uk
%     March 2016

if isempty(fname), return, end

if any(fname=='.'),
   fname = fname(1:find(fname=='.',1)) ;
end

if nargin<2 || isempty(T) || T==0,
   T = 11 ;           % Start just after mute ends if no time is given
end

% read xml file
dd = readd3xml([fname '.xml']) ;

% look for audio gain
G = getaudiogain(dd)>0 ;

% look for device id
[id,fullid] = getxmldevid(dd) ;

% get sampling frequency to deduce the band
[s,afs] = wavread([fname '.wav'],'size') ;
BAND = afs>192e3 ;

if G==0,
   VIN = 0.3/2 ;    % Vpp input for 300mVpp amplitude setting
                    % Tones for fresp testing are 0.5x full scale
   MG = 20.1 ;      % 10kHz gain in dB
else
   VIN = 0.075/2 ;  % Vpp input for 75mVpp amplitude setting
                    % Tones for fresp testing are 0.5x full scale
   MG = 33.1 ;      % 10kHz gain in dB
end

if BAND==0,
   f = logspace(3,log10(200e3),20)' ;
   h = biquad_resp([70e3 70e3 100e3],[1.2 0.6 0],f);
   FT = [100 -1.8;500 -0.1;[f h]] ;   % MF response
   %FT = [100 -1.8;500 -0.1;1e3 0;10e3 0;30e3 -0.1;64e3 -3;100e3 -15] ;   % MF response
else
   f = logspace(3,log10(200e3),20)' ;
   h = biquad_resp([180e3 180e3 256e3],[1.2 0.6 0],f);
   FT = [100 -2.9;500 -0.1;[f h]] ;   % HF response
end

GAINS = {'LOW','HIGH'} ;
BANDS = {'MF','HF'} ;
fprintf('Tag id %x, fs %d Hz, gain %s, band %s\n',id,round(afs),GAINS{G+1},BANDS{BAND+1}) ;

X = wavread([fname '.wav'],round(afs*(T+[0 4]))) ;
load d4_audio_test_sig
ZOH_corr = 20*log10(sinc(TF(:,3)/fs)) ;

% find the start of the test signal
ks = find(X>0.95,1) ;
if isempty(ks),
   fprintf(' Unable to find start pulse in the recording: check wiring\n') ;
   R = X ;
   return
end

% trim X to just the distortion test signal
XD = X(ks+(0:round(TA(end,2)*afs)+1000)) ;
FD = 10e3 ;
FF = [] ;
lmin = round(afs*min(TA(:,2)-TA(:,1)-0.008)) ;
nf = round(60e3*lmin/afs) ;
FF = zeros(nf,size(TA,1)) ;
for k=1:size(TA,1),
   %ed = TA(k,2)-0.003 ;
   st = TA(k,1)+0.005 ;
   % adjust st to include an integer number of cycles
   %ncyc = floor((ed-st)*FD) ;
   %st = ed-ncyc/FD ;
   xx = XD(round(st*afs)+(1:lmin)) ;
   ff = fft(xx.*hamming(length(xx))) ;
	FF(:,k) = 20*log10(abs(ff(1:nf))) ;
end

figure(1),clf
subplot(211)
plot((0:length(FF)-1)'*afs/length(xx)/1000,FF),grid
axis([0 35 -60 60])
xlabel('Freq (kHz)')
ylabel('Level (dB)')

% trim X to just the frequency response test signal
XF = X(ks+(0:round(TF(end,2)*afs)+1000)) ;
L = zeros(size(TF,1),4) ;
for k=1:size(TF,1),
   ed = TF(k,2)-0.003 ;
   st = TF(k,1)+0.005 ;
   % adjust st to include an integer number of cycles
   ncyc = floor((ed-st)*TF(k,3)) ;
   st = ed-ncyc/TF(k,3) ;
   xx = XF(round(st*afs):round(ed*afs)) ;
%plot(xx),grid
%title(sprintf('%f',TF(k,3)/1000))
%pause
   L(k,:) = [TF(k,3) std(xx) max(xx)-min(xx) mean(xx)] ;
end

R = [L(:,1) 20*log10(L(:,2))-20*log10(VIN/2/sqrt(2))-ZOH_corr] ;
subplot(212)
semilogx(R(:,1),R(:,2),'.-'),grid
hold on
semilogx(FT(:,1),FT(:,2)+MG,'r.') ;
semilogx(ones(3,1)*FT(:,1)',[-1:1]'*ones(1,size(FT,1))+ones(3,1)*FT(:,2)'+MG,'r-') ;

% estimate clipping level at 10 kHz
k = nearest(R(:,1),10e3);
fprintf('Clipping level at 10kHz is %1.3f Vpp\n',2*10^(-R(k,2)/20)) ;
fi = (10e3:1e3:max(R(:,1)))' ;
Gi = interp1(R(:,1),R(:,2),fi) ;
fprintf('Approx. upper -3dB frequency is %3.1f kHz\n',fi(find(Gi>Gi(1)-3,1,'last'),1)/1000) ;


repname = sprintf('audio_%x_%s',id,GAINS{G+1}) ;
testtime = datestr(now) ;
save(repname,'XD','XF','R','FF','afs','TA','TF','fname','testtime')
