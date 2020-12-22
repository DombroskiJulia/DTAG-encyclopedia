function    [S,fields] = combine_csv(recdir,prefix)
%
%    [S,fields] = combine_csv(recdir,prefix)
%     Combine time-series data from a set of CSV files. Each file must
%		contain the same number of columns and the first column must be
%		date and time. The other columns should only contain numbers.
%     recdir is the path to the directory containing the preprocessed
%      observations (files ending with gps.mat).
%     prefix is the shared first part of the file names, e.g., for
%      files called hs16_265bnnn.csv (where nnn is a three digit
%      number), the prefix would be 'hs16_265b'.
%

S = [] ; fields = [] ;
if ~exist(recdir,'dir'),
   fprintf(' No directory %s\n', recdir) ;
   return
end

if length(recdir)>1 & ismember(recdir(end),['/','\']),
   recdir = recdir(1:end-1) ;
end

recdir = [recdir,'/'] ;       % use / for MAC compatibility
recdir(recdir=='\') = '/' ;
sp = [recdir,prefix,'*.csv'] ;
ff = dir(sp) ;

if isempty(ff),
   fprintf(' No files with names %s found\n',sp) ;
   return
end

for k=1:length(ff),
	fprintf(' Reading file %s\n',ff(k).name) ;
	[s,fields] = read_csv([recdir ff(k).name]) ;
	s = struct2cell(s)' ;
	try
   	t = datenum(strvcat(s{:,1}),'yyyy/mm/dd HH:MM:SS') ;
	catch
		fprintf(' Unable to convert date string in file %s\n',ff(k).name) ;
		return
	end
	x = [] ;
	for kcol=1:size(s,2)-1,
		x(:,kcol) = str2num(strvcat(s{:,kcol+1})) ;
	end
   if isempty(S),
      S = [t x] ;
   else
	   if length(fields)~= size(S,2),
			fprintf(' File %s has incompatible number of columns. Skipping.\n',ff(k).name) ;
			continue
		end
      S(end+(1:length(t)),:) = [t x] ;
   end
end
