function    [delay,dop,stats] = gpsperf(X,sv,nave,fd,pthr,SILENT)
%
%    [delay,dop,stats] = gpsperf(X,sv,nave,fd,pthr,SILENT)
%  stats = [probability of peak, snr, mean crosscorrelation, rms of noise, raw peak]
%

if ~isreal(X),
   X = abs(X).^2 ;
end

if nargin<5,
   pthr = 0.01 ;
end

if nargin<6,
   SILENT = 0 ;
end

% find peak in X
[m ndel] = max(X) ;                    % find maximum in code and doppler
[mm ndop] = max(m) ;
ncode = ndel(ndop) ;
kcode = 1+mod(ncode-1+(-1:1),size(X,1)) ;   % interpolate around code peak
kdop = max(1,ndop-1):min(size(X,2),ndop+1) ;
Dpk = X(kcode,kdop) ;            % mini matrix of X around the peak

if size(Dpk,2)==3,               % if doppler peak is not at the edge of the values tested
   XY = [-1 0 0 0 1;0 -1 0 1 0]' ;     % do a 2-d quadratic interpolation
   R = [XY.^2 XY ones(size(XY,1),1)] ;
   Q = pinv(R) ;                       % could be pre-computed
   H = Q*Dpk([2 4:6 8])' ;
   delay = ncode-H(4)/H(2)/2 ;         % the interpolated delay
   dop = ndop-H(3)/H(1)/2 ;            % the interpolated doppler index
   mpk = H(5)-H(4)^2/H(2)/4-H(3)^2/H(1)/4 ;  % the peak cross-correlation value

else                                % if doppler peak is at the edge
   Dpk = X(kcode,ndop) ;               % just do the quadratic interpolation in delay
   XY = [-1 0 1]' ;
   R = [XY.^2 XY ones(size(XY,1),1)] ;
   Q = pinv(R) ;
   H = Q*Dpk ;
   delay = ncode-H(2)/H(1)/2 ;
   dop = ndop ;
   mpk = H(3)-H(2)^2/H(1)/4 ;
end

dop = interp1(1:length(fd),fd,dop) ; % convert doppler index to Hz 
% Calculate the snr of the peak using chi-square assumption.
% In the absence of a signal, the incoherent sum should be distributed as chi-sq(2*nave), 
% where nave=number of 1 ms blocks averaged incoherently.
df = nave*2 ;      % degrees of freedom of the chi-sq distribution
XX = X([1:ncode-4 ncode+4:size(X,1)],:) ; % removing the peak, what is the noise level?
XX = XX(:) ;
mD = mean(XX) ;               % noise mean
mpk = mpk*df/mD ;             % scale the peak and noise measures to fit chi-sq(2*nblks) distribution
sD = std(XX)*df/mD ;          % noise standard deviation
SNR = 10*log10(mpk-df) ;
p = (1-chi2cdf(mpk,df))*length(XX) ;   % work out the probability of the peak
stats = [p SNR mD sD mm] ;   % [probability of peak, snr, mean crosscorrelation, rms of noise, raw peak]
%delay = delay*1023/1024 ;     % correct the code delay for the interpolation

if SILENT==0 && p<pthr,
   fprintf('SV %d: peak %3.1f, p=%1.4f (mean %d, SD %3.1f), at delay %4.2f, doppler %d Hz\n',...
   sv,mpk-df,p,round(mD),sD,delay,round(dop)) ;
end
