function S = K_getupdated(srcdir, srcaffix, destdir, destaffix)
%  S = K_getupdated(srcdir, srcaffix, destdir, destaffix)
%
% Check the file status of files in 2 folders, srcdir and destdir. Returns which
% files need to be updated or deleted.
%
% for comparison of 3 folders, see K_getupdatedmerge
%
% INPUT ARGUMENTS
% srcdir    a valid folder path for the "source" files from which the "destination"
%           files are derived.
%
% srcaffix  a string (char tyipe) for file name prefix and/or suffix
%           and a wildcard(*) that are common to the "source" files.
%           Multiple wildcard characters are not accepted. The "source"
%           file anmes and "destination" file names must be identical
%           except those affixes. In other words, the wildcards represent
%           the identical part of the file names for the two folders.
%
%           srcaffix can also take negation in the format
%           '*.mat|*_info.mat|*_sp.mat', where | serve as a delimiter and
%           the expressions after the first demilimiter is for negation
%           (names of files to be ginored). Only one wild card is allowed
%           for each file name expression. In the following example
%
%               '*.mat|*_info.mat|*_sp.mat'
%
%           files that matches '*.mat' will be searched except those match
%           '*_info.mat' or '*_sp.mat'. The delimiter and negative
%           expressions are optional.
%
% destdir   a valid folder path for the "destination" files that are derived
%           from the "source" files
%
% destaffix The same as src1affix but for destdir
%
%
% OUTPUT ARGUMENTS
% S          A structure.
%
% S.src_updateDest
%             This holds the names of the source files whose dependent
%             destination files need to be updated in the destination
%             folder destdir..
%
% S.src_addDest
%             This holds the names of the source files whose dependent
%             desination files need to be added in the destination folder
%             destdir.
%
% S.dest_rmDest
%             This holds the names of files that needs to be deleted in the
%             destination folder destdir..
%
% S.src       Equals to srcdir
% S.dest      Equals to destdir
%
% S.src_all
%             Names of all the relevent files in the Source directory.
%
% S.dest_all
%             Names of all the relevent files in the Destintion directory.
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 24-Jul-2017 17:30:37
%
% See also
% K_getupdatedmerge, K_getupdatedf, K_checkmerge
% pvt_getListAgainstRefnames, pvt_getupdated_initS, pvt_getfilenameswithoutaffix

%% Parser

narginchk(4,4);
p= inputParser;
vfdir = @(x) isrow(x) && ischar(x) && isdir(x);
vfa = @(x) ischar(x) && isempty(x) || isrow(x) && ~contains(x, filesep) ...
    && ~contains(x, '*') || length(strfind(x, '*')) <= length(strfind(x, '|')) + 1; % only accept one wild card per affix
p.addRequired('srcdir', vfdir);
p.addRequired('srcaffix', vfa);
p.addRequired('destdir', vfdir);
p.addRequired('destaffix', vfa);

p.parse(srcdir, srcaffix, destdir, destaffix);

%% Job

[snames, snamesfull, sdatenum] = pvt_getNamesDatanum(srcdir, srcaffix);
[dnames, dnamesfull, ddatenum] = pvt_getNamesDatanum(destdir, destaffix);

%% setdiff for addition or removal of files

sId  = intersect(snames, dnames); % compare datanum
s__d = setdiff(snames, dnames);   % add to Dest
d__s = setdiff(dnames, snames);   % remove from Dest

S.src_updateDest = local_updateDest(sId, snames, dnames, sdatenum, ddatenum, snamesfull);

S.src_addDest = local_addDest(s__d, snames, snamesfull);

S.dest_rmDest = local_rmDest(d__s, dnames, dnamesfull);

S.src = srcdir;
S.dest =destdir;

S.src_all = local_fullpaths2paths(snamesfull);
S.dest_all = local_fullpaths2paths(dnamesfull);


end

%--------------------------------------------------------------------------

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
%--------------------------------------------------------------------------
function src_updateDest = local_updateDest(sId, snames, dnames, sdatenum, ddatenum, snamesfull)

% intersect for comparison of datenum for required updates

[~, ind_s ] = ismember(sId, snames);
[~, ind_d ] = ismember(sId, dnames);

sdatenum_sId = sdatenum(ind_s);
ddatenum_sId = ddatenum(ind_d);
istobeupdated = sdatenum_sId > ddatenum_sId;

tobeupdated = sId(istobeupdated);

src_updateDest = {};

src_updateDest = pvt_getListAgainstRefnames(tobeupdated, snames, snamesfull, src_updateDest);


end

%--------------------------------------------------------------------------

function src_addDest = local_addDest(s__d, snames, snamesfull)

src_addDest = {};

src_addDest = pvt_getListAgainstRefnames(s__d, snames, snamesfull, src_addDest);

end
%--------------------------------------------------------------------------
function dest_rmDest = local_rmDest(d__s, dnames, dnamesfull)

dest_rmDest = {};

dest_rmDest = pvt_getListAgainstRefnames(d__s, dnames, dnamesfull, dest_rmDest);


end

%--------------------------------------------------------------------------
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
