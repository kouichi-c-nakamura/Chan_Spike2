function [list] = K_folder_mat2sparse(varargin)
% list = K_folder_mat2sparse(srcdir, destdir)
% list = K_folder_mat2sparse(srcdir, destdir, destaffix)
% list = K_folder_mat2sparse(srcdir, srcmatfilenames, destdir)
% list = K_folder_mat2sparse(srcdir, srcmatfilenames, destdir, destaffix)
%
% INPUT ARGUMENTS
% srcdir    folder path for input .mat files that were from Spike2 (required)
%
% destdir   folder path for output .mat files containing Chan
%               objects (required)
%
% destaffix (OPTIONAL) a string (char tyipe) for file name prefix and/or suffix
%           and a wildcard(*) that are common to the "source" files.
%           Multiple wildcard characters are not accepted. The "source"
%           file names and "destination" file names must be identical
%           except those affixes. In other words, the wildcards represent
%           the identical part of the file names for the two folders.
%
%           By default, if destaffix is not specified, '*.mat' is used for
%           destaffix. You can also use something like '*_sp.mat'.
%
% srcmatfilenames
%           In addition to srcdir, you can use cell array vector of file
%           names (must not contain a file separator) of the source mat
%           files to specify which files are to be processed. They must be
%           in the same folder. In case of Marker channel, you need include
%           both xxxx.mat and xxxx_mk.mat files.
%
%
% OUTPUT ARGUMENTS
%
% list      cell array containing the list of destination file names
%
%
%% This function works on .mat files in the srcdir folder and
%
% (1) Checks if waveform data in .mat files exported from Spike2 is in
% int16 format. Otherwise, you'll get an error. %TODO should be skip the
% process with warning
%
% (2) Converts binary event channel data in .mat files exported from Spike2
% into sparse double to save disk space. However, computation with sparse
% double is slower, so you should recover sparse double into full double in
% runtime.
%
% (3) Reads the comment field of each structure for a channel and extract
% channel number (in the format, 'N|comments') saved at the begining of the
% comment by Spike2 script ExportAsMat.s2s. Store the number into a new
% field channumber. The number and the | character are removed from the
% comment field. In case no channel number is found in the comment field,
% the channumber field is set to 0 with a warning.
%
% (4) Saves the modified and merged structure into a single .mat file in
% the folder destdir. You can add prefix and/or suffix (affixes) to the
% file names in case you want to save them in the same srcdir.
%
% (5) If srcdir == destdir (that is, if you choose the destination which is
% the same as the source), then the original *.mat and *_mk.mat files are
% deleted (even if the file names are different with prefix and/or suffix)
% and instead you get a merged .mat file.
%
% (6) An output .mat file in destdir may contain the following:
%
%        waveform data
%        X.values are stored in int16 format to save disk space.
%        You can recover it to double simply by the following:
%
%            values = double(X.values) * X.scale + X.offset
%
%        event data
%        X.values are stored as binned data in sparse double format to save
%        disk space. You can recover it to standard full double by the following:
%
%            values = full(X.values)
%
%        marker and textmark data
%        Note that these data are not binned as waveform and event data.
%        This is because binned output from Spike2 loses marker codes. To
%        convert them into binned data that are compatible with
%        waveform/event data, use MarkerChan class in runtime (do not save
%        as an object of this class). Construction of MarkerChan object is easy:
%
%            obj = MarkerChan(X, Y)
%
%        where X is marker/textmark structure and Y is waveform/event
%        structure, both of which are exported from Spike2. In this work
%        flow xxxxx_mk.mat is supposed to be accompanied by xxxxx.mat to
%        searve as Y. Note that when matching xxxxx.mat is missing, you'll
%        get warning and the resultant xxxxx.mat file for xxxxx_mk.mat
%        won't be prepared.
%
%
%% EXAMPLE
% srcdir = 'Z:\Work';
% affix = '*.mat';
% destdir = 'Z:\Work\test'
%
% [list] = K_folder_mat2sparse(srcdir, affix, destdir, affix);


%% Parse inputs

[isfilesspecified, srcdir, srcmatfilenames, destdir, destaffix] = ...
    local_parse(varargin{:});


%% Job

mnamesall = local_getmnamesall(srcdir, srcmatfilenames, isfilesspecified);

mnames = local_classify_mnames(mnamesall, destaffix);
clear mnamesall

list = cell(size(mnames, 1), 1);

