function S = K_getupdatedmerge(src1dir, src1affix, src2dir, src2affix, destdir, destaffix)
% S = K_getupdatedmerge(src1dir, src1affix, src2dir, src2affix, destdir, destaffix)
%
% Check the file status of files in 3 folders, src1dir, src2dir, and destdir.
% Returns which files need to be updated or deleted.
%
% for specialized use for Spike2 *.smr, Excel *_info.xlsx, and MATLAB *.mat,
% see K_checkmerge
%
% for comparison of 2 folders, see K_getupdated
%
% INPUT ARGUMENTS
% src1dir   a valid folder path for the "source" files from which the
%           "destination" files are derived. The files in this folder has
%           more previledge over other two folders: The existance of an
%           extra file in this folder means addition of the corresponding
%           files are required for the other tho folders. The absence of a
%           file in this folder compared to the other two folders means the
%           corresponding files need to be deleted from the other tho
%           folders.
%
% src1affix  a string (char tyipe) for file name prefix and/or suffix
%           and a wildcard(*) that are common to the "source" files.
%           Multiple wildcard characters are not accepted. The "source"
%           file anmes and "destination" file names must be identical
%           except those affixes. In other words, the wildcards represent
%           the identical part of the file names for the two folders.
%
% src2dir   a valid folder path for the "source" files from which the
%           "destination" files are derived.
%
% src2affix The same as src1affix but for src2dir
%
% destdir   a valid folder path for the "destination" files that are derived
%           from the "source" files
%
% destaffix The same as src1affix but for src2dir
%
%
% OUTPUT ARGUMENTS
% S         A structure.
%
% S.src1_updateDest
%             This holds the names of the "source1" files whose
%             corresponding "destination" files need to be updated in the
%             "destination" folder destdir.
%
% S.src1_addSrc2updateDest
%             This holds the names of the "source1" files whose
%             corresponding "source2" files need to be added in the
%             "source2"  folder src2dir, and then the corresponding files
%             need to be updated in the "destination" folder destdir.
%
% S.src1_addDest
%             This holds the names of files that needs to be added in the
%             "destination" folder destdir.
%
% S.src2_rmSrc2
%             This holds the names of files that needs to be deleted in the
%             "source2" folder src2dir.
%
% S.dest_rmDest
%             This holds the names of files that needs to be deleted in the
%             "destination" folder destdir.
%
% S.src1      Equals to src1dir
% S.src2      Equals to src2dir
% S.dest      Equals to destdir
%
%
% S.src1_all  Names of all the relevent files in the Source1 directory.
%
% S.src2_all  Names of all the relevent files in the Source2 directory.
%
% S.dest_all  Names of all the relevent files in the Destintion directory.
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 24-Jul-2017 17:30:37
%
% See also
% K_getupdated, K_getupdatedf, K_checkmerge
% pvt_getListAgainstRefnames, pvt_getupdated_initS, pvt_getfilenameswithoutaffix

%% Parser

narginchk(6,6);
p= inputParser;
vfdir = @(x) isrow(x) && ischar(x) && isdir(x);
vfa = @(x) ischar(x) && isempty(x) || isrow(x) && isempty(strfind(x, filesep)) ...
    && isempty(strfind(x, '*')) || length(strfind(x, '*')) <= length(strfind(x, '|')) + 1; % only accept one wild card per affix
p.addRequired('src1dir', vfdir);
p.addRequired('src1affix', vfa);
p.addRequired('src2dir', vfdir);
p.addRequired('src2affix', vfa);
p.addRequired('destdir', vfdir);
p.addRequired('destaffix', vfa);

p.parse(src1dir, src1affix, src2dir, src2affix,  destdir, destaffix);

%% Job

[s1names, s1namesfull, s1datenum] = pvt_getNamesDatanum(src1dir, src1affix);
[s2names, s2namesfull, s2datenum] = pvt_getNamesDatanum(src2dir, src2affix);
[dnames, dnamesfull, ddatenum] = pvt_getNamesDatanum(destdir, destaffix);


%% Prepare seven cases by comparing sets of names without affix

s1Id = intersect(s1names, dnames); % I stands for intersection
s2Id = intersect(s2names, dnames);
s1Is2 = intersect(s1names, s2names);

s1Is2Id = intersect(s1Is2, dnames); % 1: for datanum comparison

