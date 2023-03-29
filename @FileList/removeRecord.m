function obj = removeRecord(obj, delRecord)
%  obj = removeRecord(obj, recTitle1)
%  obj = removeRecord(obj, {recTitle1, recTitle2, ....})
%
% delRecord    either a char row or cellstr row
%
% see also ChanInfo.removeChan()

narginchk(2,2);

assert(isempty(delRecord) ||...
    ischar(delRecord) && isrow(delRecord) ||...
    iscellstr(delRecord) &&  isvector(delRecord),...
    'K:FileList:removeRecord:delRecord:invalid',...
    'delRecord must be a char row or cellstr vector');

if isempty(delRecord)
    return
elseif ischar(delRecord)
    delRecord = {delRecord};
end

if isrow(delRecord)
    delRecord = delRecord'; % make a column
end

list = obj.MemberTitles;

Lia = ismember(delRecord, list); 

assert( nnz(Lia) == length(delRecord),...
    'K:FileList:removeRecord:delRecord:notincluded',...
    'All elements of delRecord must be member of %s.getMemberNames', inputname(1));

newlist = setdiff(list, delRecord);
[Lia] = ismember(list, newlist); % keep the order of objects unsorted

obj.List = obj.List(Lia);



end