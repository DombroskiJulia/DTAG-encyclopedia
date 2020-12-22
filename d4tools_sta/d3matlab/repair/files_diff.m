function    files_diff(dir1,dir2)

%    files_diff(dir1,dir2)
%     Compare all the files with the same names in the two directories.
%     Report any mismatch in contents.
%

fn1 = dir(dir1) ;
fn2 = dir(dir2) ;
fnames2 = {fn2.name} ;

for k=1:length(fn1),
   if fn1(k).isdir,
      continue
   end
   kk = find(strcmp(fn1(k).name,fnames2)) ;
   if isempty(kk),
      fprintf('No file in dir2 matching %s\n',fn1(k).name) ;
      continue
   end
   f1=fopen([dir1,'/',fn1(k).name]) ;
   f2=fopen([dir2,'/',fn2(kk).name]) ;
   s1=fread(f1,inf,'uchar') ;
   s2=fread(f2,inf,'uchar') ;
   if length(s1)~=length(s2),
      fprintf('Length unequal: %s %d:%d\n',fn1(k).name,length(s1),length(s2)) ;
   end
   n = min(length(s1),length(s2)) ;
   if any(s1(1:n)~=s2(1:n)),
      fprintf('Mismatch: %s\n',fn1(k).name) ;
   end
   fclose(f1);
   fclose(f2);
end
