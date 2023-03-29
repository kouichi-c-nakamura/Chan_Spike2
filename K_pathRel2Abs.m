function  abspath = K_pathRel2Abs( targetpath, refdirpath )
% abspath = K_pathRel2Abs( targetpath, refdirpath )
%
% targetpath      String. Relative path of a file including extension or a folder
%                 If targetpath is empty, empty string is returned.
%
% refdirpath      String. Absolute path of a folder as a reference for
%                 relative paths.
%
% abspath         String.  Absolute path of targetpath.
%                 If targetpath is on different drive from
%                 refdirpath, then abs_path returns 
%
% 
% Converts an absolute path targetpath into relative path in relation to a
% folder at targetpath
%
%
% TestCase
% test1= K_pathRel2Abs; disp(test1.run);
%
% See also:  K_pathAbs2Rel


%% parse
narginchk(2,2);

p = inputParser;

vf_targetpath = @(x) isempty(x) || ischar(x) && isrow(x);
vf_refdirpath = @(x) ~isempty(x) && ischar(x) && isrow(x) && any(regexp(x, filesep));

addRequired(p, 'targetpath', vf_targetpath);
addRequired(p, 'refdirpath', vf_refdirpath);

parse(p, targetpath, refdirpath);





%% job

% If targetpath is empty, empty string is returned.
if isempty(targetpath)
    abspath = '';
    return
end

% Make sure strings end by a filesep character:

[targetdirpath, name ,ext] = fileparts(targetpath);
if isempty(ext) % targetpath is a folder
    targetdirpath = targetpath;
    targetfilename = '';
else % targetpath is a file
    targetfilename = [name, ext];
end



% Create a cell-array containing the directory levels:
refdirpath_cell = foldersInPath(refdirpath);
targetdirpath_cell = foldersInPath(targetdirpath);
abs_path_cell = refdirpath_cell;

% Combine both paths level by level:
while  ~isempty(targetdirpath_cell)
    if strcmp(targetdirpath_cell{1}, '..')
        abs_path_cell(end) = [];
        targetdirpath_cell(  1) = [];
    else
        abs_path_cell{end+1} = targetdirpath_cell{1};
        targetdirpath_cell(1)     = [];
    end
end

abspath = fullfile(abs_path_cell{:});


if ~isempty(targetfilename)
    abspath = fullfile(abspath, targetfilename);
end

end


function path_cell = foldersInPath(path_str)
% path_cell = foldersInPath(path_str)
% create cell array of directories from top level to bottom

if path_str(1) ~= filesep
    path_str = [filesep, path_str];
end

if path_str(end) ~= filesep
    path_str = [path_str, filesep];
end

sep_pos = strfind( path_str, filesep );
path_cell = cell(length(sep_pos)-1, 1);
for i = 1 : length(sep_pos)-1
    path_cell{i} = path_str( sep_pos(i)+1 : sep_pos(i+1)-1 );
end

end