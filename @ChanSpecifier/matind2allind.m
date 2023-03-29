function allind = matind2allind(chanSpec,matind)
% matind2allind returns index against all the channels in chanSpec based on
% an index for a *.mat file (matind) and an index for all the channels in
% that *.mat file (chanind)
%
%    allind = matind2allind(chanSpec,matind)
%
% INPUT ARGUEMNTS
% matind      A scalar integer index for a *.mat file listed in chanSpec
%             object.
%
% OUTOUT ARGUMENT
% allind      A columnar integer index for all the channels specified by matind 
%             against the all the channels in row.
%             This is particularly useful when you want to relate a channel
%             specified by matind and chanind and TF logical value returned
%             by ischanvalid, ischantitlematched, ismatvalid, and ismatnamematched
%             methods.
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
% See also
% matind2tf, allind2matindchanind, matindchanind2allind

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

end