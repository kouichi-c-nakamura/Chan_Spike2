function obj = addRecord(obj, newRecord)
%  obj = addRecord(obj, rec1)
%  obj = addRecord(obj, recInfo1)
%  obj = addRecord(obj, {rec1; rec2; ...})
%  obj = addRecord(obj, {recInfo1; recInfo2; ...})
%
% newRecord    either a Record or RecordInfo object, or
%                Record objects or RecordInfo object in
%                cell array of column vector

narginchk(2,2);

assert(isempty(newRecord) ||...
    isscalar(newRecord)  && ( isa(newRecord, 'Record' )|| isa(newRecord, 'RecordInfo')) ||...
    iscolumn(newRecord) && ...
    iscell(newRecord) && ...
    (   all(cellfun(@(x) isa(x, 'Record'), newRecord)) ||...
    all(cellfun(@(x) isa(x, 'RecordInfo'), newRecord))   )   );

if isempty(newRecord)
    return
elseif iscell(newRecord)
    if all(cellfun(@(x) isa(x, 'Record'), newRecord))
        
        newRecordInfos = cellfun(@(x) x.getRecordInfo, newRecord, 'UniformOutput', false);
        
    elseif all(cellfun(@(x) isa(x, 'RecordInfo'), newRecord))
        newRecordInfos = newRecord;
    end
    
else % not cell
    if isa(newRecord, 'Record')
        newRecordInfos = {newRecord.getRecordInfo};
        
    elseif isa(newRecord, 'RecordInfo')
        newRecordInfos = {newRecord};
    end
    
end

% check the uniqueness of RecordTitle
newRecordTitles = cellfun(@(x) x.RecordTitle,  newRecordInfos, 'UniformOutput', false);

% if isempty(obj.List)
%     currentRecordTitles = {};
% else
%     currentRecordTitles = cell(length(obj.List), 1);
%     for i = 1:length(obj.List)
%         currentRecordTitles{i} = obj.List{i}.RecordTitle;
%     end
% end
currentRecordTitles = obj.MemberTitles;

titles = [currentRecordTitles; newRecordTitles];

assert(numel(unique(titles)) == numel(titles),...
    'K:FileList:addRecord:RecordTitle:notunique',...
    'RecordTitle must be unique.');

obj.List = [obj.List; newRecordInfos];

end