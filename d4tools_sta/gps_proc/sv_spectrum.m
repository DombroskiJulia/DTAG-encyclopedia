function    G = sv_spectrum(sv)
% 
%    G = sv_spectrum(sv)

Nfft = 2048 ;
CF = 2 ;

if nargin<1 || isempty(sv)
   sv = 1:32 ;
end

G = zeros(Nfft,length(sv)) ;
for k=1:length(sv),
   g = interp(2*ca_code(sv(k))-1,CF);      % interpolate C/A code by factor of CF
   %g = reshape(repmat(2*ca_code(sv)-1,1,CF)',[],1);      % interpolate C/A code by factor of CF
   g = resample(g,1024,1023);
   %g = [g(1:1023);0;g(1024:end);0] ;
   G(:,k) = conj(fft(g,Nfft)) ;
end
