function [names, namesfull, datenums] = pvt_getfilenameswithoutaffix(dirpath, affix)
% [names, namesfull, datenums] = pvt_getfilenameswithoutaffix(dirpath, affix)
%
% INPUT ARGUMENTS
% dirpath   a valid folder path for the "source" files from which the "destination"
%           files are derived.
%
% affix     a string (char tyipe) for file name prefix and/or suffix
%           and a wildcard(*) that are common to the "source" files.
%           Multiple wildcard characters are not accepted. The "source"
%           file anmes and "destination" file names must be identical
%           except those affixes. In other words, the wildcards represent
%           the identical part of the file names for the two folders.
%
% OUTPUT ARGUMENTS
% names     file names without affixes (prefix or suffix)
% namesfull full paths of files without affixes (they can be invalid file paths)
% datenums  datenum values of all the files
%
%
% See also
% K_getupdated, K_getupdatedf, K_getupdatedmerge


%% Parse
narginchk(2,2);
p= inputParser;
vfdir = @(x) isrow(x) && ischar(x) && isdir(x);
vfa = @(x) ischar(x) && isempty(x) || isrow(x) && isempty(strfind(x, filesep)) ...
    && isempty(strfind(x, '*')) || length(strfind(x, '*')) == 1 ; % only accept one wild card
p.addRequired('dirpath', vfdir);
p.addRequired('affix', vfa);

p.parse(dirpath, affix);


%% Job

list = dir(fullfile(dirpath, affix));
namesaf = {list(:).name}';
affix = strsplit(affix, '*');

% remove empty string in case like src1affix == '*.mat'
ind = cell2mat(cellfun(@(x) ~isempty(x), affix, 'UniformOutput', false));
affix_ = affix(ind);
affix_tokens = strcat(cellfun(@(x) ['(',x,')'], affix_, 'UniformOutput', false));

namesfull = fullfile(dirpath, namesaf);
names = regexprep(namesaf, affix_tokens, '');

datenums = zeros(length(list), 1);
for i=1:length(list)
    datenums(i) = list(i).datenum;
end

end