for i_mat = 1:size(mnames, 1)
    %% waveform and event vs marker and textmark
    name_wfev = mnames{i_mat, 1}; % waveform and event
    name_mktm = mnames{i_mat, 2}; % marker and textmark
    name =      mnames{i_mat, 4}; % for saving

    
    if ~isempty(name_wfev)
        S1 = load(fullfile(srcdir, name_wfev));
        chantitles1 = fieldnames(S1);
        isconvrted_wfev = validateS(S1, name_wfev);
    else
        S1 = struct;
        chantitles1 = [];
        isconvrted_wfev = false;
    end
    
    if ~isempty(name_mktm)
        S2 = load(fullfile(srcdir, name_mktm));
        chantitles2 = fieldnames(S2);
        isconvrted_mktm = validateS(S2, name_mktm);
    else % not marker channel
        S2 =struct;
        chantitles2 = [];
        isconvrted_mktm = true;
    end
    
    %% Skip if already converted
    if isconvrted_wfev && isconvrted_mktm
        fprintf('%s is skipped because already converted.\n', name);
        list{i_mat} = [];
        continue % skip this mat file
        
    elseif ~isconvrted_wfev || isconvrted_mktm
        % only marker chan has been converted...integrity of the files are
        % lost
        
        assert(isempty(intersect(chantitles1, chantitles2)),... % there should not be overlap
            eid('intersect'),...
            'ChanTitles in %s and %s overlap.', chantitles1, chantitles2);

    end
    
    
    % validate chan titles
    assert(isempty(intersect(chantitles1, chantitles2)),... % there should not be overlap
        eid('intersect'),...
        'ChanTitles in %s and %s overlap.', chantitles1, chantitles2);
    
    %% convert to sparse double and assign chan number
    [S1, S2] = local_sparse(S1, S2, chantitles1, chantitles2, srcdir, name_wfev);
    
     
    S = local_combineS1andS2(S1, S2);
    
    S = local_orderfiledsByChanNumber(S); %#ok<NASGU>
    
    
    %% Save
    
    if strcmpi(srcdir, destdir)
        % delete original .mat files
        if ~isempty(name_wfev)
            delete(fullfile(srcdir, name_wfev));
        end
        if ~isempty(name_mktm)
            delete(fullfile(srcdir, name_mktm));
        end
    end
    
    if exist(destdir, 'dir') ~= 7 % doesn't exist
        s = mkdir(destdir);
        if s == 0
            error(eid('f:mkdir'),...
                'mkdir failed');
        end
    end
    
    % name for saving
    
    
    if ~isempty(name)
        save(fullfile(destdir, name),'-struct', 'S');
    end
    list{i_mat} = name;
    clear S
    
    %% report
    mktmonlyname = mnames{i_mat, 5};
    if isempty(mktmonlyname)
        fprintf('%s\n', fullfile(destdir, name));
    else
        warning('K:K_folder_mat2sparse:local_classify_mnames:mktmonly',...
            '%s was removed: marker channel without an accompanying mat file for event/waveform\n',...
            mktmonlyname);
    end
    
    
end
clear i_mat

list(cellfun(@isempty, list)) = [];

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mnamesall = local_getmnamesall(srcdir, srcmatfilenames, isfilesspecified)

if isfilesspecified
    
    mat = dir(fullfile(srcdir, '*.mat'));
    mat = {mat(:).name}';
    
    for i = 1:length(srcmatfilenames)
        
        assert( ~isdir(srcmatfilenames{i}),...
            eid('srcmatfilenames:isdir'),...
            '%s is not a file name, but a directory.', srcmatfilenames{i});
        
        assert(isempty(strfind(srcmatfilenames{i}, filesep)),...
            eid('srcmatfilenames:filesep'),...
            '%s contains a file separator.', srcmatfilenames{i});
        
        assert(ismember(srcmatfilenames{i}, mat),...
            eid('srcmatfilenames:notfound'),...
            '%s was not found in srcdir %s.', srcmatfilenames{i}, srcdir);
        
    end
    
    mnamesall = srcmatfilenames;
    if isrow(mnamesall)
        mnamesall = mnamesall';
    end

else
    
    listing = dir(fullfile(srcdir, '*.mat'));
    mnamesall = {listing.name}';
    
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [isfilesspecified, srcdir, srcmatfilenames, destdir, destaffix] = ...
    local_parse(varargin)

if iscellstr(varargin{2})
    isfilesspecified = true;
    
    narginchk(3,4);
    
    p= inputParser;
    vfsrcdir = @(x) (isrow(x) && ischar(x) && isdir(x)) ||...
        cellstr(x) && iscolumn(x);
    vfsrcmatfilenames = @(x) iscellstr(x) && isvector(x) && ...
        ~any(cellfun(@isdir, x));
    vfdestdir = @(x) isrow(x) && ischar(x) && isdir(x);
    
    vfa = @(x) ischar(x) && isempty(x) || isrow(x) && isempty(strfind(x, filesep)) ...
        && isempty(strfind(x, '*')) || length(strfind(x, '*')) == 1 ; % only accept one wild card
    p.addRequired('srcdir', vfsrcdir);
    p.addRequired('srcmatfilenames', vfsrcmatfilenames);
    p.addRequired('destdir', vfdestdir);
    p.addOptional('destaffix', '*.mat', vfa);
    
    p.parse(varargin{:});
    
    srcdir = p.Results.srcdir;
    srcmatfilenames = p.Results.srcmatfilenames;
    destdir = p.Results.destdir;
    
