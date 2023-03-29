function S = K_checkmerge(smrdir, smraffix, xlsxdir, xlsxaffix, matdir, mataffix)
% S = K_checkmerge(smrdir, smraffix, xlsxdir, xlsxaffix, matdir, mataffix)
%
% This function is very similar to K_getupdatedmerge but this is
% specifically designed for the special work flow for *.smr, *_info.xlsx
% and *_m.mat files.
%
% INPUT ARGUMENTS
% smrdir   a valid folder path for the "source" .smr files from which the
%           "destination" .mat files are derived. The files in this folder
%           has more previledge over other two folders: The existance of an
%           extra file in this folder means addition of the corresponding
%           files are required for the other tho folders. The absence of a
%           file in this folder compared to the other two folders means the
%           corresponding files need to be deleted from the other tho
%           folders.
%
% smraffix  a string (char tyipe) for file name prefix and/or suffix
%           and a wildcard(*) that are common to the "source" files.
%           Multiple wildcard characters are not accepted. The "source"
%           file anmes and "destination" file names must be identical
%           except those affixes. In other words, the wildcards represent
%           the identical part of the file names for the two folders.
%
% xlsxdir   a valid folder path for the "source" .smr files from which the
%           "destination" .mat files are derived.
%
% xlsxaffix The same as smraffix but for xlsxdir
%
% matdir   a valid folder path for the "destination" .mat files that are derived
%           from the "source" .smr files
%
% mataffix The same as smraffix but for xlsxdir
%
%
% OUTPUT ARGUMENTS
% S         A structure.
%
%   S.smr_updateMat
%             This holds the names of the "Spike2" .smr files whose
%             corresponding "destination" .mat files need to be updated in the
%             "destination" folder matdir.
%
%   S.smr_addXlsxupdateMat
%             This holds the names of the "Spike2" files whose
%             corresponding "Excel" .xlsx files need to be added in the
%             "Excel" folder xlsxdir, and then the corresponding files
%             need to be updated in the "destination" folder matdir.
%
%   S.smr_addMat
%             This holds the names of files that needs to be added in the
%             "destination" folder matdir.
%
%   S.xlsx_rmXlsx
%             This holds the names of files that needs to be deleted in the
%             "Excel" folder xlsxdir.
%
%   S.mat_rmMat
%             This holds the names of files that needs to be deleted in the
%             "destination" folder matdir.
%
%   S.smr      Equals to smrdir
%   S.xlsx     Equals to xlsxdir
%   S.mat      Equals to matdir
%
%
%   S.smr_all  Names of all the relevent files in the Spike2 directory.
%
%   S.xlsx_all Names of all the relevent files in the xlsxdir directory.
%
%   S.mat_all  Names of all the relevent files in the Destintion directory.
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 24-Jul-2017 17:30:37
%
% See also
% K_getupdated, K_getupdatedf, K_getupdatedmerge
% pvt_getListAgainstRefnames, pvt_getupdated_initS, pvt_getfilenameswithoutaffix

%% Parser

narginchk(6,6);
p= inputParser;
vfdir = @(x) isrow(x) && ischar(x) && isdir(x);
vfa = @(x) ischar(x) && isempty(x) || isrow(x) && ~contains(x, filesep) ...
    && ~contains(x, '*') || length(strfind(x, '*')) <= length(strfind(x, '|')) + 1; % only accept one wild card per affix
p.addRequired('smrdir', vfdir);
p.addRequired('smraffix', vfa);
p.addRequired('xlsxdir', vfdir);
p.addRequired('xlsxaffix', vfa);
p.addRequired('matdir', vfdir);
p.addRequired('mataffix', vfa);

p.parse(smrdir, smraffix, xlsxdir, xlsxaffix,  matdir, mataffix);

%% Job

[s1names, s1namesfull, s1datenum] = pvt_getAnimalRecordDatanum(smrdir, smraffix);   %NOTE Include 'big' or 'small' etc
[s2names, s2namesfull, s2datenum] = pvt_getAnimalRecordDatanum(xlsxdir, xlsxaffix);
[dnames, dnamesfull, ddatenum]    = pvt_getAnimalRecordDatanum(matdir, mataffix);

%% Prepare seven cases by comparing sets of names without affix
%NOTE "I" stands for intersection

s1Id    = intersect(s1names, dnames);
s2Id    = intersect(s2names, dnames);
s1Is2   = intersect(s1names, s2names);

% intersecton of three groups
s1Is2Id = intersect(s1Is2, dnames);       % 1: for datanum comparison


s1Id__s1Is2Id  = setdiff(s1Id, s1Is2Id);  % 2: add to s2 and then update d
%NOTE "__" stands for set difference

s2Id__s1Is2Id  = setdiff(s2Id, s1Is2Id);  % 3: removal from both s2 and d

s1Is2__s1Is2Id = setdiff(s1Is2, s1Is2Id); % 4: add to d

s1only         = setdiff(setdiff(s1names, dnames), s2names); % 5: add to s2 and then update d

s2only         = setdiff(setdiff(s2names, dnames), s1names); % 6: removal from s2

donly          = setdiff(setdiff(dnames, s1names), s2names); % 7: removal from d

%% Handle each case separately

S.smr_updateMat        = local_updateMat(s1Is2Id, s1names, s2names, ...
    dnames, s1datenum, s2datenum, ddatenum, s1namesfull);

S.smr_addXlsxupdateMat = local_addXlsxupdateMat(s1Id__s1Is2Id, ...
    s1names, s1only, s1namesfull);

