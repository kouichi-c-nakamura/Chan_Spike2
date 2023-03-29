function [TFchan, names, TFmat] = ismatnamematched(chanSpec, expr, varargin)
% A wrapper of ismatvalid with @ismatchedany
%
% [TFchan, names, TFmat] = ismatnamematched(chanSpec, expr)
% [TFchan, names, TFmat] = ismatnamematched(______, 'full')
% [TFchan, names, TFmat] = ismatnamematched(______, 'literal')
% 
% INPUT ARGUMETS
% chanSpec      a ChanSpecifier object
%
% expr          Regular expression in char type string or cell array of
%               strings.
%               String (char type). A field name of a channel structure
%               (chanSpec.List.channels.xxxxx) that is to be evaluated
%
% OPTION
% 'full'        Matching of full path of mat file names or MatNamesFull.
%               Note that you need to escape special characters in expr by
%               adding \ in front of each in order to use regexp internally.
%
%
% OUTPUT ATGUMENTS
% TFchan            vertical vector of logical 
%               a logical for a .mat file is followed by logical values for
%               channels included in that .mat file.
%
% names         So that you can tell which value is which, this cell array
%               of strings has the same size as TFchan. It contains name of
%               each .mat files and title of each channel that
%               corresponds to the TFchan. names(TFchan) gives you the file names
%               and chan titles of the selection.
%
%
%
%
% (Example)
%      [TFchan, names] = ismatnamematched(chanSpec, '^kjx127b')
%      and
%      [TFchan, names] = chanSpec.ismatnamematched('^kjx127b')
%      are equlvalen to
%      [TFchan, names] = ismatvalid(chanSpec, 'name', @(x) ismatchedany(x, '^kjx127b'))
%      and
%      [TFchan, names] = chanSpec.ismatnamematched('name', @(x) ismatchedany(x, '^kjx127b'))
%
%%
%
% See also
% ChanSpecifier.ismatvalid, ChanSpecifier.choose, ismatchedany,
% regexptranslate
%
% 19 Jun 2015
% Written by Dr Kouichi C. Nakamura
% kouichi.c.nakamura@gmail.com


%% parse
narginchk(2,3);
dofull = false;

if length(varargin) == 1
   
    assert(ischar(varargin{1}) && strcmpi(varargin{1}, 'full'),...
        'ismatnamematched:full:invalid', 'The option must be ''full'' .');

    dofull = true;   
end

if dofull
    
    fullnames = chanSpec.MatNamesFull;
    
    index = find(ismatched(fullnames, expr));

    [TFchan, names, TFmat] = ismatvalid(chanSpec, index);    
    
else
    
    [TFchan, names, TFmat] = ismatvalid(chanSpec, 'name', @(x) ismatchedany(x, expr));
    
end


end
