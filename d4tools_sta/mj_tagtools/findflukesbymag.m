function    [F,p]= findflukesbymag(Mw,fs,fc,thr)
%
%    [F,p] = findflukesbymag(Mw,fs,thr)
%    VERY EXPERIMENTAL - SUBJECT TO CHANGE!!
%    UNPUBLISHED ALGORITHM - ACKNOWLEDGEMENT REQUIRED!!
%    Find cues to each fluke stroke using the body rotation method
%    (Martin et al. in press). Mw is the whale frame
%    magnetometer matrix. fs is the sampling rate.
%    fc should be set equal to about 0.4 of the nominal fluking rate 
%    in Hz. This is used to set the cut-off frequency of a low-pass filter.
%    thr is the magnitude threshold for detecting a fluke stroke in radians.
%
%    Output: 
%    F is a matrix of cues to zero crossings in seconds (1st column) and
%     zero-crossing directions (2nd column). +1 means a positive-going zero
%     crossing.
%
%    mark johnson    1 June 2011

n = round(5*fs/fc) ;
Mf = fir_nodelay(Mw,n,fc/(fs/2)) ;
Mt = Mw-Mf ;
qm = Mf(:,1).^2+Mf(:,3).^2 ;
V = [Mf(:,3) -Mf(:,1)].*repmat(1./qm,1,2) ;
badpts = find(qm < 0.5*Mf(:,2)) ;
p = real(asin(sum(V.*Mt(:,[1 3]),2))) ;
p(badpts) = NaN ;
K = findzc(p,thr,fs/(fc*2)) ;
F = [(K(:,1)+K(:,2))/(2*fs) K(:,3)] ;
return
