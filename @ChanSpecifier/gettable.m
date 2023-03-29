function T = gettable(chanSpec, varargin)
% gettable is a simple wrapper of getstructNby1 method
%
%   T = gettable(chanSpec)
%   T = gettable(chanSpec, chanpropname);
%   T = gettable(chanSpec, TF);
%
% When called without "chanfieldname", it returns N by 1 non-scalar
% strucure of channels with unshared field left empty (== []), where N is the
% number of all the channels included.
%
% chanpropname   string (char type)
%                When "chanpropname" is given, looks for the specified
%                field of each channel and return it in a N by 1 non-scalar
%                structure, where N is the number of relavant channels.
%
% TF             Logical vector with the length that is euqal to the sum of
%                chanSpec.ChanNum
%
% OUTPUT ARGUMENTS
% T       table with N observations for all the N channels.
%         The uncommon fields are left empty [] for channels that don't
%         have those fields. The order of fields are kept unchanged as much
%         as possible. N equals to sum(chanSpec.ChanNum) or the number of
%         relavant channels with field 'chanpropname'.
%
% See also
% ChanSpecifier.getstructOne, ChanSpecifier.getstructNby1

%% Parse

narginchk(1,2);

p = inputParser;
p.addRequired('chanSpec');

vf2 = @(x) ischar(x) && isrow(x) || iscolumn(x) && all(x==0|x==1);
p.addOptional('chanpropname', '', vf2);

p.parse(chanSpec, varargin{:});

S = getstructNby1(chanSpec, varargin{:});


T = struct2table(S,'AsArray',true);