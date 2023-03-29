function relpath = K_pathAbs2Rel( targetpath, refdirpath )
% relpath = K_pathAbs2Rel( targetpath, refdirpath )
%
% targetpath      String. Absolute path of a file including extension or a folder
%                 If targetpath is empty, empty string is returned.
% refdirpath      String. Absolute path of a folder as a reference for
%                 relative paths.
%
% relpath         String.  Relative path of targetpath in relation to
%                 refdirpath. 
%                 In case the volume drive letters don't match,
%                 an absolute path will be returned.
% 
% Converts an absolute path targetpath into relative path in relation to a
% folder at targetpath
%
% TestCase
% test1= test_K_pathAbs2Rel; disp(test1.run);
%
% See also:  K_pathRel2Abs



%% parse
narginchk(2,2);

p = inputParser;

vf_targetpath = @(x) isempty(x) || ischar(x) && isrow(x) && any(regexp(x, filesep));
vf_refdirpath = @(x) ~isempty(x) && ischar(x) && isrow(x) && any(regexp(x, filesep));

addRequired(p, 'targetpath', vf_targetpath);
addRequired(p, 'refdirpath', vf_refdirpath);

parse(p, targetpath, refdirpath);




%% job

% If targetpath is empty, empty string is returned.
if isempty(targetpath)
    relpath = '';
    return
end


% Create a cell-array of directories in hierarchy
refdirpath_cell = foldersInPath(refdirpath); 

[targetdirpath, name ,ext] = fileparts(targetpath);
if isempty(ext) % targetpath is a folder
    targetdirpath = targetpath;
    targetfilename = '';
else % targetpath is a file
    targetfilename = [name, ext];
end

targetdirpath_cell = foldersInPath(targetdirpath);

% If volumes are different, return absolute path:
if ~strcmp( refdirpath_cell{1} , targetdirpath_cell{1} )
    relpath = targetpath;
    return
end

% Delete top level dir one by one

while  ~isempty(refdirpath_cell) && ~isempty(targetdirpath_cell)
    if  strcmp( refdirpath_cell{1}, targetdirpath_cell{1} )
        refdirpath_cell(1) = [];
        targetdirpath_cell(1) = [];
    else
        break
    end
end

% add '..\' one by one
relpath = '';
for  i = 1 : length(refdirpath_cell)
    relpath = ['..' filesep relpath];
end

% Relative directory levels to target directory:
for  i = 1 : length(targetdirpath_cell)
    relpath = [relpath filesep];
    relpath = [relpath targetdirpath_cell{i}];
end

relpath = fullfile(relpath, targetfilename);

end




function path_cell = foldersInPath(path_str)
% path_cell = foldersInPath(path_str)
% create cell array of directories from top level to bottom


path_str = [filesep, path_str];

% Make sure refdirpath end with a filesep
if path_str(end) ~= filesep
    path_str = [path_str, filesep];
end

sep_pos = strfind( path_str, filesep );
path_cell = cell(length(sep_pos)-1, 1);
for i = 1 : length(sep_pos)-1
    path_cell{i} = path_str( sep_pos(i)+1 : sep_pos(i+1)-1 );
end

end