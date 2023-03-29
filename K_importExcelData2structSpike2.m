function list = K_importExcelData2structSpike2(matdir, varargin)
% Import data from *_info.xlsx files and merge them with *_sp.mat files and save as *_m.mat files.
%
% list = K_importExcelData2structSpike2(matdir, ______)
% list = K_importExcelData2structSpike2(matdir, destdir, ______)
% list = K_importExcelData2structSpike2(_____, '-regexp', {'^kjx127'; '^kjx158i02'})
% list = K_importExcelData2structSpike2(_____, '-ismember', {'kjx127a01_sp.mat'; 'kjx127b01_sp.mat'})
% list = K_importExcelData2structSpike2(_____, '-listdlg', true)
%
% K_importExcelData2structSpike2 imports data from *_info.xlsx files and
% merge them with *_sp.mat files and save as *_m.mat files. If matdir
% equals to destdir, then *_sp.mat files will be deleted after the
% procedure.
%
% Input arguments
%  matdir              string (a row vector of char type). Folder path for
%                      the directory that contains MAT files containing
%                      sparse double for event channels (*_sp.mat)  and the
%                      relevant Excel (*_info.xlsx) files. Only when both
%                      matching files exist, the contents of the Excel file
%                      are imported to .mat files by adding extra fields to
%                      each structure for one recording channel.
%
%  destdir             (OPTIONAL) A string for a valid folder path in which
%                      the output .mat files are to be saved. By dafault,
%                      destdir is matdir. Useful for test purpose
%                      when you don't want to change the actual data.
%
% (Optional Param/Value pair)
% An option to specify a subset of .MAT files in the folder matdir. ONLY
% ONE of the following three can be accepted.
%
%   '-regexp'          A string or cell vector of regular expressions that
%                      match the name of .MAT file to be modified.
%                      ex. {'^kjx127'; '^kjx158i02'}
%                      ex. {'^kjx127', '^kjx158i02'}
%                      ex. '^kjx(127|158i02)' % almost equivalent as above
%
%   '-ismember'        A string or cell vector of strings for .MAT data file
%                      names. This requires exact match including file
%                      extentions.
%                      ex. {'kjx127a01@0-100_sp.mat'; 'kjx158i02@0-100_sp.mat'}
%                      ex. {'kjx127a01@0-100_sp.mat', 'kjx158i02@0-100_sp.mat'}
%                      ex. 'kjx127a01@0-100_sp.mat'
%
%   '-listdlg'         A scalar logical or 0 or 1: GUI list option for file
%                      selection.
%                      Default: false
%
% OUTPUT ARGUMENT
% list                 The names of output MAT (*_m.mat) files that contain
%                      merged data in a cell column of strings
%
% works together with K_extractExcelDataForSpike2
%
% For channels for probe data, chantitle for probe data must be in the
% format "A16" or "B32", where numbers can be 1 to 16 or 1 to 32. In
% regular expression the format is defined as '[A-B]\d\d'. For example, a
% chantitle "probeA05e" is accepted. See local_getRow16x1  and
% local_getRow16x2.
%
% Extrac fields such as 'probemode', 'animal', 'record', 'electrode'
% 'location', 'dopamine', and 'note_labeledcell' will be added to the
% channel.
%
% For EEG channel, chantitle must be like "IpsiEEG", "PostECoG" or
% "contEEG". In detail, the format is defined in regular expression as
% '(^|^[iI]psi|^[pP]ost|^[cC]ont)E(E|Co)G$'. For these chantitles, extra
% fields such as 'animal', 'record', and 'dopamine' will be added to the
% channel. ('probemode', 'electrode' 'location', and 'note_labeledcell' are
% omitted.)
%
% For other type of channels, such as Juxta data, any chantitle is
% accepted. They include the same fields as probe channels.
%
%
% See also
% K_importExcelData2structSpike2_test, K_extractExcelDataForSpike2,
%
%
% ISSUES
% Difficult to detemine the specification of chantitles.
% % TODO what about stim channel or Hum channel? They should not have location
% field, for example.
%
% TODO handling of concatenated data files
% one .mat file corresponds to multiple rows in the Excel sheet.
% The file names tend to be irregular. Need to be tested.
%
% NOTE: how to handle brain state?
% Because Excel sheet is per recording file, it cannot support the cases in
% which both brain states are included at different times and are useful
% for different puropse. Data for different brain states should be handled
% in separate folders.
%
% 7 Jan 2015
% Written by Dr Kouichi C. Nakamura
% kouichi.c.nakamura@gmail.com

%% initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
regexpr = '';
targetfiles = '';
dogui = false;
destdir = matdir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parse
narginchk(1,4);

% which one recording file contains both brain states at different times
assert(isdir(matdir), 'inputfolder must be a valid folder path');

p = inputParser;
vfm = @(x) isdir(x) && isrow(x) && ischar(x);

addRequired(p, 'inputfolder', vfm);

p.parse(matdir);

clear vfm

%% Param/Val pair

[regexpr, targetfiles, dogui, destdir] = local_paramvalpair(regexpr, ...
    targetfiles, dogui, destdir, varargin{:});


%% job

matfiles = dir(fullfile(matdir, '*_sp.mat')); % required *_sp.mat files

matnames = {matfiles(:).name}';

infofiles = dir(fullfile(matdir, '*_info.xlsx'));
infonames = {infofiles(:).name}';


%% check if matfiles and infofiles both exist by their names

[ind1, ind2] = local_checkMATandINFO(matnames, infonames, regexpr, targetfiles, dogui);


%% remove suffix and compare them
%NOTE char(regexp(names{i}, '^[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d\(w*(?=@)|\S*(?=_sp\.mat$))','match')
% see scr20170726_150052_regexpfor_K_importExcelData2structSpike2.mlx

matfiles = local_add_shortname_OK_toStruct(matfiles, matnames,...
    'char(regexp(names{i}, ''^[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d(\w*(?=@)|\S*(?=_sp\.mat$))'', ''match''))', ind1);

% char(regexprep(infonames(i),'_info.xlsx',''));
infofiles = local_add_shortname_OK_toStruct(infofiles, infonames, ...
    'char(regexprep(names(i),''_info.xlsx'',''''))', ind2);


list = cell(length(matfiles), 1);

for i = 1:length(matfiles)
    if matfiles(i).OK

        TF = strcmp(matfiles(i).shortname, {infofiles(:).shortname}');
        if nnz(TF) == 1
            % match

            %% read xlsx
            try
                [~, ~, raw] = xlsread(fullfile(matdir, infofiles(TF).name));
            catch Exc
                keyboard
            end


            %% assert raw

            assert(all(strcmp(raw(2:end, 1), regexp(infofiles(TF).shortname, ...
                '^[a-zA-Z-_]{3,6}\d{1,3}', 'match'))),...
                eid('excel:animal:invalid'),...
                '%d/%d ''Animal'' name in raw doesn''t match %s', ...
                nnz(~strcmp(raw(2:end, 1), regexp(infofiles(TF).shortname, ...
                '^[a-zA-Z-_]{3,6}\d{1,3}', 'match'))),...
                length(raw(2:end, 1)),...
                infofiles(TF).shortname);

            %% load .mat
            try
                S = load(fullfile(matdir, matnames{i}));
            catch ME1
                if strcmp( ME1.identifier, 'MATLAB:load:cantReadFile')
                    fprintf('Failure in loading %s\n',...
                        fullfile(matdir, matnames{i}));
                    disp('You could retry "S = load(fullfile(matdir, matnames{i}));" and then continue by typing "return".');
                    keyboard

                else
                    fprintf('Unexpected error during loading %s\n',...
                        fullfile(matdir, matnames{i}));
                    disp('You could retry "S = load(fullfile(matdir, matnames{i}));" and then continue by typing "return".');
                    keyboard
                end
            end

            chantitles = fieldnames(S);

            % get dopamine field
            if size(raw, 1) > 1
                thisDopamine = raw{2, local_findcol(raw, 'Dopamine')};

                if ~all(strcmp(thisDopamine, raw(2:end, local_findcol(raw, 'Dopamine'))))
                    warning off backtrance
                    warninng(eid('dopamine:notidentical'),...
                        'Some values of dopamine filed were different from others in file %s', matnames{i});
                    warning on backtrance
                end

            else
                thisDopamine = '';
            end

            % get isinjection field

            if size(raw, 1) > 1 && ...
                    ~isnan(raw{2, local_findcol(raw, 'isinjection')}) && ... %TODO
                        raw{2, local_findcol(raw, 'isinjection')} == 1
                isinjection = true;
            else
                isinjection = false;
            end

            % get injLocation field
            if size(raw, 1) > 1 && ischar(raw{2, local_findcol(raw, 'injLocation')})
                injLocation = raw{2, local_findcol(raw, 'injLocation')};
            else
                injLocation = '';
            end



            for j = 1:length(chantitles)

                %% parse chantitles

                thisAnimal = local_assertAnimalIdentity(raw, i, matnames);

                thisRecord = local_assertRecordIdentity(raw, i, matnames);

                S = local_assign_common(S, chantitles, j, thisAnimal, thisRecord, thisDopamine, isinjection, injLocation);


                %% EEG channels
                % parse channnames
                if ~isempty(regexp(chantitles{j}, '(^|^[iI]psi|^[pP]ost|^[cC]ont)E(E|Co)G$', 'once'))

                    if isinjection
                        S = local_assign_xyz(S, chantitles, j, raw, 2);
                    else
                        S = local_assign_xyz_null(S, chantitles, j);
                    end

                    S = local_assign_others_null(S, chantitles, j);


                %% probe channels
                % parse channnames
                elseif any(cellfun(@(x) ~isempty(x), regexp(chantitles, '[A-B]\d\d'))) ... % recording data includes probe channels (unit, LFP or spike)
                        && ~isempty(regexp(chantitles{j}, '[A-B]\d\d', 'once')) % probe channels (unit, LFP or spike)

                    %% find the matching data

                    col_probemode = local_findcol(raw, 'ProbeMode');
                    col_electrode = local_findcol(raw, 'Electrode');

                    if all(strcmp('16x1', raw(2:end, col_probemode)))

                        probemode = '16x1';

                        row = local_getRow16x1(raw, col_electrode, chantitles, j);

                        local_warnrow(row, 'probe16x1', i, j, TF, infofiles, chantitles, matnames);


                    elseif all(strcmp('16x2', raw(2:end, col_probemode)))

                        probemode = '16x2';

                        row = local_getRow16x2(raw, col_electrode, chantitles, j);

                        local_warnrow(row, 'probe16x2', i, j, TF, infofiles, chantitles, matnames);

                    end

                    S = local_assign_xyz(S, chantitles, j, raw, row); %TODO
                    S = local_assign_others(S, chantitles, j, probemode, raw, row);

                else % juxta data etc
                    %% accept any chantitle
                    probemode = '';

                    col_electrode = local_findcol(raw, 'Electrode');

                    if size(raw, 1) == 2 % raw is juxta
                        % unit, LFP or any other channels than EEG

                        isnumericscalar = @(x)  isnumeric(x) && isscalar(x);
                        assert(  isnumericscalar(raw{2, col_electrode}), ...
                            eid('juxta:invalid'),...
                            'for juxta configuraiton, column %d must be all numeric scalar', col_electrode);
                        clear isnumericscalar

                        row = 2;
                        local_warnrow(row, 'juxta', i, j, TF, infofiles, chantitles, matnames);

                        S = local_assign_xyz(S, chantitles, j, raw, row); %TODO
                        S = local_assign_others(S, chantitles, j, probemode, raw, row);

                    elseif size(raw, 1) > 16
                        % raw is probe, but not probe channels: ex. stim, hum, etc

                        S = local_assign_xyz_null(S, chantitles, j);
                        S = local_assign_others_null(S, chantitles, j);

                    else % unknown data type of raw

                        warning off backtrance
                        warning(eid('raw:unknowndatatype'),...
                            'raw is in unknown format');
                        warning on backtrance

                        S = local_assign_xyz_null(S, chantitles, j);
                        S = local_assign_others_null(S, chantitles, j);

                    end
                end
            end


            %% save *_m.mat

            newfilename = regexprep(matfiles(i).name, '_sp.mat$', '_m.mat');

            outname = fullfile(destdir, newfilename);
            save(outname, '-struct', 'S');

            disp(outname);
            list(i) = {outname};

            % delete *_sp.mat file only if matdir equals to destdir
            if strcmp(matdir, destdir)
                delete(fullfile(matdir, matfiles(i).name));
            end


        elseif nnz(TF) > 1
            warning(eid('warning:toomanymatch'),...
                'more than one infonames matched matfile name %s.',  matnames{i});
        end
    end

end

if ~isempty(matfiles) && ~any([matfiles(:).OK])
   warning(eid('nomatfilesfound'),...
       'No *_sp.mat file to be processed was found.');
end


list(cellfun(@isempty, list)) = [];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [regexpr, targetfiles, dogui, destdir] = ...
    local_paramvalpair(regexpr, targetfiles, dogui, destdir, varargin)

ni = length(varargin); % ni >= 1
if ni >= 1 || ni <= 3

    i = 1;

    %% check if destdir is set

    if ischar(varargin{1}) && isrow(varargin{1}) && ...
            ~ismember(lower(varargin{1}), {'-regexp','-ismember', '-listdlg'})
        if isdir(varargin{i})
            destdir = varargin{i};
            i = 2;
        else
            error(eid('pvsetInvalid:destdir'),...
                'destdir must be a valid folder path')
        end
    end


    %% Set each Property Name/Value pair in turn.
    Property = varargin{i};
    if i+1>ni
        error(eid('pvsetInvalid'),...
            'Input argument numner is invalid.')
    else
        Value = varargin{i+1};
    end
    %% Perform assignment
    switch lower(Property)
        case '-regexp'
            %% Assign the value
            if ~isempty(Value) && (ischar(Value) && isrow(Value))
                % char row (string) is accepted
                regexpr = {Value};
            elseif ~isempty(Value) &&  iscellstr(Value) && iscolumn(Value)
                regexpr = Value;
            elseif ~isempty(Value) &&  iscellstr(Value) && isrow(Value)
                regexpr = Value';
            else
                error(eid('pvsetInvalid:regexp'), ...
                    'Value is invalid for regexp option.')
            end
        case '-ismember'
            %% Assign the value
            if ~isempty(Value) && (ischar(Value) && isrow(Value))
                % char row (string) is accepted
                targetfiles = {Value};
            elseif ~isempty(Value) &&  iscellstr(Value) && iscolumn(Value)
                targetfiles = Value;
            elseif ~isempty(Value) &&  iscellstr(Value) && isrow(Value)
                targetfiles = Value';
            elseif isempty(Value)
                targetfiles = {};
            else
                error(eid('pvsetInvalid:ismember'), ...
                    'Value is invalid for ismember option.')
            end
        case '-listdlg'
            %% Assign the value
            if ~isempty(Value) && islogical(Value) || Value == 0 || Value == 1
                dogui = Value;
            else
                error(eid('pvsetInvalid:listdlg'), ...
                    'Value is invalid for listdlg option.')
            end
        case {'regexp', 'ismember','listdlg'}
            error(eid('pvsetInvalid:Param:hyphen'), ...
                'Optinoal parameter must be either -regexp, -ismember. Hyphen is missing!')
        otherwise
            error(eid('pvsetInvalid:Param'), ...
                'Optinoal parameter must be either -regexp, OR -ismember.')
    end % switch
    clear i


elseif ni > 3
    error(eid('pvsetInvalid'), ...
        'Only one Property/Value pair is accepted');
else % ni == 0
    % no options, go with the default values

end



end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ind1, ind2] = local_checkMATandINFO(matnames, infonames, regexpr, targetfiles, dogui)
% [ind1, ind2] = local_checkMATandINFO(matnames, infonames)
% check if matfiles and infofiles both really exist by their names

expr1 = '^[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d\S*\.mat$';
wrnmsg1 = 'Some .mat files had unexpected file names:';
warnid1 = eid('warning:matnames');

ind1 = local_checkfilenames(matnames, expr1, wrnmsg1, warnid1);

if ~isempty(regexpr)
    indx = false(size(ind1));
    for i = 1:length(matnames)
        startIndex = regexp(matnames{i}, regexpr);
        indx(i) = any(cellfun(@(x) ~isempty(x), startIndex));
    end

    ind1 = ind1 & indx;

elseif ~isempty(targetfiles)

    indx = ismember(matnames,targetfiles);
    ind1 = ind1 & indx;

elseif dogui
    [Selection, ok] = listdlg('PromptString','Select files:',...
        'SelectionMode','multiple',...
        'ListString', matnames);

    if ok
        indx = false(size(ind1));
        indx(Selection') = true;
        ind1 = ind1 & indx;
    else
        error(eid('local_checkMATandINFO:canceled'),...
            'Canceled by user');
    end

end



expr2 = '^[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d\S*\_info\.xlsx$';
wrnmsg2 = 'Some .xlsx files had unexpected file names:';
warnid2 = eid('warning:infonames');

ind2 = local_checkfilenames(infonames, expr2, wrnmsg2, warnid2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filesStruct = local_add_shortname_OK_toStruct(filesStruct, names, expr, ind)

for i = 1:length(names)
    if ind(i)
        filesStruct(i).shortname = eval(expr);
        filesStruct(i).OK = true;
    else
        % default values
        filesStruct(i).shortname = '';
        filesStruct(i).OK = false;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ind = local_checkfilenames(names, expr, wrnmsg, warnid)
% ind = local_checkfilenames(names, expr, wrnmsg, warnid)
%
% output argument
% ind        logical index for valid names
%
% check the list of filenames, names in cell string, for expr with regexp
% function and return warning message if some file names violate the rule.


ind = regexp(names, expr);
ind = cellfun(@(x) ~isempty(x), ind);

if any(ind ~= 1)
    wrninfonames = names(ind == 0);

    for i = 1:length(wrninfonames)
        wrnmsg =  [wrnmsg, '\n', wrninfonames{i}];
    end
    clear i

    warning(warnid, wrnmsg);

end %tested 28/12/2013

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function thisAnimal = local_assertAnimalIdentity(raw, i, matnames)
col = local_findcol(raw, 'Animal');

thisAnimal = regexp( matnames{i}, ...
    '(^[a-zA-Z_]{3,5}\d\d\d)', 'tokens');
thisAnimal = char(thisAnimal{:});

assert(all(strcmpi(thisAnimal, raw(2:end, col))), ...
    eid('local_assertAnimalIdentity:animal:invalid'),...
    'Expected animal %s, but found wrong ones %s ', ...
    thisAnimal, raw{~strcmpi(thisAnimal, raw(:, col))});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function thisRecord = local_assertRecordIdentity(raw, i, matnames)

col = local_findcol(raw, 'Record');

thisRecord = regexp( matnames{i}, ...
    '(?:^[a-zA-Z_]{3,5}\d\d\d)([a-zA-Z]{1,2}\d\d)', 'tokens');
thisRecord = char(thisRecord{:});

assert(all(strcmpi(thisRecord, raw(2:end, col))), ...
    eid('record:invalid'),...
    'Expected record %s, but found %d/%d wrong ones  \n', ...
    thisRecord, ...
    nnz(~strcmpi(thisRecord, raw(2:end, col))), ...
    length(raw(2:end, col)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function row = local_getRow16x1(raw, col_electrode, chantitles, j)

assert( all(cellfun(@(x) isnumeric(x) && isscalar(x), raw(2:end, col_electrode))), ...
    eid('probe16x1:invalid'),...
    'for 16x1 probe configuraiton, column %d must be all numeric scalar', col_electrode);

contactN_chantitle = regexp(chantitles{j}, '(?:[A-B])(\d\d)', 'tokens');
contactN_chantitle = str2double(char(contactN_chantitle{:})); % recording contact number in the chantitle

assert( contactN_chantitle >= 1 && contactN_chantitle <= 16,...
    eid('probe16x1:contactN_chantitle:invalid'),...
    'for 16x1 probe configuraiton, contactN_chantitle must be 1 to 16, but it is %d', contactN_chantitle);

row = find(double(cellfun(@(x) isnumeric(x) && x == contactN_chantitle, raw(:, col_electrode))));

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function row = local_getRow16x2(raw, col_electrode, chantitles, j)

assert( all(cellfun(@(x) ischar(x) && ~isempty(regexp(x, '^[A-B]\d{1,2}', 'once')), raw(2:end, col_electrode))),...
    eid('probe16x2:invalid'),...
    'for 16x2 probe configuraiton, column %d must be all in the fomat such as A01 or B03', col_electrode);

probeID_chantitle = regexp(chantitles{j}, '([A-B])(?:\d\d)', 'tokens');
probeID_chantitle = char(probeID_chantitle{:}); % A or B

contactN_chantitle = regexp(chantitles{j}, '(?:[A-B])(\d\d)', 'tokens');
contactN_chantitle = str2double(char(contactN_chantitle{:})); % recording contact number in the chantitle

assert( contactN_chantitle >= 1 && contactN_chantitle <= 16,...
    eid('probe16x2:contactN_chantitle:invalid'),...
    'for 16x2 probe configuraiton, contactN_chantitle must be 1 to 16, but it is %d', contactN_chantitle);

row = find(cellfun(@(x) strcmp([probeID_chantitle, num2str(contactN_chantitle)], x), raw(:, col_electrode)));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function col = local_findcol(raw, str)


%% find the column which has the specified header

TF = strcmpi(str, raw(1,:));

if nnz(TF) == 1
    col = find(TF);
else
    col = [];
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function local_warnrow(row, str, i, j, TF, infofiles, chantitles, matnames)

if ~isscalar(row)
    % multiple hits
    warning(eid([str,':row:invalid1']),...
        'Only a single row in raw is expected to match');

elseif isempty(row)
    % no matching row
    warning(eid([str,':row:invalid2']),...
        'There is no matching data in the Excel file %s for channel %s in the mat file %s',...
        infofiles(TF).name, chantitles{j}, matnames{i});
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = local_assign_common(S, chantitles, j,...
    thisAnimal, thisRecord, thisDopamine, isinjection, injLocation)
% S = local_assign_common(S, chantitles, j, thisAnimal, thisRecord, ...
% thisDopamine, isinjection,injLocation)
%
% These fields will be added to the all the channels.
%
% See also
% local_assign_others, local_assign_others_null

S.(chantitles{j}).animal = thisAnimal;
S.(chantitles{j}).record = thisRecord;
S.(chantitles{j}).dopamine = thisDopamine;
S.(chantitles{j}).isinjection = isinjection;
S.(chantitles{j}).injLocation = injLocation;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = local_assign_xyz(S, chantitles, j, raw, row)
% S = local_assign_xyz(S, chantitles, j, raw, row)
%
% Applied to Probe channel, juxta channel.
% Also to EEG channel when isinjection is true.
%
% See also
% local_assign_others, local_assign_others_null


recX = raw{row, local_findcol(raw, 'recX')};
recY = raw{row, local_findcol(raw, 'recY')};
recZ = raw{row, local_findcol(raw, 'recZ')};
injX = raw{row, local_findcol(raw, 'injX')};
injY = raw{row, local_findcol(raw, 'injY')};
injZ = raw{row, local_findcol(raw, 'injZ')};

recX = validateXY(recX, 'recX');
recY = validateXY(recY, 'recY');
recZ =  validateZ(recZ, 'recZ');
injX = validateXY(injX, 'injX');
injY = validateXY(injY, 'injY');
injZ =  validateZ(injZ, 'injZ');

S.(chantitles{j}).xyzrec = [{recX}, {recY}, {recZ}]; % double, double, char
S.(chantitles{j}).xyzinj = [{injX}, {injY}, {injZ}]; % double, double, char


    function x = validateXY(x, str)

        assert( isscalar(x) && isnan(x) || isa(x, 'double'),...
            ['local_assign_xyz:', str ':invalid'],...
            [str, ' must be scalar double'])

        if isnan(x)
            x = [];
        end
    end

    function x = validateZ(x, str)

        assert((isscalar(x) && isnan(x) ) || isa(x, 'char') && isrow(x),...
            ['local_assign_xyz:', str ':invalid'],...
            [str, ' must be scalar double'])

        if isnan(x)
            x = '';
        end
    end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = local_assign_xyz_null(S, chantitles, j)
% S = local_assign_xyz_null(S, chantitles, j, raw, row)
%
% Applied to Probe channel, juxta channel.
% Also to EEG channel when isinjection is true.
%
% See also
% local_assign_others, local_assign_others_null

S.(chantitles{j}).xyzrec = [{[]}, {[]}, {''}]; % double, double, char
S.(chantitles{j}).xyzinj = [{[]}, {[]}, {''}]; % double, double, char


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = local_assign_others(S, chantitles, j, probemode, raw, row)
% S = local_assign_others(S, chantitles, j, probemode, raw, row)
%
% Applied to Probe channel, juxta channel
%
% See also
% local_assign_common, local_assign_others_null

S.(chantitles{j}).probemode = probemode;
S.(chantitles{j}).electrode = raw{row, local_findcol(raw, 'Electrode')};
S.(chantitles{j}).location = raw{row, local_findcol(raw, 'Location')};
S.(chantitles{j}).note_labeledcell = raw{row, local_findcol(raw, 'Note for Labeled Cell')};

if isempty(probemode) % "isidentified" is added only to juxta channels
    % (not to probe channels or EEG channels)
    % Although this will cause inconsistency as to existence of "isidentified" field,
    % I opted this in order to avoid unnecessarily updating large number of
    % probe data files

    isidentified = raw{row, local_findcol(raw, 'Identified')};
    if isnan(isidentified)
        isidentified = false;
    elseif isidentified == 1 || isidentified == 0
        isidentified = logical(isidentified);
    else
        error('K:K_importExcelData2structSpike2:local_assign_others',...
            'unexecpted value for isidentified');
    end
    S.(chantitles{j}).isidentified = isidentified;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function S = local_assign_others_null(S, chantitles, j)
% S = local_assign_others_null(S, chantitles, j)
%
% Applied to EEG channels or channels of unknown type
%
% See also
% local_assign_common, local_assign_others

S.(chantitles{j}).probemode = '';
S.(chantitles{j}).electrode = [];
S.(chantitles{j}).location = '';
S.(chantitles{j}).note_labeledcell = '';

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K:
%
% input argument
% str        (Optional) string in char type (row vector)
%
% output argument
% eid         an error id composed of 'K:(functionname):str'

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
