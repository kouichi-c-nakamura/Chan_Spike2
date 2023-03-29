function [TF,names] = ischanwithfield(chanSpec,targetfield)
% ChanSpecifier.ischanwithfield method determines which channels include a field or fields specified by
% targetfield and returns logical array TF.
%
% [TF,names] = ischanwithfield(chanSpec,targetfield)
%
% See also
% ischanvalid, ChanSpecifier

p = inputParser;
p.addRequired('chanSpec');
p.addRequired('targetfield',@(x) isrow(x) && ischar(x) || iscellstr(x));
p.parse(chanSpec,targetfield);

%%Job

names = chanSpec.ChanTitlesMatNamesAll;

if char(targetfield)
    targetfield = {targetfield};
end

TF = false(sum(chanSpec.ChanNum),1);
k = 0;

for m = 1:chanSpec.MatNum
    for ch = 1:chanSpec.ChanNum(m)
        
        k = k + 1;
        
        clear this
        this = chanSpec.getstructOne(m,ch);
        
        fin = fieldnames(this);
        
        tf = false(length(targetfield),1);
        for i = 1:length(targetfield)
            
            tf(i) = ismember(targetfield{i},fin);
            
        end
        
        if all(tf)
            TF(k) = true;
        end
        
    end
    
end

end