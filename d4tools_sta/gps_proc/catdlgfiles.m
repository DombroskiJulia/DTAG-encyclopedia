function    N = catdlgfiles(recdir,tag)
%
%    N = catdlgfiles(recdir,tag)
%

[fn,devid,recn,recdir]=getrecfnames(recdir,tag) ;
X = {} ;
for k=1:length(fn),
   x=readcsv([recdir fn{k} '.dlg'],[],-1) ;
   X = vertcat(X,x) ;
end

n1 = str2num(strvcat(X{:,1})) ;
n2 = str2num(strvcat(X{:,2})) ;
n4 = str2num(strvcat(X{:,4})) ;
n3 = strcmp('gps',{X{:,3}})' ;
N = [n1 n2 n3 n4] ;
