function [matind,chanind] = tf2matindchanind(chanSpec,tf)
% tf2matindchanind returns index against all the channels in chanSpec
% based on an index for a *.mat file (matind) and an index for a channel in
% that *.mat file (chanind). 
%
%   [matind,chanind] = tf2matindchanind(chanSpec,tf)
%
% INPUT ARGUEMNT
% tf          Logical column whose length equals to sum(chanSpec.ChanNum)
%             tf specifies channels in chanSpec and is often obtained by
%             ischantitlematched, ischanvalid, ismatvalid or
%             ismatnamematched methods of ChanSpecifier
%
% OUTOUT ARGUMENTS
% matind      A column vector of scalar integer index for a *.mat file 
%             listed in chanSpec object.
%
% chanind     A column vector of scalar integer index for a channel in the 
%             *.mat file specified by matind. Each row of chanind
%             corresponds to each row of allind and matind.
%
%
% See also
% ChanSpecifier.allind2matindchanind


p = inputParser;
p.addRequired('chanSpec');
p.addRequired('tf',@(x) iscolumn(x) && all(x == 0 | x == 1));
p.parse(chanSpec,tf);

assert(length(tf) <= sum(chanSpec.ChanNum));

allind = find(tf);

[matind,chanind] = allind2matindchanind(chanSpec,allind);

end