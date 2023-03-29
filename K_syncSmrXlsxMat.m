function [Sbef, Saft] = K_syncSmrXlsxMat(smrdir, matdir, excelmasterpath)
% [Sbef, Saft] = K_syncSmrXlsxMat(smrdir, matdir, excelmasterpath)
%
% K_syncSmrXlsxMat compares the file names and last modified dates in
% smrdir and matdir and make sure all the *.smr files and *_info.xlsx files
% are successfully converted to *_m.mat files. This is the key function for
% syncing these data files.
%
% 1. In this workflow, *.smr files in smrdir folder are exported into
% *.mat files and *_mk_mat files by ExportAsMat.s2s.
%
% 2. Subsequently K_folder_mat2sparse convert *.mat files and *_mk_mat
% files into *_sp.mat files in which event channels are compressed in
% sparse double format and channumber field is added to each channel.
%
% 3. Then, K_extractExcelDataForSpike2 will extract additional channel
% information such as anatomical location and store them in *_info.xlsx
% files in matdir.
%
% 4. Those data in *_info.xlsx files are merged with *_sp.mat files and
% imported into *_m.mat files by K_importExcelData2structSpike2. *_m.mat
% files are ready for analyses.
%
% INPUT ARGUMENTS
%
% smrdir      Directory path for *.smr files
%
% matdir      Directory path for *m.mat files. This folder can also contain
%               *m.mat files, *_mk_mat files, *_sp.mat files,
%               *_info.xlsx files.
%
% excelmasterpath
%               The full file path for the master Excel file that contains
%               extra information about each channel of recordings.
%
% OUTPUT ARGUMENTS
%
% Sbef, Saft    Structures in the same format. Sbef contains the file
%               status before the operation and Saft contains that after
%               the operation. The contents of Sbef and Saft is based
%               on K_checkmerge. If the syncing is successful, the first
%               five fields ( smr_updateMat, smr_addXlsxupdateMat,
%               smr_addMat, xlsx_rmXlsx, mat_rmMat ) of Saft that
%               contain the names of files that require a specific action
%               for syncing should be all empty, while other fields are
%               not.
%
% EXAMPLE
%
%   smrdir = 'Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus\probe\SUA\act\smr';
%   matdir = 'Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus\probe\SUA\act\mat';
%   excelmasterpath = 'Z:\Dropbox\Private_Dropbox\DATA_dropbox\kjx data summary.xlsx';
%
%   [Sbef, Saft] = K_syncSmrXlsxMat(smrdir, matdir, excelmasterpath)
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 24-Jul-2017 17:21:41
%
% See also
% K_checkmerge, K_folder_mat2sparse, K_extractExcelDataForSpike2,
% K_syncSmrXlsxMatloop, K_importExcelData2structSpike2, ExportAsMat.s2s
% sync


%% need to check the content of all the existing _info.xlsx files first

xlsxlist = dir(fullfile(matdir, '*_info.xlsx'));
xlsxnames = {xlsxlist(:).name}';

animalrecord2 = local_names2animalrecordplus(xlsxnames);
list0b = local_addExcelFilesinMatdirplus(animalrecord2,...
    matdir, excelmasterpath);

clear xlsxlist xlsxnames animalrecord2


%% Code begins here

S = K_checkmerge(smrdir, '*.smr', matdir, '*_info.xlsx', matdir, '*_m.mat'); 
% check if source and final destination are synced
disp(S)


%% list of short filenames that lack chan number data

smrchannumbad = local_checkchannumber(matdir, smrdir);


%% Add Excel files in Destination folder

if ~isempty(S.smr_addXlsxupdateMat)

    animalrecord1 = local_names2animalrecordplus(S.smr_addXlsxupdateMat);
    list0a = local_addExcelFilesinMatdirplus(animalrecord1, matdir, excelmasterpath);

end


%% then Update or Add *.mat and *_mk.mat files in Destination folder

S1 = K_getupdated(smrdir, '*.smr', matdir, '*.mat|*_m.mat|*_mk.mat|*_sp.mat');

datetime1 = datestr(now, '_yyyy-mm-dd_HHMMSS');
dirstr =  ['srcdir=%s\n', 'destdir=%s']; % these names are important for ExpoatAsMat to recognize the values

tobeupdated_S = union(S.smr_updateMat, union(S.smr_addXlsxupdateMat, S.smr_addMat));

tobeupdated1 = intersect(tobeupdated_S, union(S1.src_addDest, S1.src_updateDest));
tobeupdated1 = union(smrchannumbad, tobeupdated1); % include those without channumber value

msg = sprintf(['The files in the folder "srcdir" whose corresponding files in the folder "destdir" need to be updated.\n', ...
    dirstr], smrdir, matdir);
