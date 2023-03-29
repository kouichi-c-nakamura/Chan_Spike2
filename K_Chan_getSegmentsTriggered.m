function outdata = K_Chan_getSegmentsTriggered(data, triggerT, width, offset)
%
% input arguments
% data         Chan objects or Record objectis or cell array
%              vector containing them
%
% triggerT     A vector of monotonically increasing event timestamps that
%              is used as triggers or cell array vector containing them for
%              each data (the cell array must have the same size as data)
% width        in seconds
% offset       in seconds
%
% output arguments
% outdata      Record
%              when data doesn't exist within width, elements will be
%              padded with NaNs.
%
% Overlapped period will be ignored (can make it optional)


%% parse
p = inputParser;


vf_data = @(x) ~iscell(x) && isscalar(x) && (isa(x, 'Record') ||  isa(x, 'Chan') ) ||...
    iscell(x) && isvector(x) && ...
    ( all(cellfun(@(y) isa(y, 'Record'))) || all(cellfun(@(y) isa(y, 'Chan'))));

addRequired(p, 'data', vf_data);

vf_triggerTone = @(x)  ~iscell(x) && isvector(x) && isnumeric(x) && ...
    x > 0 && all(diff(x) > 0);

vf_triggerT = @(x) vf_triggerTone(x) || ...
    iscell(x) && isvector(x) && all(cellfun(@(y) vf_triggerTone(y), x)); 

addRequired(p, 'triggerT', vf_triggerT);


vf_width = @(x) isscalar(x) && isnumeric(x) &&...
    x > 0;

addRequired(p, 'width', vf_width);


vf_offset = @(x) isscalar(x) && isnumeric(x) &&...
    x > 0;

addRequired(p, 'offset', vf_offset);

parse(p, data, triggerT, width, offset);


%% 




%% job

if iscell(data)
    
    if ~iscell(triggerT) ||  size(triggerT) ~= size(data)
        error('K:K_Chan_getSegmentsTriggered:triggerT:cell:size',...
            'Size of triggerT doesn''t match that if data.');
    end
    
    for i = 1:length(data)
        
        
        
        
       if isa(data{i}, 'Chan')
           obj = data{i};
           obj.time
           
           
           
       elseif isa(data{i}, 'Record')
           
           
           
       end
        
        
        
    end
else
    
    
end
    


end



function out = chooseTime(obj, thisTriggerT, width, offset)

sInterval = obj.SInterval;
time = obj.time;
width_p = round(width/sInterval);
offset_p = round(offset/sInterval);
start = obj.Start;
maxtime = obj.MaxTime;




ind_thisTriggerT = zeros(length(thisTriggerT), 1);


for i = 1:length(thisTriggerT)
    % find nearest time
      ind = find((time - sInterval/2) < thisTriggerT(i) & ...
          (time + sInterval/2) >= thisTriggerT(i), 1, 'first'); 
      if ~isempty(ind)
          ind_thisTriggerT(i) = ind;
      else
          ind_thisTriggerT(i) = NaN;
      end
end

if any(isnan(ind_thisTriggerT))
   warning('K:K_Chan_getSegmentsTriggered:chooseTime',...
       'Some of trigger event failed to find matched time in obj.');
end


ind_startT = ind_thisTriggerT - offset_p; 
ind_endT = ind_thisTriggerT - offset_p + width_p;

for i = 1:length(thisTriggerT)
    
    if ind_startT(i) < 1
        % padding
        padlen = 1 - ind_startT(i);
        
        out = obj;
        out.Data = NaN(padlen, 1); %TODO  impossible!!!
        out = [out; obj]
        
        
    end
    
    if  time(ind_endT(i)) > maxtime
       % padding

    end
    
    out = obj.extractTime(time(ind_startT(i)), time(ind_endT(i)));
    out.Start = 0;
    out.Header.originalStart = start;
    
    
    
    
    
    
    
end














end