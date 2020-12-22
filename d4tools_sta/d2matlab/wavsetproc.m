function    [SL,T,F] = wavsetproc(dir,fnames,nfft,tave,fdet,tdet,tblnk,dthr)
%
%    [SL,T,F] = wavsetproc(dir,fnames,nfft,tave,fdet,tdet,tblnk,dthr)
%     Example:
%     ff=dir('e:/*.wav')
%     [SL,f] = wavsetproc('e:',{ff.name},1024,10,fdet,tdet,tblnk,dthr);
%

SL = {} ;
if ~isempty(dir) && ~ismember(dir(end),'/\'),
   dir = [dir,'\'] ;
end

stt = 0 ;
T = [] ;
SL = [] ;
for k=1:length(fnames),
   fname = [dir,fnames{k}] ;
   fprintf('Reading %d of %d\n',k,length(fnames));
   [sl,t,F,len] = wavproc(fname,nfft,tave,fdet,tdet,tblnk,dthr) ;
   T(end+(1:length(t))) = t+stt ;
   SL(:,end+(1:length(t))) = sl ;
   save _wavproc_temp
   stt = stt+len ;
end
