function    [S,fc,CI] = thirdoctlevs(x,fs,T,fmin,fkey)
%    [S,fc,CI] = thirdoctlevs(x,fs,T,fmin,fkey)
%     Compute third octave levels (TOLs) of signal x sampled at fs Hz
%     using multi-rate processing.
%     The third octaves to compute are chosen automatically based on the
%     sampling rate and the key frequency (1kHz by default). The highest 
%     third octave will have a center frequency given by fc = fkey*2^(n/3)
%     where n is the highest integer, n, for which fc <= fs/3.
%
%     T specifies the averaging time in seconds. x is divided into non-overlapping
%        blocks of length fs*T samples and the TOLs are reported for each block.
%        If T is omitted or empty, the full vector x will be averaged.
%     fmin specifies the lowest third octave frequency to analyse. Default
%        is 25 Hz. If the averaging time is too short for the specified fmin,
%        a higher frequency will be automatically chosen.
%     fkey specifies the center frequency of the key third octave from
%        which the others are calculated. For ANSI and IEC standards it is
%        1kHz which is the default value.
%
%     Return:
%     S is the TOLs in dB re 1.0 for each T second averaging interval.
%        The first row of S is the TOLs for the first averaging interval etc.
%     fc is the center frequency of each third octave in Hz.
%     CI is the lower and upper confidence intervals in dB for each third
%        octave assuming a Gaussian input. The confidence limit is 90%.
%
%     Scaling:
%     The TOLs are scaled so that, if all the signal energy in x is within
%     the frequency range analysed, then sum(10.^(S/10)) == mean(x.^2), assuming a
%     single averaging block. There will be small differences due to the
%     startup condition of the filter but the results should be close.
%
%     Example:
%        x=randn(10000,1);                   % white noise
%        [S,fc,CI] = thirdoctlevs(x,96e3);   % TOL analysis on x
%        % the TOLs should increase by 3dB per octave.
%
%        x=sin(2*pi*1000/96e3*(1:10000)');   % a 1kHz sinewave
%        [S,fc,CI] = thirdoctlevs(x,96e3);   % TOL analysis on x
%        [mean(x.^2) sum(10.^(S/10))]        % compare powers - should both be 0.5
%        
%     markjohnson@st-andrews.ac.uk
%     Based on the octave toolbox by Christophe Couvreur
%     The function oct3dsgn by Christophe Couvreur is included in this
%     function.
%     Last modified: 3 May 2014

S = [] ; fc = [] ; CI = [] ;

if nargin<2,
   help thirdoctlevs
   return
end

% check the arguments and use defaults if needed
if nargin<3 | isempty(T),
   T = length(x)/fs ;
end

if nargin<4 | isempty(fmin),
   fmin = 25 ;
end

if nargin<5 | isempty(fkey),
   fkey = 1000 ;
end

ord = 3 ;                                 % third octave filter order
ndec = 24 ;                               % length of decimating FIR filter
za = 1.6 ;                                % multiplier on sigma for a 90% confidence interval
nta = floor(log(fs/3/fkey)/log(2)*3) ;    % number of third octaves above key frequency
ntb = floor(-log(fmin/fkey)/log(2)*3) ;   % number of third octaves below key frequency
fc = fkey*2.^((nta:-1:-ntb)'/3) ;         % center frequencies of the third octaves to analyse, high to low

% just design a filter for the top three third octaves
B = zeros(3,2*ord+1) ;
A = zeros(3,2*ord+1) ;
for k=1:3,
   [B(k,:),A(k,:)] = oct3dsgn(fc(k),fs,ord);
end

nocts = ceil(length(fc)/3) ;              % number of octaves
nave = round(T*fs) ;                      % number of samples to average in the top octave
S = zeros(floor(length(x)/nave),length(fc)) ;   % make space for the results
CI = zeros(length(fc),1) ;

for k=1:length(fc),              % do for each third octave
   ton = rem(k-1,3)+1 ;                   % find out which filter to use
   y = filter(B(ton,:),A(ton,:),x) ;      % apply the filter
   [Y,z] = buffer(y,nave,0,'nodelay') ;   % break up the filter output in T-length blocks
   S(:,k) = 10*log10(mean(Y.^2)) ;        % record the power in each block in dB
   CI(k) = 0.5/sqrt(0.23*fc(k)*nave/fs) ; % 1/(2sqrt(B*T)), B = (2^(1/6)-2^(-1/6))fc = 0.23fc
   if ton==3,                             % after each third TOL, decimate by 2 for the next octave
      if length(x)<4*ndec, break, end     % first check that there are enough samples
      x = decimate(x,2,ndec,'FIR') ;      % do the decimation
      fs = fs/2 ;                         % update the sampling rate and number of samples to average
      nave = round(fs*T) ;
   end
end

S = fliplr(S(:,1:k)) ;        % reorder the results from low to high
fc = flipud(fc(1:k)) ;        % and eliminate any unanalysed third octaves.
CI = flipud(20*log10([max(1-za*CI(1:k),0) 1+za*CI(1:k)])) ;
return


function [B,A] = oct3dsgn(Fc,Fs,N); 
% OCT3DSGN  Design of a one-third-octave filter.
%    [B,A] = OCT3DSGN(Fc,Fs,N) designs a digital 1/3-octave filter with 
%    center frequency Fc for sampling frequency Fs. 
%    The filter is designed according to the Order-N specification 
%    of the ANSI S1.1-1986 standard. Default value for N is 3. 
%    Warning: for meaningful design results, center frequency used
%    should preferably be in range Fs/200 < Fc < Fs/5.
%    Usage of the filter: Y = FILTER(B,A,X). 
%
% Abbreviated from the octave toolbox by:
% Author: Christophe Couvreur, Faculte Polytechnique de Mons (Belgium)
%         couvreur@thor.fpms.ac.be
% Last modification: Aug. 25, 1997, 2:00pm.

% References: 
%    [1] ANSI S1.1-1986 (ASA 65-1986): Specifications for
%        Octave-Band and Fractional-Octave-Band Analog and
%        Digital Filters, 1993.

% Design Butterworth 2Nth-order one-third-octave filter 
% Note: BUTTER is based on a bilinear transformation, as suggested in [1]. 
pi = 3.14159265358979;
f1 = Fc/(2^(1/6)); 
f2 = Fc*(2^(1/6)); 
Qr = Fc/(f2-f1); 
Qd = (pi/2/N)/(sin(pi/2/N))*Qr;
alpha = (1 + sqrt(1+4*Qd^2))/2/Qd; 
W1 = Fc/(Fs/2)/alpha; 
W2 = Fc/(Fs/2)*alpha;
[B,A] = butter(N,[W1,W2]); 