S.smr_addMat  = local_addMat(s1Is2__s1Is2Id, s1names, s1namesfull);

S.xlsx_rmXlsx = local_removalFromS2(s2Id__s1Is2Id, s2only, s2names, s2namesfull);

S.mat_rmMat   = local_removalFromD(s2Id__s1Is2Id, donly, dnames, dnamesfull);

S.smr  = smrdir;
S.xlsx = xlsxdir;
S.mat  = matdir;

S.smr_all  = local_fullpaths2paths(s1namesfull);
S.xlsx_all = local_fullpaths2paths(s2namesfull);
S.mat_all  = local_fullpaths2paths(dnamesfull);


%% Assertion

local_assert(S);


end

%--------------------------------------------------------------------------------

function names = local_fullpaths2paths(fullnames)

narginchk(1,1);
p = inputParser;
vf = @(x) iscellstr(x) && isvector(x);
p.addRequired('fullnames', vf);


names = cell(size(fullnames));
for i = 1:length(fullnames)
   [~, name, ext] = fileparts(fullnames{i});
   names{i} = [name, ext];
end

end

%--------------------------------------------------------------------------------

function smr_updateMat = local_updateMat(s1Is2Id, s1names, s2names, ...
    dnames, s1datenum, s2datenum, ddatenum, s1namesfull)

[~, ind_s1] = ismember(s1Is2Id, s1names);
[~, ind_s2] = ismember(s1Is2Id, s2names);
[~, ind_d]  = ismember(s1Is2Id, dnames);

s1datenum_s1Is2Id = s1datenum(ind_s1);
s2datenum_s1Is2Id = s2datenum(ind_s2);
ddatenum_s1Is2Id  = ddatenum(ind_d);

istobeupdated1 = s1datenum_s1Is2Id > ddatenum_s1Is2Id;
istobeupdated2 = s2datenum_s1Is2Id > ddatenum_s1Is2Id;

istobeupdated = istobeupdated1 | istobeupdated2; % logical index OR operation

tobeupdated = s1Is2Id(istobeupdated);


smr_updateMat = {};

smr_updateMat = pvt_getListAgainstRefnames(tobeupdated, s1names, s1namesfull, smr_updateMat);

end

%--------------------------------------------------------------------------------
function smr_addXlsxupdateMat = local_addXlsxupdateMat(s1Id__s1Is2Id, ...
    s1names, s1only, s1namesfull)

% Add to xlsxdir and then update Matinaiton
smr_addXlsxupdateMat = {};

smr_addXlsxupdateMat = pvt_getListAgainstRefnames(s1Id__s1Is2Id, s1names, s1namesfull, smr_addXlsxupdateMat);

smr_addXlsxupdateMat = pvt_getListAgainstRefnames(s1only, s1names, s1namesfull, smr_addXlsxupdateMat);



end

%--------------------------------------------------------------------------------
function smr_addMat = local_addMat(s1Is2__s1Is2Id, s1names, s1namesfull)

% Add to Destination
smr_addMat = {};

smr_addMat = pvt_getListAgainstRefnames(s1Is2__s1Is2Id, s1names, s1namesfull, smr_addMat);


end

%--------------------------------------------------------------------------------


function [xlsx_rmXlsx] = local_removalFromS2(s2Id__s1Is2Id,...
    s2only, s2names, s2namesfull)

% Removal from xlsxdir
xlsx_rmXlsx = {};

xlsx_rmXlsx = pvt_getListAgainstRefnames(s2only, s2names, s2namesfull, xlsx_rmXlsx);

xlsx_rmXlsx = pvt_getListAgainstRefnames(s2Id__s1Is2Id, s2names, s2namesfull, xlsx_rmXlsx);


end

%--------------------------------------------------------------------------------

function [mat_rmMat] = local_removalFromD(s2Id__s1Is2Id,...
    donly, dnames, dnamesfull)

% Removal from destination
mat_rmMat = {};

mat_rmMat = pvt_getListAgainstRefnames(donly, dnames, dnamesfull, mat_rmMat);

mat_rmMat = pvt_getListAgainstRefnames(s2Id__s1Is2Id, dnames, dnamesfull, mat_rmMat);

end

%--------------------------------------------------------------------------------

function local_assert(S)

% when the number of files in three folders are different, you have to do
% somthing about it

if length(S.smr_all) ~= length(S.xlsx_all)...
        || length(S.xlsx_all) ~= length(S.mat_all)...
        || length(S.smr_all) ~= length(S.mat_all)

   if isempty(S.smr_updateMat) && isempty(S.smr_addXlsxupdateMat) ...
           && isempty(S.smr_addMat) && isempty(S.xlsx_rmXlsx) && isempty(S.mat_rmMat)


       fprintf('smr, %d; xlsx, %d; mat, %d\n',...
           length(S.smr_all), length(S.xlsx_all), length(S.mat_all))

       smr_all = regexprep(S.smr_all,'@.+$','')
       mat_all = regexprep(S.mat_all,'@.+$','')
       xlsx_all = regexprep(S.xlsx_all,'_info.xlsx$','')
       smr_all_ = regexprep(S.smr_all,'\.smr$','')
       mat_all_ = regexprep(S.mat_all,'_m\.mat','')

       G = {smr_all,mat_all,xlsx_all,smr_all_,mat_all_};


       error(['Although the numbers of files in the three folders are different ',...
           '(smr_all, %d; xlsx_all, %d; mat_all, %d), ',...
           'none of the files are to be processed in any way.'],...
           length(S.smr_all),length(S.xlsx_all),length(S.mat_all));
   end


end

end
