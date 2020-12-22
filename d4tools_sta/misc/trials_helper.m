preproc_trials % do once
% do the following to make click lists for each trial
load('C:\tag_data\data\heatherwav\sif.25.2.1.mat')
cl=sortclicks_trials(x,fs);
% do this if you want to re-check or edit the click list
cl=sortclicks_trials(x,fs,cl);
% plot echogram
X=extractcues(x,cl(:,1)*fs,round(fs*[-0.0005 0.005]));
clf,imageirreg(cl(:,1),(1:size(X(:,2)))'*750/fs,20*log10(X)',1),axis xy
