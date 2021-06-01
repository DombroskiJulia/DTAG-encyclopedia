%.wav split: code will split wave files in 60 s segments. 
%J. Dombroski Sep 2020.
%bult under version 2015a


projectdir = 'location of files to split'; 
outdir = 'location of directory to split into';  %can be the same as projectdir, but matlab dosent love it
dinfo = dir( fullfile(projectdir, '*.wav') ); %getting all wav files
filenames = fullfile( projectdir, {dinfo.name} ); %getting file names
nfiles = length(dinfo); % getting #files
stims = cell(nfiles,1);
stiml = zeros(nfiles,1);
Fss = zeros(nfiles,1);
for K = 1 : nfiles
    [y, Fss(K)] = audioread(filenames{K}); %reading each wav file. If >16bit it will freeze 
    stims{K} = y;
    stiml(K) = size(y,1) / Fss(K) * 1000;
end
for K = 1 : nfiles
    [~, basename, ext] = fileparts( filenames{K} );
    thisoutdir = fullfile(outdir, basename);
    if ~exist(thisoutdir, 'dir');
        try
            mkdir(thisoutdir);
        catch ME
            fprintf('count not make the output directory "%s", skipping file\n', thisoutdir);
            continue;
        end
    end
    nchan = size(stims{K},2);
    Fs = Fss(K);
    buffered_chans = arrayfun(@(Cidx) buffer(stims{K}(:,Cidx), floor(60*Fss{K})), 1:nchan, 'uniform', 0); %60=60seconds.
    nparts = size(buffered_chans{1},2);
    for part = 1 : nparts
       File = fullfile(thisoutdir, sprintf('Part%02d.wav', part));
       this_segment = cell2mat(cellfun(@(C) C(:,part), buffered_chans, 'uniform', 0));
       audiowrite(File, this_segment, Fs);
    end
end
