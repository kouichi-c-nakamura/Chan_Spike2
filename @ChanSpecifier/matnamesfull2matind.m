function matind = matnamesfull2matind(chanSpec, matnamesfull)
% matind = matnamesfull2matind(chanSpec, matnamesfull)
%
% INPUT ARGUMENTS
% matnamesfull   fullpath of a mat file in char or
%                cell vector of fullpaths of mat files
%
% OUTPUT ATGUMENTS
% matind         A column of positive integers that specifys the mat files at matnamesfull.
%
%                Or if matnamesfull is cellstr, cell column vector with the
%                length of matnamesfull containing a column of positive
%                integers as above.
%
%                Note that chanSpec can hold mulitiple copies of exactly
%                the same mat file. To support these cases, the matind is
%                stored in a cell vector rather than a numeric vector.
%
% EXAMPLES
% matind = matnamesfull2matind(chanSpec, 'folder\name1')
% matind = matnamesfull2matind(chanSpec, {'folder\name1','folder\name2'} )
%
% See also
% chantitles2chanind


%% Parse

narginchk(2,2)

p = inputParser;
p.addRequired('chanSpec');


vf = @(x) (ischar(x) && isrow(x)) ||...
    (iscellstr(x) && isvector(x));
p.addRequired('matnamesfull', vf);
p.parse(chanSpec, matnamesfull);

%% Job
waschar = false;
if ischar(matnamesfull)
    matnamesfull = {matnamesfull};
    waschar = true;
end

if isrow(matnamesfull)
    matnamesfull = matnamesfull'; % make column vector
end

n = length(matnamesfull);
matind = cell(n, 1);
for i = 1:n
    matind{i} = find(ismember(chanSpec.MatNamesFull, matnamesfull{i}));
    if isempty(matind{i})
        error('K:ChanSpecifier:matnamesfull2matind:matnamesfull',...
            '%dth element of %s, %s doesn''t match any of mat file full paths.', ...
            i, inputname(2), matnamesfull{i});
        
    end
end

if n == 1 && waschar
    matind = matind{1};
end


end