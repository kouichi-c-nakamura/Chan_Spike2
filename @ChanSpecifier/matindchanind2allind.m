function allind = matindchanind2allind(chanSpec,matind,chanind)
% matindchanind2allind returns index against all the channels in chanSpec
% based on an index for a *.mat file (matind) and an index for a channel in
% that *.mat file (chanind)
%
%    allind = matindchanind2allind(chanSpec,matind,chanind)
%
% INPUT ARGUEMNTS
% matind      A scalar integer index for a *.mat file listed in chanSpec
%             object.
%
% chanind     A scalar integer index for a channel in the *.mat
%             file specified by matind.
%
% OUTOUT ARGUMENT
% allind      A scalar integer index for a channel specified by matind and
%             chanind against the all the channels in row.
%             This is particularly useful when you want to relate a channel
%             specified by matind and chanind and TF logical value returned
%             by ischanvalid, ischantitlematched, ismatvalid, and ismatnamematched
%             methods.
%
% 
% EXAMPLE
% Skip channels whose corresponding TF logical vector is flase
% 
%     chanSpec = ChanSpecifier(folderpath);
% 
%     TF = chanSpec.ischanvalid('length', @(x) x > 10000);
% 
%     k = 0;
%     C = cell(nnz(TF),0);
%     for m = 1:chanSpec.MatNum 
%         if ~isempty(TF) && ~any(TF(chanSpec.matind2allind(m)))
%             continue
%         end
% 
%         for ch = 1:chanSpec.ChanNum(m)    
%             if isempty(TF) || TF(chanSpec.matindchanind2allind(m,ch))
%                 k = K +1;
% 
%                 thisChan = chanSpec.constructChan(m,ch);
% 
%                 C{k} = thisChan.Data;
% 
%             end
%         end
%     end
% 
%
% See also
% ChanSpecifier.allind2matindchanind

narginchk(3,3)
% p = inputParser;   % FOR SPEED PARSER HAS BEEN COMMENTED OUT
% p.addRequired('chanSpec');
% p.addRequired('matind',@(x)isreal(x)&&isscalar(x)&&x>0&&fix(x)==x);
% p.addRequired('chanind',@(x)isreal(x)&&isscalar(x)&&x>0&&fix(x)==x);
% p.parse(chanSpec,matind,chanind);

assert(matind <= chanSpec.MatNum);
assert(chanind <= chanSpec.ChanNum(matind));

%%
if matind == 1
    allind = chanind;
else
    allind = sum(chanSpec.ChanNum(1:matind-1)) + chanind;
end

end