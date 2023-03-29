function tf = matind2tf(chanSpec,matind)
% matind2tf returns index against all the channels in chanSpec based on
% an index for a *.mat file (matind) and an index for all the channels in
% that *.mat file (chanind). This is a wrapper of matind2allind
%
%    tf = matind2tf(chanSpec,matind)
%
% INPUT ARGUEMNTS
% matind      A scalar integer index for a *.mat file listed in chanSpec
%             object.
%
% OUTOUT ARGUMENT
% tf          A columnar logical vector which has true for all the channels 
%             specified by matind against the all the channels in row. This
%             is particularly useful when you want to relate a channel
%             specified by matind and chanind and TF logical value returned
%             by ischanvalid, ischantitlematched, ismatvalid, and
%             ismatnamematched methods.
%
%
% See also
% matind2allind, allind2matindchanind, matindchanind2allind

% p = inputParser;
% p.addRequired('chanSpec');
% p.addRequired('matind',@(x)isreal(x)&&isscalar(x)&&x>0&&fix(x)==x);
% p.parse(chanSpec,matind);

narginchk(2,2)
assert(matind <= chanSpec.MatNum);

%%
if matind == 1
    allind = (1:chanSpec.ChanNum(1))';
else
    allind = (sum(chanSpec.ChanNum(1:matind-1))+1:sum(chanSpec.ChanNum(1:matind)))';
end

tf = false(sum(chanSpec.ChanNum),1);
tf(allind) = true;

end