
% D4m MF response curve
[R,FF,XD,XF] = d4_fresp('/tag/temp/audtst004');
[f1,q1]=sak_rc2fq(1800,3900,2.2e-9,330e-12,1)
[f2,q2]=sak_rc2fq(649,3650,2.2e-9,1e-9,1.36)
f3 = 1/(75*2*10e-9)/2/pi ;
[h,f] = biquad_resp([f1 f2 f3],[q1 q2 0]);
[h(:,2),f] = biquad_resp([70e3 70e3 100e3],[1.2 0.6 0],f);
% 1st column of h is the response with components as populated
% 2nd column is the ideal response
figure(3),clf
plot(f,h),grid
hold on
plot(R(:,1),R(:,2)-20.8,'m.-')
axis([0 max(R(:,1)) -50 3])

% D4m HF response curve
[R,FF,XD,XF] = d4_fresp('/tag/temp/hf019');
[f1,q1]=sak_rc2fq(604,2740,2.2e-9,220e-12,1)
[f2,q2]=sak_rc2fq(560,3000,1e-9,470e-12,1.36)
f3 = 1/(68*2*4.7e-9)/2/pi ;
[h,f] = biquad_resp([f1 f2 f3],[q1 q2 0]);
[h(:,2),f] = biquad_resp([180e3 180e3 256e3],[1.2 0.6 0],f);
figure(4),clf
plot(f,h),grid
hold on
plot(R(:,1),R(:,2)-20.6,'m.-')
axis([0 max(R(:,1)) -15 3])
