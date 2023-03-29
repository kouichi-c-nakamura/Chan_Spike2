function chanout = K_setChanNumberPerChan(chan, path, mname)
% chanout = K_setChanNumberPerChan(chan, path, mname)
%
% Read a text file '*_chan.txt' that is associated with a Chan
% objects from an original .smr file and add ChanNumber field to Header
%
% In contrast to K_setChanNumber, which reads a text file
% associated with the single folder, this script reads a separate text tile
% assocated with the single original .smr file.
% TODO NOT IMPLEMENTED YET
%
% path    folder path for .mat and the text file containing channumber information
% mname   name of the source .mat file NOT including the extension

%% parse inputs
narginchk(3,3);

p = inputParser;

vf1 = @(x) isa(x, 'Chan');
addRequired(p, 'chan', vf1);

vf2 = @(x) ischar(x);
addRequired(p, 'textdir', vf2);
addRequired(p, 'mname', vf2);
            
parse(p, chan, path, mname);

%% openfile
fid = fopen([path, filesep,'ExportAsMat_chan.txt']);

if fid < 3
    error('K:setChanNumber:textdir:fid',...
        'textloc is not a valid file path for a text file.');
end

str = textscan(fid, '%s\t%s\t%s\t%s\t%s');

fclose(fid);


%% Store chantitle and channumber in cell arrays
    
labels = str{1,1}(4:end);
values = str{1,2}(4:end);

% remove double quotation marks
labels = regexprep(labels,'"','');
values = regexprep(values,'"','');


ind_fnames = find(strcmpi('filename', labels));
nfiles = length(ind_fnames);
nchan = diff([ind_fnames; length(labels)+1]) -1;
fname = cell(nfiles,1);
chantitle = cell(nfiles,1);
channumber = cell(nfiles,1);

for file = 1:nfiles
    fname(file) = values(ind_fnames(file));
    channumber{file} = zeros(nchan(file), 1);
    for chan = 1:nchan(file)
        chantitle{file}(chan,1) = labels(ind_fnames(file)+chan);
        channumber{file}(chan,1) = str2double(values{ind_fnames(file)+chan});
    end
end

%% Set chan.Header.channumber

indmfile = strcmp(mname, fname);
indchan = strcmp(chan.ChanTitles, chantitle{indmfile});

chan.Header.channumber = channumber{indmfile}(indchan);

chanout = chan;
end