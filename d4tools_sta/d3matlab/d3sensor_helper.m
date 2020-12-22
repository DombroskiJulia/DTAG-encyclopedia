% Example file for reading in and calibrating sensor data
% from a DTAG3 or DTAG4 deployment

recdir = 'E:\hs16\hs16_265c' ;
prefix = 'hs16_265c' ;

% generate CAL file for the deployment
[CAL,DEPLOY]=d3deployment(recdir,prefix);
% make a common 5Hz sensor structure for overview and calibration
X = d3readswv_commonfs(recdir,prefix) ;

% do data-driven calibrations
[p,CAL,fs,tempr,fst] = d3calpressure(X,CAL,'full');
[A,CAL,fs] = d3calacc(X,CAL,'full',1);
[M,CAL] = d3calmag(X,CAL,'full',1);
% store updated CAL structure
d3savecal(prefix,'CAL',CAL);

% save tag-frame PRH file
saveprh(prefix,'p','fs','A','M','tempr')
