function X = d3fixsensorgap(X,df,DEPLOY)
% Fix gap in sensor record due to DTAG3 resetting during deployment
% Diagnosis: 
% - DTAG files shorter than normal dtag file (this indicates that
%   recording has stopped earlier than expected)
% - xml file for subsequent dtg file will have file state "new" at start of
%   html file, in contrast to normal files that have file state "reopen"
% - Warning about timing error (and magnitude of timing error) will be
%   displayed when making prh file
% - Tagaudit for any period after this file will demonstrate difference
%   between sensor and audio timing, for example in surfacing periods
% Fix:
%   Run X = d3fixsensorgap(X,df,DEPLOY) after running d3deployment and
%   d3readswv. DEPLOY includes information on where the timing errors are.
%   Sensor values will be interpolated during the missing periods.
% FHJ, princeton, 2015

% First, find timing errors and abort correction if none are above 1s
terr = DEPLOY.SCUES.TERR ;
if ~any(terr>1)
    return
end

% Now find original sensor sampling rate (battery voltage) 
% and duration of sensors reported from xml files
sfs = df * X.fs(end) ;
sensdur = (DEPLOY.SCUES.N)/sfs;
cumsensdur = cumsum(sensdur) ;

% Check that length of decimated sensor data fits with expected sensor data
Obs = length(X.x{1})./X.fs(1) ;
Exp = cumsensdur(end) ;
if abs(Obs-Exp)>1
    disp(' Warning: Decimated sensor data differs from ')
    disp([' expected sensor data by ' num2str(Obs-Exp) ' seconds'])
end

% Calculate the cumulative time error as offset
cumterr = cumsum(terr) ;

% Now go through each channel and insert samples corresponding to each gap
for ch=1:length(X.fs),
    fs    = X.fs(ch);
    x     = X.x{ch} ;
    
    % INSERT HERE CORRECTION: CONSTRUCT PLACEHOLDER VECTOR; INSERT
    xx = NaN*ones(round((cumsensdur(end)+cumterr(end))*fs),1) ; % Make NaN vector
    
    % For first file, simply grab samples
    k = [1:round(cumsensdur(1)*fs)];
    xx(k) = x(k) ;
    
    % For second to last file, allocate samples appropriately
    for fil = 2:length(cumterr)
        offset = round(cumterr(fil)*fs) ;
        k = [round(cumsensdur(fil-1)*fs)+1:min([length(x) round(cumsensdur(fil)*fs)])];
        xx (k+offset) = x(k);
    end
    xx = xx(1:length(x)+offset);
    
    % Now find gaps (NaNs) and interpolate sensor readings
    kgap     = find(isnan(xx));
    kgood = setdiff([1:length(xx)],kgap) ;
    xx(kgap)  = interp1(kgood,xx(kgood),kgap,'linear');
    X.x{ch} = xx;
    
end