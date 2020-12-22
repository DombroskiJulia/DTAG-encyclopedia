loadprh('pw03_307b')
T=finddives(p,fs,300)
CL=findallclicks('pw03_307b',[T(1,1)+10 T(1,2)-10]);
C = findmissedclicks('pw03_307b',CL,[5e3 30e3],[0.05 0.35]);
