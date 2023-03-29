function [tf] = allind2tf(chanSpec,allind)
% allind2tf returns logical index against all the channels in chanSpec
% based on integer indices for all the channels.
%
%   [tf] = allind2tf(chanSpec,allind)
%
% INPUT ARGUEMNT
% allind      scalar positive integer | column of positive integers
%             A scalar integer index for a channel specified by matind and
%             chanind against the all the channels in row.
%             Or a column vector of such integer indices.
%             This is particularly useful when you want to relate a channel
%             specified by matind and chanind and TF logical value returned
%             by ischanvalid, ischantitlematched, ismatvalid, and ismatnamematched
%             methods.
%
% OUTOUT ARGUMENTS
% tf          Logical vector
%
% See also
% ChanSpecifier.matindchanind2allind, ChanSpecifier.allind2matindchanind

p = inputParser;
p.addRequired('chanSpec');
p.addRequired('allind',@(x) isreal(x)&& all(x>0) && all(fix(x)==x) && ...
    isscalar(x) || iscolumn(x));
p.parse(chanSpec,allind);

assert(all(allind <= sum(chanSpec.ChanNum)));

%%

tf = false(sum(chanSpec.ChanNum),1);
tf(allind) = true;


end