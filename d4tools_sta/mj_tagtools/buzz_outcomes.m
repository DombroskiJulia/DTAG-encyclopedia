function    M = buzz_outcomes(tag)
%
%    M = buzz_outcomes(tag)
%     Columns of M are: buzz cue
%                       target visible (-1,0,1,2,3)
%                       elusive (-1,0,1)
%                       captured (-1,0,1)
%                       increase in closing speed (-1,0,1)
%     -1 means that attribute could not be judged

fn = sprintf('/tag/docs/dtagpapers/beakers/beaker_elusive/score_%s.csv',tag);
[X,fields]=readcsv(fn);
M = str2num(strvcat(X(:).buzz)) ;
M(:,2) = str2num(strvcat(X(:).target_visible)) ;
M(:,3) = str2num(strvcat(X(:).elusive)) ;
M(:,4) = str2num(strvcat(X(:).capture)) ;
M(:,5) = str2num(strvcat(X(:).incrCS)) ;
