function row = mch2row(obj,m,ch)
% row = mch2row(obj,m,ch)
%
% BUAparameters.mch2row
%
% See also
% BUAparameters.row2mch

p = inputParser;
p.addRequired('obj');
p.addRequired('m',@(x) isscalar(x) && fix(x) == x && x > 0);
p.addRequired('ch',@(x) isscalar(x) && fix(x) == x && x > 0);
p.parse(obj,m,ch);

if isempty(obj.Tparams)
    row = [];
    return
    
else
    
    obj = changepathplatform(obj);
        
    this_matchanfull = fullfile(obj.chanSpec.MatNamesFull(m), ...
        obj.chanSpec.ChanTitles{m}{ch});
    
    Tmatchanfull = fullfile(obj.Tparams.parentdir,obj.Tparams.matname,...
        obj.Tparams.chantitle);
    
    TFmatch = strcmp(this_matchanfull,Tmatchanfull);
    
    row = find(TFmatch);
    
    assert(isempty(row) || length(row) <= 1,...
        'assuming the data is unique!')
end
end