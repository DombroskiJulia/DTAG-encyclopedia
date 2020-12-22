function    d3sensorcheck(filename)
%
%    d3sensorcheck(filename)
%

X=d3parseswv(filename);
% pressure and voltage
figure(1)
subplot(321),plot(X.x{19}*6),grid,title('Battery, V')
subplot(322),plot(X.x{11}*3),grid,title('Thermistor, V')
subplot(323),plot(X.x{12}*6),grid,title('PB+, V')
subplot(324),plot(X.x{13}*3),grid,title('PB-, V')
subplot(325),plot(X.x{10}*3),grid,title('Pressure, V')
subplot(326),plot(X.x{20}*3),grid,title('Ext, V')

% magnetometer
M=[X.x{1:6}];
[MM,Md]=interpmag(M,X.fs(1));
figure(2)
subplot(321),plot(Md*3),grid,title('Mz, V')
subplot(322),plot(MM*3),grid,title('MAGNETOMETER, V')
subplot(323),plot(X.x{14}*6),grid,title('MB+, V')
subplot(324),plot(X.x{15}*3),grid,title('MB-, V')
subplot(325),plot(X.x{16}*3),grid,title('Mtst0mV, V')
subplot(326),plot(X.x{17}*3),grid,title('Mtst3mV, V')
fprintf('\nMagnetometer') ;
fprintf('Magnetometer preamp gain %3.2f\n',mean(X.x{16}-X.x{17})*3/0.003)
fprintf('Click on start and end of flips interval...\n') ;
g=ginput(2) ;
k=round(g(1,1)):round(g(2,1));
[C,Y]=spherical_cal(MM(k,:),[],5/(X.fs(7)/2));
fprintf('\nMag spherical cal:\n')
fprintf(' Mx %2.3f, %2.3f\n',C(1,1:2)) ;
fprintf(' My %2.3f, %2.3f\n',C(2,1:2)) ;
fprintf(' Mz %2.3f, %2.3f\n',C(3,1:2)) ;

% accelerometer
figure(3)
A=[X.x{7:9}];
plot(A),grid
fprintf('\nAccelerometer') ;
fprintf('Click on start and end of flips interval...\n') ;
g=ginput(2) ;
k=round(g(1,1)):round(g(2,1));
[C,Y]=spherical_cal(A(k,:),1,5/(X.fs(7)/2));
fprintf('\nAcc spherical cal:\n')
fprintf(' Ax %2.3f, %2.3f\n',C(1,1:2)) ;
fprintf(' Ay %2.3f, %2.3f\n',C(2,1:2)) ;
fprintf(' Az %2.3f, %2.3f\n',C(3,1:2)) ;
