function       [y,afs] = warpaudio(tag,cues,fname)
%
%     [y,afs] = warpaudio(tag,cues,fname)
%     Warp and post emphasise audio sample for movie making
%

[x,fs] = tagwavread(tag,cues(1),diff(cues));
if fs==96e3,
   df = 2 ;
else
   df = 4 ;
end
[y,afs] = audiowarp(x,fs,df);
y = postemph(y,afs,1);
%y = 10*y ;

if nargin==3,
   wavwrite(y,afs,16,fname);
end