txtname = ['updateMat',datetime1,'.txt'];
fsave_getupdatedf(tobeupdated1, smrdir, smrdir, txtname, msg);

%% Run ExportAsMat.s2s in Spike2 with the text file "updateDest_*"

if ~isempty(tobeupdated1)

    clipboard('copy', smrdir);
    msg = sprintf(['\nYou need to export .mat files from %d Spike2 files in the smrdir folder below. ',...
        'Now, run "ExportAsMat.s2s" in Spike2, press the button "4. Batch Update .mat". ', ...
        'In the file open dialog that appears after your click, ',...
        'move to the smrdir folder ',...
        'by pasting the folder path below (the path is now in the system clipboard) ',...
        'into the Address Bar at the top. ',...
        'Then select the text file "%s." ',...
        '\n\n%s\n\n'],...
        length(tobeupdated1), txtname, regexprep(smrdir,'\\','\\\\'));
        %NOTE input() requires escaping \


    if inputYN([msg,...
            'Type "Y" if you have run "ExportAsMat.s2s" and want to proceed. Type "N" if you want to abort. [Y/N]:'])
        % proceed
    else
        disp('Cancelled by user')
        return
    end
    
    local_rename32mat(matdir);    
end

%% Update or Add *_sp.mat files in Destination folder

S2 = K_getupdated(matdir, '*.mat|*_m.mat|*_mk.mat|*_sp.mat', matdir, '*_sp.mat');

tobeupdated2 = intersect(regexprep(tobeupdated_S, '.smr','.mat'), ...
    union(S2.src_addDest, S2.src_updateDest));

%NOTE tobeupdated2 needs to include *_mk.mat files as well if they
% coexist with *.mat files

TFmkexist = logical(cellfun(@(x) exist(x,'file'),fullfile(matdir,...
    regexprep(tobeupdated2,'.mat$','_mk.mat'))));

mknames = regexprep(tobeupdated2,'.mat$','_mk.mat');

tobeupdated2_ = [tobeupdated2; mknames(TFmkexist)];

list1 = K_folder_mat2sparse(matdir, tobeupdated2_, matdir, '*_sp.mat');


%% Update or Add *_m.mat files in Destination folder

S3 = K_getupdated(matdir, '*_sp.mat', matdir, '*_m.mat');

tobeupdated3 = intersect(regexprep(tobeupdated_S, '.smr','_sp.mat'), ...
    union(S3.src_addDest, S3.src_updateDest));

list2 = K_importExcelData2structSpike2(matdir, '-ismember', tobeupdated3); 


%% Delete files from Source2 == Destination folder
tobedeleted_matdir1 = cellfun(@(x) fullfile(matdir, x), S.xlsx_rmXlsx, 'UniformOutput', false);

if ~isempty(tobedeleted_matdir1)
    delete(tobedeleted_matdir1{:});
end


%% Delete files from Destination folder
tobedeleted_matdir2 = cellfun(@(x) fullfile(matdir, x), S.mat_rmMat, 'UniformOutput', false);
if ~isempty(tobedeleted_matdir2)
    delete(tobedeleted_matdir2{:});
end

Sbef = S;
Saft = K_checkmerge(smrdir, '*.smr', matdir, '*_info.xlsx', matdir, '*_m.mat');


%% Delete orphan files from the Destination folder
recycle('on'); % in case you want to undo from Bin

existingsmr = dir(fullfile(smrdir, '*.smr'));
existingsmrname = {existingsmr(:).name}';
stem1 = cellfun(@(x) regexprep(x, '.smr$', ''), existingsmrname, 'UniformOutput', false);

local_delorphans(stem1, matdir, '_m.mat', '_m.mat$');

% for these intermediate file with the suffixes syou should delete them all
local_delwithregexp(matdir, '(?<!_mk|_sp|_m).mat$'); % *.mat, but not *_mk.mat, *_sp.mat, *_m.mat
local_delwithregexp(matdir, '(_mk|_sp).mat$'); % *_mk.mat, *_sp.mat
local_delwithregexp(matdir, '_chanMAT.txt$'); % *_chanMAT.txt


%NOTE special stem is required for _info.xlsx

stem2 = cellfun(@(x) x{1}, ...
    regexp(stem1, '^[a-zA-Z_-]{3,6}\d{1,3}[a-zA-Z]{1,2}\d+(\w*(?=@)|.+$)', 'match'),...
    'UniformOutput', false);

local_delorphans(stem2, matdir, '_info.xlsx', '_info.xlsx$');

recycle('off');

end

%--------------------------------------------------------------------------

