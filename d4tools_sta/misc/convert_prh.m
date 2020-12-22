function		ncfile = convert_prh(prhfile,csvfile,POSfile)

%		ncfile = convert_prh(prhfile,csvfile)
%

VARS = {'A','M','P'} ;
vtype = {'acc','mag','press'} ;
VAR={'POS'};
type={'pos'};
frm = [0  0  0] ;					% 0 = tag, 1 = animal
scf = [9.81,1,1] ;			% conversions to standard units
fr=[0];
sf=[1];

X=load('C:\tag\in_progress\hs16_265aprh.mat');
info=csv2struct('C:\tag\Tag Lab\info\hs16_265cinfo.csv');
Y=load('C:\tag\Tag Lab\pos\POS_hs_265c.mat');

fn = fieldnames(X) ;
fm=fieldnames(Y);
if ~isfield(X,'fs'),
	fprintf(' PRH file must contain a varable fs with the sampling rate\n');
	return
end
	
fs = X.fs(1) ;
ir=0;
ncfile = sprintf('%s_prh%d',info.depid,round(fs));
save_nc(ncfile,info) ;

for k=1:length(VARS),
	k = strcmpi(fn,VARS{k}) ;
	if isempty(k), continue, end
	V=sens_struct(X.(fn{k})*scf(k),fs,info.depid,vtype{k});
	if frm(k) == 1,
		V.frame = 'animal' ;
	else
		V.frame = 'tag' ;
	end
	add_nc(ncfile,V) ;
end

for k=1:length(VAR),
    k=strcmpi(fm,VAR{k});
    if isempty(k),continue,end
    Z=sens_struct(Y.(fm{k}),Y.POS(:,1),info.depid,type{k});
    if frm(k) == 1,
		Z.frame = 'animal' ;
	else
		Z.frame = 'tag' ;
	end
    add_nc(ncfile,Z);
end

