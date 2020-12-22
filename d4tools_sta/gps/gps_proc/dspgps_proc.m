
NDOPPS = 17 ;		% number of Doppler shifts between -8 and 8 kHz to test
THR = 150 ;

% x is input data stream at 16.368 MHz

% 1. find the zero sentinel and read the full array starting after the sentinel
kz = find((x(1:end-1)==0) & (x(2:end)==0)) ;
x = x([kz(end)+2:end 1:kz(1)-2]) ;

% 2. demodulate, decimate by 8 and take FFT of each 1ms chunk
F = dspgps_input(x) ;	% F is 2048x64

% 3. make or load FFTs of the 32 SV Gold codes
G = sv_spectrum ;		% G is 2048x32

% 4. do code-doppler search
R = zeros(size(G,2),2) ;
P = zeros(NDOPPS,1) ;
D = zeros(NDOPPS,1) ;
for ksv=1:size(G,2),    % repeat for each SV
   for kdopp=1:NDOPPS,
		X = dspgps_kernel(F,G(:,ksv),kdopp-8) ;
		[P(kdopp),D(kdopp)] = max(X) ;
   end
	[m,d] = max(P) ;			% find the largest peak over the doppler shifts
	if m>THR,
		R(ksv,:) = [m,D(d)] ;
	end
end

k = find(R(:,1)>0) ;
[r,I] = sort(R(:,1),1,'descend') ;
R = R(I,2)*1023/2048 ;


% STILL TO DO:
% apply fractional sample doppler shift
      for k=1:size(S,2),
         ss = conv(hdopp,circ(SS(:,k),nd));
         SS(:,k) = ss(16+(1:Nfft)) ;
      end
   end

% refine doppler search and interpolate