function animalrecord = local_names2animalrecord(names)
% getfilenames2animals_records()
% animal ID and record ID

animalrecord = regexp(names, '^[a-zA-Z-]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d', 'match');

% handle the case in which no match returned
notempty = cellfun(@(y) ~isempty(y), animalrecord);

animalrecord(~notempty) = []; % delete empty cells

animalrecord = cellfun(@(x) x{1}, ...
    animalrecord, ...
    'UniformOutput', false);


end

%--------------------------------------------------------------------------

function animalrecord = local_names2animalrecordplus(names)
% getfilenames2animals_records()
% animal ID and record ID + trailing identifiers (big,  small etc)

animalrecord = regexp(names,'^[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d\w*(?=(@|\.|$))','match');

% handle the case in which no match returned
notempty = cellfun(@(y) ~isempty(y), animalrecord);

animalrecord(~notempty) = []; % delete empty cells

animalrecord = cellfun(@(x) x{1}, ...
    animalrecord, ...
    'UniformOutput', false);


end

%--------------------------------------------------------------------------

function list0 = local_addExcelFilesinMatdir(animalrecord, matdir, excelmasterpath)
% getfilenames2animals_records()

expr_animalrecord = strjoin(animalrecord', '|');

if ~isempty(expr_animalrecord)

    [list0, skipped0] = K_extractExcelDataForSpike2(excelmasterpath, matdir, expr_animalrecord); % DONE

    iswarned = false(length(animalrecord),1);
    for i = 1:length(animalrecord)
        TF1 = ismatchedany(list0, animalrecord{i});

        TF2 = ismatchedany(skipped0, animalrecord{i});

        if (isempty(TF1) || ~TF1)  && (isempty(TF2) || ~TF2)
            warning off backtrace
            warning('K:K_syncSmrXlsxMat:local_addExcelFilesinMatdir',...
                '*_info.xlsx (Excel) files were not successfully prepared for %s.\n', animalrecord{i});
            warning on backtrace
            iswarned(i) = true;

        end

    end

    if iswarned
       error('K:K_syncSmrXlsxMat:local_addExcelFilesinMatdir:ExcelFailure',...
           '*_info.xlsx (Excel) file(s) were not successfully prepared.')
    end

else

    list0 = {};
    skipped0 = {};

end

end

%--------------------------------------------------------------------------

function list0 = local_addExcelFilesinMatdirplus(animalrecordplus, matdir, excelmasterpath)
% getfilenames2animals_records()

animalrecord = cellfun(@(x) x{1}, regexp(animalrecordplus,...
    '^[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d', 'match'),...
    'UniformOutput',false);

namestem = cellfun(@(x) x{1}, regexp(animalrecordplus,...
    '^.*(?=@)|^.*(?=_info)|^.*(?=\.)|^.*$', 'match'),...
    'UniformOutput',false); %NOTE this bloody took 2 hrs
%NOTE Look ahead for either @, _info, ., or end of the string($).

if ~isempty(animalrecord) && ~isempty(namestem)

    [list0, skipped0] = K_extractExcelDataForSpike2(excelmasterpath, matdir, ...
        animalrecord,namestem);

    iswarned = false(length(animalrecordplus),1);
    for i = 1:length(animalrecordplus)
        TF1 = ismatchedany(list0, animalrecordplus{i});

        TF2 = ismatchedany(skipped0, animalrecordplus{i});

        if (isempty(TF1) || ~TF1)  && (isempty(TF2) || ~TF2)
            warning off backtrace
            warning('K:K_syncSmrXlsxMat:local_addExcelFilesinMatdir',...
                '*_info.xlsx (Excel) files were not successfully prepared for %s.\n', animalrecordplus{i});
            warning on backtrace
            iswarned(i) = true;

        end

    end

    if iswarned
       error('K:K_syncSmrXlsxMat:local_addExcelFilesinMatdir:ExcelFailure',...
           '*_info.xlsx (Excel) file(s) were not successfully prepared.')
    end

else

    list0 = {};
    skipped0 = {};

end

end

%--------------------------------------------------------------------------

function smrchannumbad = local_checkchannumber(matdir, smrdir)

[smrshortnames, smrfull] = pvt_getAnimalRecordDatanum(smrdir, '*.smr');

[dnames, dnamesfull] = pvt_getAnimalRecordDatanum(matdir, '*_m.mat');

isrecordOK = false(size(dnamesfull));
for i = 1:length(dnamesfull)
    S = load(dnamesfull{i});
    channames = fieldnames(S);
    ischannumOK = false(size(channames));

    for j = 1:length(channames)
        if isfield( S.(channames{j}), 'channumber')
            if S.(channames{j}).channumber ~= 0
                ischannumOK(j) = true;
            end
        end
    end

    if all(ischannumOK)
        isrecordOK(i) = true;
    end
end

channumbad = dnames(~isrecordOK);

[~,~, ib] = intersect(channumbad, smrshortnames); % exclude if the corresponding .smr file does not exist

smrchannumbadfull = smrfull(ib);

smrchannumbad  = cellfun(@(x) strrep(x, [smrdir, filesep], ''), smrchannumbadfull, 'UniformOutput', false);

end

%--------------------------------------------------------------------------

function local_delorphans(stem, matdir, suffix, regexpr)
% local_delorphans(stem, matdir, suffix, regexpr)
%
% This function searches files whose names end with "suffix" in "matdir"
% and delete them if they are not derivative of file names listed in
% "stem". This way the orpthan files with "suffix" in "matdir" whose
% corresponding .smr files are absent will be deleted.
%
% INPUT ARGUMENTS
% stem      Stem of file names
% matdir    Directory that contains .mat files
% suffix    Suffix that is to be appended to stem
% regexpr   Regular expression for matching.
%
% EXMAPLE
% local_delorphans(matdir, '.mat', '(?<!_mk|_sp|_m).mat$')


allowed = cellfun(@(x) strcat(x, suffix), stem, 'UniformOutput', false);

allfiles = dir(matdir);
allfilenames = {allfiles(:).name}';
startInd = regexp(allfilenames, regexpr); % cell column vector containing row vectors of start indices for each element of allfilenames
ismatched = cellfun(@(x) ~isempty(x), startInd); % row vector of logicals
found = allfilenames(ismatched); % regexp was used because dir cannot handle negation such as '(?<!_mk|_sp|_m).mat$'

orphans = setdiff(found, allowed);
if ~isempty(orphans)
    for i = 1:length(orphans)
        delete(fullfile(matdir, orphans{i}));
        fprintf('deleted %s\n', fullfile(matdir, orphans{i}));
    end
end

end

%--------------------------------------------------------------------------

function local_delwithregexp(matdir, regexpr)
% local_delwithregexp(matdir, regexpr)
%
% This function searches files whose names match "regexpr" in "matdir"
% and delete them all.
%
% INPUT ARGUMENTS
% matdir    Directory that contains .mat files
% regexpr   Regular expression for matching.


allfiles = dir(matdir);
allfilenames = {allfiles(:).name}';
startInd = regexp(allfilenames, regexpr); % cell column vector containing row vectors of start indices for each element of allfilenames
ismatched = cellfun(@(x) ~isempty(x), startInd); % row vector of logicals
found = allfilenames(ismatched); % regexp was used because dir cannot handle negation such as '(?<!_mk|_sp|_m).mat$'

if ~isempty(found)
    for i = 1:length(found)
        delete(fullfile(matdir, found{i}));
        fprintf('deleted %s\n', fullfile(matdir, found{i}));
    end
end

end

%--------------------------------------------------------------------------

function local_rename32mat(matdir)
% Version 8 Spike2 add [32-bit] suffix to the exported .mat files
% This local function gets rid of that suffix.

listmat = dir(fullfile(matdir,'*.mat'));
newmatnames = {listmat(:).name}';

newmatnames32bit = newmatnames(ismatched(newmatnames,'\[32-bit\]\.mat$'));

newmatnamesCorrected = regexprep(newmatnames32bit,'\[32-bit\]\.mat$','.mat');
k = length(newmatnames32bit);

for l = 1:k
    movefile(fullfile(matdir,newmatnames32bit{l}),...
        fullfile(matdir,newmatnamesCorrected{l}));

end

matrenamed = [newmatnames32bit;newmatnamesCorrected];

v = [1:k;...
    k+1:2*k];

fprintf('''%s'' has been renamed as ''%s''\n',matrenamed{v(:)})



listtxt = dir(fullfile(matdir,'*_chanMAT.txt'));
newtxtnames = {listtxt(:).name}';

newtxtnames32bit = newtxtnames(ismatched(newtxtnames,'\[32-bit\]_chanMAT\.txt$'));

newtxtnamesCorrected = regexprep(newtxtnames32bit,'\[32-bit\]_chanMAT\.txt$','.mat');
k = length(newtxtnames32bit);

for l = 1:k
    movefile(fullfile(matdir,newtxtnames32bit{l}),...
        fullfile(matdir,newtxtnamesCorrected{l}));

end

txtrenamed = [newtxtnames32bit;newtxtnamesCorrected];

v = [1:k;...
    k+1:2*k];

fprintf('''%s'' has been renamed as ''%s''\n',txtrenamed{v(:)})


    
end
