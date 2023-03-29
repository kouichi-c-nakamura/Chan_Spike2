function thiscol = whichcolumn(thisname, headers)
% prop      string. Property name:
% header    cellstr row vector. Header in the Excel sheet
%
% thiscol   numeric linear index for column in the Excel sheet
%
% returns the destination column for the property prop that particially matches header
% elements

assert(isrow(thisname) && ( ischar(thisname) && ~isempty(thisname) ) ||...
    iscellstr(thisname) && isscalar(thisname),...
    'K:K:FileList:saveSummaryXlsx:whichcolumn:thisname',...
    'thisname must be string (a row vector of char type) or scalar cellstr');

assert(iscellstr(headers) && isrow(headers) && ~isempty(headers),...
    'K:K:FileList:saveSummaryXlsx:whichcolumn:header',...
    'header must be cellstr');


%% return column number of unique matching headers

apropkey = regexpi(headers, ['^', thisname, '($|\s)'], 'ignorecase');
tf = cellfun(@(x) ~isempty(x), apropkey);
% ^xxxx matches the beginning of the input string
% (\s)? matches optional single space
% $ matches the end of input string
% (A|B) is OR operator
% apropkey     cell array containing the index of matches or empty cells


%TODO alternatively you could use ismember()

if nnz(tf) == 1 % single hit
    
    thiscol = find(tf);
    
elseif  nnz(~isempty(apropkey)) > 1
    error('K:FileList:saveSummary:whichcolumn:apropkey:toomanyhit',...
        'apropkey matches more than one of headers');
else % nnz(~isempty(apropkey)) == 0
    thiscol = [];
end


end