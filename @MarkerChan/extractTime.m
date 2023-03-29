function obj2 = extractTime(obj, StartTime, EndTime, mode, time)
% MarkerChan.extractTime is a method to extract a aubset of data between StartTime and EndTime
%
% SYNTAX
% obj2 = extractTime(obj, StartTime, EndTime, mode)
% obj2 = extractTime(obj, StartTime, EndTime, mode, time)
%
%
% INPUT ARGUMENTS
% obj         MarkerChan
%
% StartTime   scalar
%
% EndTime     scalar
%             Must be equal to or larger than StartTime.
%
%
% mode           0 (default) | non-negative integers
%             (Optional) Description about B comes here.
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'C'         'on' (default) | 'off'
%             (Optional) Description about 'C' comes here.
%
%
% OUTPUT ARGUMENTS
% D           cell array 
%             Description about D comes here.
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 08-Oct-2020 20:15:36
%
% See also
% MarkerChan


%obj2 = extractTime(obj, StartTime, EndTime)
% StartTime, EndTime, in seconds


arguments
    
    obj
    StartTime
    EndTime
    mode (1,:) char {mustBeMember(mode,{'normal','extend'})} = 'normal';
    time (:,1) = zeros(1, 0)
end


%% parse
if isempty(time)
    time = obj.time;
else
    assert(obj.Length == length(time))
    assert(obj.Start == time(1))
    assert(obj.MaxTime == time(end))    
end

%% job

warning off
obj2 = extractTime@Chan(obj, StartTime, EndTime, mode, time);
warning on

switch lower(mode)
    case 'normal'
        timestamps = time(cell2mat(obj.Data_(:,1))); %TODO need test
        stmpStartInd = find(timestamps >= StartTime, 1, 'first');
        
        stmpEndInd = find(timestamps <= EndTime, 1, 'last');
        
        obj2.Data_ = obj.Data_(stmpStartInd:stmpEndInd,:);
        
        % Support MarkerFilter
        
        startInd = find(time <= StartTime, 1, 'last'); % TODO need test
        
        obj2.Data_(:,1) = num2cell(cell2mat(obj2.Data_(:,1)) - (startInd -1));

        obj2.Header = obj.Header;
        obj2.MarkerFilter = obj.MarkerFilter;
        
    case 'extend'
        timestamps = time(cell2mat(obj.Data_(:,1))); % TODO need test
        stmpStartInd = find(timestamps >= StartTime, 1, 'first');
        
        stmpEndInd = find(timestamps <= EndTime, 1, 'last');
        
        obj2.Data_ = obj.Data_(stmpStartInd:stmpEndInd,:);
        
        % Support MarkerFilter

        if StartTime < obj.Start
            startInd = 1;
            startpad = round((obj.Start - StartTime)/obj.SInterval); 
            
        else
            startInd = find(time <= StartTime, 1, 'last');  % TODO need test
            startpad = 0;
        end
        
        obj2.Data_(:,1) = num2cell(cell2mat(obj2.Data_(:,1)) + startpad - (startInd -1));
        
        obj2.Header = obj.Header;
        obj2.MarkerFilter = obj.MarkerFilter;
        
end

end