s1Id__s1Is2Id = setdiff(s1Id, s1Is2Id); % 2: add to s2 and then update d
% __ stands for set difference

s2Id__s1Is2Id = setdiff(s2Id, s1Is2Id); % 3: removal from both s2 and d

s1Is2__s1Is2Id = setdiff(s1Is2, s1Is2Id); % 4: add to d

s1only = setdiff(setdiff(s1names, dnames), s2names); % 5: add to s2 and then update d

s2only = setdiff(setdiff(s2names, dnames), s1names); % 6: removal from s2

donly = setdiff(setdiff(dnames, s1names), s2names); % 7: removal from d

%% Handle each case separately

S.src1_updateDest = local_updateDest(s1Is2Id, s1names, s2names, ...
    dnames, s1datenum, s2datenum, ddatenum, s1namesfull);

S.src1_addSrc2updateDest = local_addSrc2updateDest(s1Id__s1Is2Id, ...
    s1names, s1only, s1namesfull);

S.src1_addDest = local_addDest(s1Is2__s1Is2Id, s1names, s1namesfull);

S.src2_rmSrc2 = local_removalFromS2(s2Id__s1Is2Id, s2only, s2names, s2namesfull);

S.dest_rmDest = local_removalFromD(s2Id__s1Is2Id, donly, dnames, dnamesfull);

S.src1 = src1dir;
S.src2 = src2dir;
S.dest = destdir;

S.src1_all = local_fullpaths2paths(s1namesfull);
S.src2_all = local_fullpaths2paths(s2namesfull);
S.dest_all = local_fullpaths2paths(dnamesfull);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function src1_updateDest = local_updateDest(s1Is2Id, s1names, s2names, ...
    dnames, s1datenum, s2datenum, ddatenum, s1namesfull)

[~, ind_s1]= ismember(s1Is2Id, s1names);
[~, ind_s2]= ismember(s1Is2Id, s2names);
[~, ind_d]= ismember(s1Is2Id, dnames);

s1datenum_s1Is2Id= s1datenum(ind_s1);
s2datenum_s1Is2Id= s2datenum(ind_s2);
ddatenum_s1Is2Id= ddatenum(ind_d);

istobeupdated1 = s1datenum_s1Is2Id > ddatenum_s1Is2Id;
istobeupdated2 = s2datenum_s1Is2Id > ddatenum_s1Is2Id;

istobeupdated = istobeupdated1 | istobeupdated2; % logical index OR operation

tobeupdated = s1Is2Id(istobeupdated);


src1_updateDest = {};

src1_updateDest = pvt_getListAgainstRefnames(tobeupdated, s1names, s1namesfull, src1_updateDest);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function src1_addSrc2updateDest = local_addSrc2updateDest(s1Id__s1Is2Id, ...
    s1names, s1only, s1namesfull)

% Add to Source2 and then update Destinaiton
src1_addSrc2updateDest = {};

src1_addSrc2updateDest = pvt_getListAgainstRefnames(s1Id__s1Is2Id, s1names, s1namesfull, src1_addSrc2updateDest);

src1_addSrc2updateDest = pvt_getListAgainstRefnames(s1only, s1names, s1namesfull, src1_addSrc2updateDest);



end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function src1_addDest = local_addDest(s1Is2__s1Is2Id, s1names, s1namesfull)

% Add to Destination
src1_addDest = {};

src1_addDest = pvt_getListAgainstRefnames(s1Is2__s1Is2Id, s1names, s1namesfull, src1_addDest);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [src2_rmSrc2] = local_removalFromS2(s2Id__s1Is2Id,...
    s2only, s2names, s2namesfull)

% Removal from source2
src2_rmSrc2 = {};

src2_rmSrc2 = pvt_getListAgainstRefnames(s2only, s2names, s2namesfull, src2_rmSrc2);

src2_rmSrc2 = pvt_getListAgainstRefnames(s2Id__s1Is2Id, s2names, s2namesfull, src2_rmSrc2);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dest_rmDest] = local_removalFromD(s2Id__s1Is2Id,...
    donly, dnames, dnamesfull)

% Removal from destination
dest_rmDest = {};

dest_rmDest = pvt_getListAgainstRefnames(donly, dnames, dnamesfull, dest_rmDest);

dest_rmDest = pvt_getListAgainstRefnames(s2Id__s1Is2Id, dnames, dnamesfull, dest_rmDest);

end
