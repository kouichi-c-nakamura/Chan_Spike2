function [affix, negaffixC] = pvt_parseaffix(affixes)
% [affix, negaffixC] = pvt_parseaffix(affixes)
% 
% INPUT ARGUMENT
% affixes   expressions containing prefix and/or suffix and a wild card are
%           separated by the delimiter "|". Any expressions after the
%           delimiter are considered negation. 
%
%           For example, '*.mat|*_info.mat|*_sp.mat', files that matches
%           '*.mat' will be searched except those match '*_info.mat' or
%           '*_sp.mat'. The delimiter and negative expressions are
%           optional.
%
% OUTPUT ARGUMENTS
% affix     char for affix for postive match
%
% negaffixC cell array of file names that are to be ignored.
%
% See also
% K_getupdated, K_getupdatedmerge


narginchk(1,1);

n = length(strfind(affixes, '|'));

expr = strcat('^([^\|]*)', repmat('\|([^\|]*)', 1, n));

tokens = regexp(affixes, expr, 'tokens');

isupto1wildcard = @(x) length(strfind(x, '*')) <= 1;

if ~isempty(tokens)
    tokens = tokens{1};
    affix = char(tokens{1});
    assert(isupto1wildcard(affix), eid('affix'),...
        'Only one wild card * per file name format is allowed.');
    
    if length(tokens) > 1
        negaffixC = tokens(2:end);
        
        assert(all(cellfun(isupto1wildcard, negaffixC)), ...
            eid('negaffixC'),...
            'Only one wild card * per file name format is allowed.');
    else
        negaffixC = {};
    end
else
    affix = '';
    negaffixC = {};
end

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