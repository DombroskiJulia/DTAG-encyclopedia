function		fr = d4fragrepair(recdir)

%		fr = d4fragrepair(recdir)
%
%

% find any recording that has a dtg file but no wavt file
fr = [] ;
fx=dir([recdir '\*.dtg']);
fw=dir([recdir '\*.wavt']);
nx = zeros(length(fx),1);
for k=1:length(fx),
	nm = fx(k).name ;
	nx(k)=sscanf(nm(end+(-6:-4)),'%d');
end
nw = zeros(length(fw),1);
for k=1:length(fw),
	nm = fw(k).name ;
	nw(k)=sscanf(nm(end+(-7:-5)),'%d');
end
kf = find(ismember(nx,nw)==0) ;
if isempty(kf),
	return
end

fragdir = [recdir '/fragments'] ;
if ~exist(fragdir,'dir'),
	mkdir(recdir,'fragments') ;
end
	
kr = [] ;
for k=1:length(kf),
	fname = fx(kf(k)).name ;
	if kf(k)>1 && ~ismember(kf(k)-1,kf),	% if this is the first append to a given file
		bk = kf(k)-1 ;
	   % copy the previous dtg file to fragments directory
		fprintf('Backing up %s\n',fx(bk).name) ;
		copyfile([recdir,'\' fx(bk).name],fragdir) ;
		% keep track of the files that have been changed
		kr(end+1) = bk ;
	end
		
	% append this dtg file to the previous
	fprintf('Appending %s to %s\n',fname,fx(bk).name) ;
	d4fileappend([recdir '\' fx(bk).name],[recdir '\' fname]);
	% move the dtg file to fragments
	fprintf('Moving %s to fragments\n',fname) ;
	movefile([recdir,'\' fname],[fragdir '\' fname]) ;
	% delete the xml file
	if exist([recdir,'\' fname(1:end-3) 'xml'],'file'),
		delete([recdir,'\' fname(1:end-3) 'xml']) ;
	end
end

for k=1:length(kr),
	% when done, re-run d4read on the changed files
	fprintf('Running d4read on file %s...\n',fx(kr(k)).name) ;
   system(['/tag/projects/d4/host/d4host_dev/d4read.exe ' recdir '\' fx(kr(k)).name]);
end

fr = {fx(kr).name} ;
