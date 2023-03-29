function [m,ch] = row2mch(obj,row)
% [m,ch] = row2mch(obj,row)
%
% BUAparameters.row2mch
%
% See also
% BUAparameters.mch2row

p = inputParser;
p.addRequired('obj');
p.addRequired('row',@(x) isscalar(x) && fix(x) == x && x > 0);
p.parse(obj,row);

if isempty(obj.Tparams)
    m = [];
    ch = [];
    return
    
else
    
    obj = changeplatform(obj);
    
    chSp = obj.chanSpec;
    
    matfulls   = chSp.MatNamesFull;
    channum   = chSp.ChanNum;
    
    C = arrayfun(@(x,y) repmat(x{1},channum,1), matfulls, channum,'UniformOutput',false);
    matfullsdup = vertcat(C{:});
    clear C
    
    matchanfull = fullfile(matfullsdup,chanSpec.ChanTitlesAll);
     
    
    
    Tmatchanfull   = fullfile(obj.Tparams.parentdir,obj.Tparams.matname,...
        obj.Tparams,obj.Tparams.chantitle);
    
    thisTmatchanfull = Tmatchanfull(row);
    
    TFmatch = strcmp(thisTmatchanfull,matchanfull);
    
    assert(nnz(TFmatch) <= 1); % unique or no hit
    
    [m,ch] = chSp.allind2matindchanind(find(TFmatch));
    

end
end