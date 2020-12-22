function    X = gps_decimate(x,md)
%
%    X = gps_decimate(x)
%     Unpack 1-bit binary samples in x at 16.368Msps,
%     demodulate and decimate to 2.048 MHz.
%     x is a vector of 16-bit packed binary samples from
%      d3readbin.
%     md is the mean doppler correction in Hz.
%
%`    Returns:
%     X is a 2048xn matrix with a column for each full millisecond
%     of data in x.
%
%     markjohnson@st-andrews.ac.uk

FC = 1575.42e6 ;        % GPS L1 carrier frequency
PB = 16368 ;            % pass-band samples in x per ms
FB = 2048 ;             % output rate in samples per ms
incr = PB*md/FC ;       % interpolation required to correct mean doppler in samples/ms

% Demodulate, decimate and interpolate the input signal
% adjusting for the average Doppler

% make decimating filter
h = fir1(47,0.8/8) ;    % df is 8
nh = length(h) ;

b = 2*unpack(x,16)-1 ;                 % convert packed binary samples to +/-1
b = b.*exp(-j*pi/2*(1:length(b))') ;   % form base-band signal with complex demodulation
nblks = floor(length(b)/PB) ;
X = zeros(FO,nblks) ;
ks = 0 ;
dfix = 0 ;
for k=1:nblks,
   X(:,k) = fft_resample(b(ks+(1:PB+nh)),h) ;
   ks = ks+PB ;
   dfix = dfix+incr ;
   if(abs(dfix)>0.5),
      ks = ks+round(dfix) ;
      dfix = dfix-round(dfix) ;
   end
end
