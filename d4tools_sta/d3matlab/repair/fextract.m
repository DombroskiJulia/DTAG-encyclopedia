function    x = fextract(ifname,ofname,n,locn)
%
%    x = fextract(ifname,ofname,n,locn)
%

fin = fopen(ifname,'rb') ;
fout = fopen(ofname,'wb') ;
if nargin==4 && strcmpi(locn,'end')==1,
	fseek(fin,-n,1) ;
end
x = fread(fin,n,'uchar') ;
fwrite(fout,x,'uchar') ;
fclose(fin) ;
fclose(fout) ;
