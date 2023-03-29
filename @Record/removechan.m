function rec = removechan(rec, chantitle)
%rec = removets(rec, chantitle)
% removes one or more Chan objects with the specified ChanTitle chantitle from the
% Record object rec. ChanTitle can either be a string or a cell array of
% strings.

narginchk(2,2);

p = inputParser;
vf1 = @(x) ~isempty(x) && ...
    ( ischar(x) && isrow(x) ) ||...
    ( iscellstr(x) && length(x) == length(unique(x)) );
addRequired(p, 'chantitle', vf1);
parse(p, chantitle);

if ischar(chantitle) && isrow(chantitle)
    chantitle = {chantitle};
end

[tf, selected] = ismember(chantitle, rec.ChanTitles);

if any(~tf)
    error('K:Record:removechan:chantitle',...
        'All elemtns of chantitle must match ChanTitle of Chan objects stored in Record.Chans');
end

if length(rec.Chans) <= length(chantitle)
    rec = Record('Name', rec.RecordTitle);
    
    %     error('K:Record:removechan:onlyOneChan',...
    %         'You cannot delete the last Chan object in the Record.');
else
    
    
    rec.Chans(selected) = []; % delete the cell itself
end


end