%  test front end gps processing by monte carlo simulation

g = 2.5 ;
df = 8 ;
load gpstestset1
sv = 3 ;
FD = [-42 -25]*1e3 ;
n = 200 ;
D1 = zeros(n,5) ;
D2 = D1 ;
b = 2*unpack(B(:,1),16)-1 ;
bb = b.*exp(-j*pi/2*(1:length(b))') ;
bb = decimate(bb,df,8*df,'FIR') ;
%[bb,fs] = bitgrab2bb(B(:,1),df,0);
%sigma = g*std(real(bb)) ;
for k=1:n,
   if rem(k,10)==0,
      fprintf('Trial %d of %d\n',k,n) ;
   end
   N = g*randn(length(b),1) ;
   nn = N.*exp(-j*pi/2*(1:length(b))') ;
   x = bb+decimate(nn,df,8*df,'FIR') ;
   [del,dop,snr] = fdoppsearchi_oa(x,sv,FD,16/df,1);
   %N = randn(size(bb,1),2)*[1;j] ;
   %[del,dop,snr] = fdoppsearchi_oa(bb+sigma*N,sv,[-42 -25]*1e3,16/df,1);
   D1(k,:) = [del dop(2) snr(2:4)] ;
   [del,dop,snr] = fft_search(bb,sv,FD)
   D2(k,:) = [del dop(2) snr(2:4)] ;
end

D1 = D1(D1(:,3)>85,:) ;
[std(D1(:,1))*df/16 std(D1(:,2))]     % std of delay in usecs and doppler in Hz
mean(D1(:,3:5))

D2 = D2(D2(:,3)>85,:) ;
[std(D2(:,1))*df/16 std(D2(:,2))]     % std of delay in usecs and doppler in Hz
mean(D2(:,3:5))

% result for standard fdoppsearchi_oa with B(:,1), sv=3, 8xdf decimation filter,
% baseband noise
%  g     snr      std(delay)     std(dopp)
%  3     150      0.05 us        55 Hz
%  2     293      0.03 us        34 Hz

% passband noise
%  g     snr      std(delay)     std(dopp)
%  2.5   240      0.034 us       35 Hz       8xdf decimation filter
