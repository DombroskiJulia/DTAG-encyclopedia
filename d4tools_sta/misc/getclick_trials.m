function    cl = getclick_trials(x,fs)
%
%   cl = getclick_trials(x,fs)
%

blank = round(0.001*fs) ; 
thrave = 0.2 ;
minthr = 0.005 ;
DT = 0.2 ; 

T=max(abs(buffer(x,thrave*fs,thrave/2*fs,'nodelay')))';
t=(1:length(T))'*thrave/2;
t=[0;t];
T=[T(1);T];
T=max(T,minthr) ;
thresh = interp1(t,DT*T,(1:length(x))/fs,'PCHIP')';
dxx = diff(x>thresh) ;
cc = find(dxx>0)+1 ;

% eliminate detections which do not meet blanking criterion.
% blanking time is calculated after pulse returns below threshold

% first compute raw pulse endings
coff = find(dxx<0)+1 ;    % find where envelope returns below threshold
cend = size(x,1)*ones(length(cc),1) ;
for k=1:length(cc)-1,
   kends = find(coff>cc(k),1) ;
   if ~isempty(kends),
      cend(k) = coff(kends) ;
   end
end

% merge pulses that are within blanking distance
done = 0 ;
while ~done,
   kg = find(cc(2:end)-cend(1:end-1)>blank) ;
   done = length(kg) == (length(cc)-1) ;
   cc = cc([1;kg+1]) ;
   cend = cend([kg;end]) ;
end

level = zeros(length(cc),1) ;
for k=1:length(cc),
   level(k) = max(x(cc(k):cend(k))) ;
end

cl = [cc*(1/fs) level] ;
