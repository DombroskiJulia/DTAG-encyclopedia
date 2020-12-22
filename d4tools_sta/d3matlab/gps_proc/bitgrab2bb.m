function    [bb,fs] = bitgrab2bb(x,df,BIN,nb)
%
%     [bb,fs] = bitgrab2bb(x,df,BIN,nb)
%     Convert an IF GPS bitgrab to a base-band complex vector, bb.
%     fs is the output
%     sampling rate in Hz. x can be a vector of packed 16 bit
%     measurements or the name of a file containing these.
%     df is the decimation factor - can be 1, 2, 4 or 8. The default
%     is 8. Option BIN=1 selects binary (non-filtered) decimation. 
%     BIN=0 is the default.
% 
%     mark johnson
%     majohnson@whoi.edu
%     Last modified: 27 May 2006

if nargin==1 | isempty(df),
   df = 8 ;
end

if nargin<3 | isempty(BIN),
   BIN = 0 ;
end

if nargin<4 | isempty(nb),
   nb = 1 ;
end

if isstr(x),
   x = readcchex(x) ;     % read raw IF bits sampled at 16MHz
end

if nb==1,
   b = 2*unpack(x,16)-1 ;     % convert to +/-1
else
   b = unpack(x,16) ;
   bm = b(1:2:end) ;          % magnitude bits
   bs = b(2:2:end) ;          % sign bits
   b = (2*bs-1).*(0.707*bm+0.707) ;
end

fs = 16368e3/df ;           % output sampling rate

% form base-band signal with full demodulation
if BIN==0,
	bb = b.*repmat([-j;-1;j;1],length(b)/4,1) ;
   if df>1,
      bb = decimate(bb,df,4*df,'FIR') ;
   end
   return
end

% form base-band signal with binary demodulation
switch df,
   case 8,
      % make decimation filter for a decimate by 2
      % this option is not tested!!
		h = fir1(10,0.42) ;
		B = buffer(b(2:4:end)+j*b(1:4:end),length(h),length(h)-2,'nodelay') ; 
		bb = (h*B).' ;
	case 4,
      % binary method
      %bb = b(2:4:end)+j*b(1:4:end) ;
      % tri-level method
      bb = (b(2:4:end)-b(4:4:end)+j*(b(1:4:end)-b(3:4:end)))/2 ;
      %bb = (bb(1:end-2)+bb(2:end-1)+bb(3:end))/3 ;
	case 2,
      bb = [b(2:4:end)+j*b(1:4:end) -b(4:4:end)-j*b(3:4:end)] ;
      bb = reshape(bb.',[],1) ;
   otherwise
      fprintf('Unknown decimation factor %d in BIN mode\n',df) ;
      bb = [] ;
end


