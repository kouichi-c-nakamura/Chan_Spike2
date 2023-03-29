function obj = removeChan(obj, delChan)
%  obj = removeChan(obj, chanTitle1)
%  obj = removeChan(obj, {chanTitle1, chanTitle2, ....})
%
% delChan    either a char row or cellstr row
% 
% see also FileList.removeRecord()


narginchk(2,2);

assert(isempty(delChan) ||...
    ischar(delChan) && isrow(delChan) ||...
    iscellstr(delChan) &&  isvector(delChan),...
    'K:RecordAInfo:removeChan:delChan:invalid',...
    'delChan must be a char row or cellstr vector');

if isempty(delChan)
    return
elseif ischar(delChan)
    delChan = {delChan};
end

if isrow(delChan)
    delChan = delChan'; % make a column
end

list = obj.ChanTitles; %TODO

Lia = ismember(delChan, list); 

assert( nnz(Lia) == length(delChan),...
    'K:RecordAInfo:removeChan:delChan:notincluded',...
    'All elements of delChan must be member of %s.MemberNames', inputname(1));


newlist = setdiff(list, delChan);
[Lia] = ismember(list, newlist); % keep the order of objects unsorted

obj.ChanInfos = obj.ChanInfos(Lia);



end