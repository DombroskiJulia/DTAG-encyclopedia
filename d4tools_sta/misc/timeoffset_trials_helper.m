load('E:\Heatherwavsecs\20161102_freja_0.25_0.5_1(4)st.mat')
load('E:\Heatherwavsecs\click files\20161102_freja_0.25_0.5_1(4).mat')
t = timeoffset_trials(x,fs,cl,-1,2)

load('E:\Heatherwavsecs\click files\20161102_sif_0.25_0.5_1(12).mat')
% note: this click file has an x vector in it which it shouldn't -
% it makes things screw up if you read in the click file after the
% soundtrap file
load('E:\Heatherwavsecs\20161102_sif_0.25_0.5_1(12)st.mat')
timeoffset_trials(x,fs,cl,3,1)
