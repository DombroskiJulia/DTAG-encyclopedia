% calibrate accelerometer and magnetometer sensors on tag.
% Begin by turning tags on and taking them away from any source of
% electronic interference i.e. take them outside.
% Take the tag in your hands and do a set up flips and smoothly as
% possible.

% Use d3parseswv to read in the sensor file.
% Y.x(1:3)=accelerometer Y.x(4:6)=magnetometer Y.x(7)=temp Y.x(8)=pressure
filename='C:\tag\testao3b_003';
Y=d3parseswv(filename);
A=[Y.x{1} Y.x{2} Y.x{3}];; % create matrix with accelerometer axes
M=[Y.x{4} Y.x{5} Y.x{6}]; % create matric with magnetometer axes

%% sampling rates
fsa=Y.fs(1);
fsm=Y.fs(4);

% For accelerometer and magnetometer begin my cropping the section of your
% data containing the flips.
Ac=crop(A,fsa);
Mc=crop(M,fsm);

%Then decimtae cropped data to around 5 Hz
Ad=decdc(Ac,40);
Md=decdc(Mc,10);


% run spherical cal on cropped and decimated accelerometer and
% magenetometer data
[Acal,GAcal] = spherical_cal(Ad,9.81,'gain'); % the output should have a residual <5% and an axial balance >20%
[Mcal,GMcal] = spherical_cal(Md,50,'gain');