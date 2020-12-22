function    cl = getclicks(x,fs,opts)
%
%   cl = getclicks(x,fs,opts)
%		EXPERIMENTAL
%		General purpose click finder with a variable threshold.
%		Unlike rainbow.m, this function is suitable for single channel
%		data.
%		x is an envelope sampled at fs Hz.
%		opts is an optional structure of configuration options. Valid
%		 fields are: blank, thrave, minthr, DT.

blank = round(0.001*fs) ;
thrave = 0.2 ;
minthr = 0.005 ;
DT = 0.2 ;        % was 0.1

if nargin>2,
   if isfield(opts,'blank'), blank = round(fs*opts.blank) ; end
   if isfield(opts,'thrave'), thrave = opts.thrave ; end
   if isfield(opts,'minthr'), minthr = opts.minthr ; end
   if isfield(opts,'DT'), DT = opts.DT ; end
end

T=max(abs(buffer(x,thrave*fs,thrave/2*fs,'nodelay')))';
t=(0:length(T))'*(fs*thrave/2);
T=max([T(1);T],minthr) ;
thresh = interp1(t,DT*T,(1:length(x))','cubic');
dxx = diff(x>thresh) ;
cc = find(dxx>0)+1 ;
if isempty(cc), cl=[]; return, end

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
done = length(cc)<2 ;
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