else
    isfilesspecified = false;
    
    narginchk(2,3);
    
    p= inputParser;
    vfdir = @(x) isrow(x) && ischar(x) && isdir(x);
    vfa = @(x) ischar(x) && isempty(x) || isrow(x) && isempty(strfind(x, filesep)) ...
        && isempty(strfind(x, '*')) || length(strfind(x, '*')) == 1 ; % only accept one wild card
    p.addRequired('srcdir', vfdir);
    p.addRequired('destdir', vfdir);
    p.addOptional('destaffix', '*.mat', vfa);
    
    p.parse(varargin{:});
    
    srcdir = p.Results.srcdir;
    srcmatfilenames = '';
    destdir = p.Results.destdir;
    
end

destaffix = p.Results.destaffix;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mnames = local_classify_mnames(mnamesall, destaffix)
% mnamesall    cellstr containing the list of .mat file names in a folder
%
% destaffix    a string (char tyipe) for file name prefix and/or suffix
%              and a wildcard(*) that are common to the "destination" files.
%              Multiple wildcard characters are not accepted. The "source"
%              file names and "destination" file names must be identical
%              except those affixes. In other words, the wildcards represent
%              the identical part of the file names for the two folders.
%
%              Typically, '*.mat' is used for destaffix. You can also use
%              something like '*_sp.mat'.
%
% mnames       cellstr (n ,3) orgnized per original file in row by row manner
%              col 1     .mat for waveform/event
%              col 2     .mat for marker/textmark
%              col 3     .mat for all without suffix but with extension
%              col 4     .mat for output files with prefix and suffix
%              col 5     .mat for marker/textmark only that is not
%                        accompanied by waveform/event


isWaveformOrEvent = cellfun(@isempty, (regexp(mnamesall, '_mk\.mat$')));

mnames_wfev = mnamesall(isWaveformOrEvent);
mnames_wfev_ = regexprep(mnames_wfev, '\.mat$', '') ;

mnames_mktm = mnamesall(~isWaveformOrEvent);
mnames_mktm_ = regexprep(mnames_mktm, '_mk\.mat$', '') ;

both = intersect(mnames_wfev_, mnames_mktm_);
wfevonly = setdiff(mnames_wfev_, mnames_mktm_);
mktmonly = setdiff(mnames_mktm_, mnames_wfev_);

mnames = [strcat(both, '.mat') , strcat(both, '_mk.mat');...
    strcat(wfevonly, '.mat') , cell(size(wfevonly));...
    cell(size(mktmonly)), strcat(mktmonly, '_mk.mat')];

mnames(:, 3) = strcat([both; wfevonly; mktmonly], '.mat');

affixes = strsplit(destaffix, '*');
prefix = affixes{1};
suffix = affixes{2};
mnames(:, 4) = [strcat(prefix, [both; wfevonly], suffix); cell(size(mktmonly))];

mnames(:, 5) = [cell(size(both)); cell(size(wfevonly)); mktmonly];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function isconverted = validateS(S, matname)
% validateS(S)
% S               struct
% matname         name of .mat file with extension
% isconverted     scalar logical

chantitles = fieldnames(S);
for i = 1:length(chantitles)
    
    this = S.(chantitles{i});
    
    if all(isfield(this, {'title','interval','scale','offset','units','start', 'length', 'values'})) && ...
            ~all(this.values == 0 | this.values == 1)
        
        % waveform channel
        if ~isa(this.values, 'int16')
            error(eid('validateS'),'values must be int16 class');
        end
        
    elseif all(isfield(this, {'title','interval','start', 'length', 'values'})) &&...
            all(this.values == 0 | this.values == 1)
        % event channel
        
    elseif all(isfield(this, {'title','codes','length', 'times'})) && ...
            ~any(isfield(this, {'items', 'text'}))
        % marker channel
        
    elseif all(isfield(this, {'title','codes','items', 'length', 'times', 'text'}))
        % textmark channel
        
    else
        if isstruct(this) && all(structfun(@(x) isfield(x, 'channumber'), this));
            error(eid('validateS:struct:channnumber'),...
                'It seems that the loaded .mat file %s has already been converted by K_folder_mat2sparse', matname);
        else
            error(eid('validateS:struct:invalidfields'),...
                'The loaded .mat file %s contained data other than Spike2 export', matname);
        end
    end
    
end

%% check if the .mat file was already converted

isconverted_chan = false(length(chantitles), 1);

