function [matind,chanind] = allind2matindchanind(chanSpec,allind)
% allind2matindchanind returns index against all the channels in chanSpec
% based on an index for a *.mat file (matind) and an index for a channel in
% that *.mat file (chanind)
%
%   [matind,chanind] = allind2matindchanind(chanSpec,allind)
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
% matind      A scalar integer index for a *.mat file listed in chanSpec
%             object.
%             Or a column vector of such integers when allind is a column
%             vector.
%
% chanind     A scalar integer index for a channel in the *.mat
%             file specified by matind.
%             Or a column vector of such integers when allind is a column
%             vector. Each row of chanind corresponds to each row of allind
%             and matind.
%
%
% See also
% ChanSpecifier.matindchanind2allind

p = inputParser;
p.addRequired('chanSpec');
p.addRequired('allind',@(x) isreal(x)&& all(x>0) && all(fix(x)==x) && ...
    isscalar(x) || iscolumn(x));
p.parse(chanSpec,allind);

assert(all(allind <= sum(chanSpec.ChanNum)));

%%

matind = zeros(size(allind));
chanind = matind;

for i = 1:length(allind)

    ind = find(cumsum(chanSpec.ChanNum)<allind(i),1,'last');
    if isempty(ind)
       ind = 0; 
    end
    
    matind(i) = ind + 1;
    
    if isempty(matind(i))
        matind(i) = 1;
        chanind(i) = allind(i);
        
    else
        chanind(i) = allind(i) - sum(chanSpec.ChanNum(1:matind(i)-1));
    end

end

end