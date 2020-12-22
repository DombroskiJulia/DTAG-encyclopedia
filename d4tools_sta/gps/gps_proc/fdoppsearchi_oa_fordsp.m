
% predefine:
FD doppler frequencies to search FD=[lowest,highest]

% initialization
CF = 2 ;                      % number of samples per chip
df = 16/CF ;                  % decimation factor from input rate
FC = 1575.42e6 ;              % GPS L1 carrier frequency
FS = 1023e3*CF ;              % base-band sampling rate
Nfft = CF*1024 ;              % FFT length to use
fstep = 300/FS ;              % target Doppler step
GUARD = -4:4 ;                % guard band around peak to exclude for noise calculations
incr = round((1+mean(FD/FC))*nmf) ;   % amount to move input pointer per block
[DT,mdopshft] = make_doppler_shift_filters(FD,FC) ;  % table of short FIR filters for interpolating dopplers

% demodulate, decimate and fft the input signal
for each millisecond of capture (16368 input bits or 1023 words)
   b = 2*unpack(x,16)-1 ;        % convert packed binary samples to +/-1
   bb = b.*exp(-j*pi/2*(1:length(b))') ;  % form base-band signal with complex demodulation
   bb = fft_resample(bb,df,8*df,'FIR') ;  % decimate and resample to 2048 samples/ms, stretch for mean doppler
   Fin = pack_to_8bits(fft(bb,Nfft)) ;    % fft and store in packed 8-bit format
end

% brute force search over svs and dopplers
for each sv
   % unpack matched filter
   g = reshape(repmat(2*ca_code(sv)-1,1,16)',[],1) ;      % interpolate C/A code by factor of 16 without filtering
   g = fft_resample(g,h) ;                % code now at 2048 samples/ms
   g = g(end:-1:1) ;                      % reverse code order for matched filtering
   Fg = fft(g,Nfft) ;                     % matched filter in frequency domain, can do in-place
   Fg = circ(Fg,mdopshft) ;               % adjust for mean doppler (integer number of fft bins)

   for kd=1:ndopps,              % do for each doppler frequency
      acc = zeros(Nfft,1) ;               % zero a power accumulator
      fmf = conv(Fg,DT(:,kd)) ;           % generate matched filter with doppler correction
      for k=1:nms,                        % for each 1ms block of input
         fin = unpack(Fin,k) ;            % unpack the input fft
         fin *= fmf ;                     % product of input fft and matched filter fft, in-place
         fin = ifft(fin,Nfft) ;            % inverse fft of product, can do in-place
         acc += abs(fin).^2 ;              % incoherent average over blocks
      end                        % for each input block

      pks = find_peaks(pks,acc) ;         % find peaks over threshold for this doppler
   end                           % for each doppler

   [delay,dopp] = peak_of_peaks(pks) ;    % find peak of ambiguity function and interpolate
   % if needed, do fine grain search here

end                        % for each sv
