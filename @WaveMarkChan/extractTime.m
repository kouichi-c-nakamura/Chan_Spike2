function obj2 = extractTime(obj, StartTime, EndTime, mode, time)
%obj2 = extractTime(obj, StartTime, EndTime)
% StartTime, EndTime, in seconds

arguments
    
    obj
    StartTime
    EndTime
    mode (1,:) char {mustBeMember(mode,{'normal','extend'})} = 'normal';
    time (:,1) = zeros(1, 0)
end


if isempty(time)
    time = obj.time;
else
    assert(obj.Length == length(time))
    assert(obj.Start == time(1))
    assert(obj.MaxTime == time(end))    
end
%% job

obj2 = extractTime@MarkerChan(obj, StartTime, EndTime, mode, time);

switch lower(mode)
    case 'normal'
        timestamps = time(cell2mat(obj.Data_(:,1))); %TODO need test
        stmpStartInd = find(timestamps >= StartTime, 1, 'first');
        
        stmpEndInd = find(timestamps <= EndTime, 1, 'last');

        obj2.TracesAll_ = obj.TracesAll_(stmpStartInd:stmpEndInd,:);
        
    case 'extend'
        timestamps = time(cell2mat(obj.Data_(:,1))); % TODO need test
        stmpStartInd = find(timestamps >= StartTime, 1, 'first');
        
        stmpEndInd = find(timestamps <= EndTime, 1, 'last');
        
%         obj2.Data_ = obj.Data_(stmpStartInd:stmpEndInd,:);
%         
%         % Support MarkerFilter
% 
%         if StartTime < obj.Start
%             startInd = 1;
%             startpad = (obj.Start - StartTime)/obj.SInterval; 
%             
%         else
%             startInd = find(time <= StartTime, 1, 'last');  % TODO need test
%             startpad = 0;
%         end
% %         
% %         obj2.Data_(:,1) = num2cell(cell2mat(obj2.Data_(:,1)) + startpad - (startInd -1));
%         

        obj2.TracesAll_ = obj.TracesAll_(stmpStartInd:stmpEndInd,:);

        
end

end