for i = 1:length(chantitles)
    
    this = S.(chantitles{i});
    
    
    if isfield(this, {'channumber'}) && ~isempty(this.channumber)  && this.channumber > 0
        
        isconverted_chan(i) = true;
        
    end
end

if all(isconverted_chan)
    isconverted = true;
%     warning('K:K_folder_mat2shrink:validateS:channumber:isconvertedall',...
%         ['All the fields in the loaded .mat file %s has channumber field.'...
%         ' It appears to have been converted already.\n'], matname);
    
elseif any(isconverted_chan)
    
    ss = repmat('%s, ', 1, nnz(isconverted_chan));
    
    error('K:K_folder_mat2shrink:validateS:channumber:isconvertedany',...
        ['The field ', ss, 'in the loaded .mat file %s has channumber field while the others don''t.'...
        ' It appears to have been partially converted already.\n'], ...
        chantitles{isconverted_chan}, matname);
else
    isconverted = false;
end




end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function S = local_assignChanNumber2field(S)
% S = local_assignChanNumber2field(S)
%
% S             structure holding data of Spike2 recording
%
% textdir       folder path for the text file containing channumber
%               information
%
% mnamelong     name of the source .mat file INCLUDING suffix and extension

%% parse inputs
narginchk(1,1);

p = inputParser;

vf1 = @(x) isstruct(x) && isfield(x, 'title') && isfield(x, 'comment'); 
addRequired(p, 'S', vf1);

parse(p, S);
clear p vf1

%% Job

chanN = regexp(S.comment, '(^\d+)\|', 'tokens'); % row vector output

if isempty(chanN)
    if ~isfield(S, 'channumber')    
        
        warning off backtrace
        warning(eid('local_assignChanNumber2field:thenum'),... %TODO should it be an error?
            'The comment field of the channel %s lacks the channel number. The field channumber is set to 0', S.title);
        warning on backtrace
        chanN = 0;
    
    end
else
    chanN = str2double(chanN{1});
    assert(fix(chanN) == chanN & chanN > 0, ...
        eid('local_assignChanNumber2field:thenum'),...
        'the channel number %d must be a positive integer', chanN);
    
    S.comment = regexprep(S.comment, '^\d+\|', ''); % recover the comment
    % NOTE: The recovery will be imperfect in case the comment was truncated
end

S.channumber = chanN;

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S1, S2] = local_sparse(S1, S2, chantitles1, chantitles2, srcdir, name_wfev)

for j = 1:length(chantitles1)
    %wavemark and event
    
    this = S1.(chantitles1{j});
    
    %% job: convert binned event in Spike2 .mat into sparse double
    if all(isfield(this, {'title','interval','start', 'length', 'values'})) &&...
            all(~isfield(this, {'scale','offset'})) &&...
            all(this.values == 0 | this.values == 1) % event channel, NOT waveform
        
        if ~issparse(this.values)
            this.values = sparse(this.values);
        end
    end
    
    assert(~(all(isfield(this, {'title','interval','start', 'length', 'values', 'scale','offset'})) && ...
        all(this.values == 0 | this.values == 1)),...
        'local_sparse:waveform:values:invalid',...
        ['Although this channel %s IN %s is waveform, the values only takes 0 or 1. ',...
        'Possibly, an error in Spike2 export. Check the original .smr file.'],...
        this.title, fullfile(srcdir, name_wfev));
    
    this = local_assignChanNumber2field(this);
    S1.(chantitles1{j}) = this;
    clear this
end
clear j

for j = 1:length(chantitles2)
    % marker and textmark
    
    this = S2.(chantitles2{j});
    
    this = local_assignChanNumber2field(this);
    S2.(chantitles2{j}) = this;
    clear this
end
clear j

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = local_combineS1andS2(S1, S2)
    
S = struct;
fldn1 = fieldnames(S1);
fldn2 = fieldnames(S2);

for i = 1:length(fldn1)
    S.(fldn1{i}) = S1.(fldn1{i});
end


for i = 1:length(fldn2)
    S.(fldn2{i}) = S2.(fldn2{i});
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = local_orderfiledsByChanNumber(S)
    
fldn =fieldnames(S);
channumbers = zeros(size(fldn));
for i = 1:length(fldn)
    channumbers(i) =S.(fldn{i}).channumber;
end
clear i

[~, perm] = sort (channumbers);

S = orderfields(S, perm);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K:
%
%
% input argument
% str (Optional) string in char type (row vector)
%
% output argument
% eid an error id composed of 'K:(functionname):str'

narginchk(0, 1);
p = inputParser;
p.addOptional('str', '', @(x) isempty(x) || ischar(x) && isrow(x));
p.parse(varargin{:});
str = p.Results.str;

if isempty(str)
    str = '';
else
    str = [':', str];
end

[~,m,~] = fileparts(mfilename('fullpath'));

eid = ['K:', m, str];


end




