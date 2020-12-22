function    X = dspgps_kernel(F,G,kdopp)

%    X = dspgps_kernel(F,G,kdopp)
%     F is the matrix of input FFTs
%     G is the vector of SV FFT
%     kdopp is the Doppler shift in 1kHz increments

X = zeros(size(F,1),1) ;    % clear the accumulator
for k=1:size(F,2),
   XX = ifft(circ(F(:,k),kdopp).*G) ;
   X = X + abs(XX).^2 ;
end
