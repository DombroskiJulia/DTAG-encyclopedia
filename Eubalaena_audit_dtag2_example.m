
settagpath('prh','C:/tag/tag2/metadata/prh')
settagpath('audit','E:/DUKE Tagging/SEUS 2006_Duke tagging/audit')
settagpath('cal','C:/tag/tag2/metadata/cal')
settagpath('audio','E:/DUKE Tagging/SEUS 2006_Duke tagging')


%set your tag name
tag='eg06_028a'% this is an example for tag: pw08_110e
loadprh(tag) %

%if you have any doubt how it works do 
help tagaudit
%first time you audit a tag
R = tagaudit('eg06_028a',1)% this shows you the audit above the specgram for the cue that you put in the second place. in this case is in second 1
%for dtag3 do the next: R = d3audit(''H:/tag/tag2/data/pw08/pw08_110e','pw08110e',1)%dtag3
%save your aduit
saveaudit('eg06_028a',R)

%after the first time you only have to load your adudit and keep auditing
%from where you left it the previous time

R=loadaudit('eg06_028a')% this loads the audit 
R = tagaudit('eg06_028a',1,R)% this shows you the audit above the specgram for the cue that you put in the second place. in this case is in second 1
