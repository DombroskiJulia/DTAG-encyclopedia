function    make25Hzraw(tag)
%
%    make25Hzraw(tag)
%
[s,fs]=swvread(tag,[],2) ;
save(['/tag/data/raw/' tag 'raw25'],'s','fs')

