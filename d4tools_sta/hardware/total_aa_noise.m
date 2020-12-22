% total self noise in a 7-pole anti-alias filter

N0 = 2.3*30 ;
N1 = 17 ;
[v1,f] = sak_noise(413,2903,3.3e-9,1e-9,1);
n1 = v1(:,2)*N1 ;
n1_0 = v1(:,1).*N0 ;
n1t = n1 ;

N2 = 9.5 ;
v2 = sak_noise(1048,3688,3.3e-9,470e-12,1,f);
n2 = v2(:,2)*N2 ;
n2_0 = v2(:,1).*n1_0 ;
n2_1 = v2(:,1).*n1 ;
n2t = sqrt(n2.^2+(v2(:,1).*n1t).^2) ;

N3 = 9.5 ;
v3 = sak_noise(952,2863,2.2e-9,1e-9,1.36,f);
n3 = v3(:,2)*N3 ;
n3_0 = v3(:,1).*n2_0 ;
n3_1 = v3(:,1).*n2_1 ;
n3_2 = v3(:,1).*n2 ;
n3t = sqrt(n3.^2+(v3(:,1).*n2t).^2) ;

h4 = biquad_resp(95e3,0,f) ;
v4 = 10.^(h4/20) ;
n4t = n3t.*v4 ;      % filter only noise RTO
n4_0 = n3_0.*v4 ;    % preamp only noise RTO
n4_1 = v4(:,1).*n3_1 ;
n4_2 = v4(:,1).*n3_2 ;
n4_3 = v4(:,1).*n3 ;

N5 = 55 ;      % ADC input noise at 192kHz (48uV/sqrt(192e3)/2)
n5t = sqrt(n4t.^2 + N5.^2) ;
