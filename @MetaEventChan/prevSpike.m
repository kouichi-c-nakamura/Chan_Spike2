function [t, points] = prevSpike(obj, current_time)
% prevSpike method returns previous event in time and data points
%
% [t, points] = prevSpike(obj, current_time)
%
% See also
% MetaEventChan.nextSpike

%% parse inputs

narginchk(2, 2);

p = inputParser;
vf1 = @(x) isa(x, 'MetaEventChan');
vf2 = @(x) isnumeric(x) &&...
    isscalar(x) &&...
    obj.Start < x &&...
    x < obj.MaxTime;
addRequired(p, 'obj', vf1);
addRequired(p, 'current_time', vf2);
parse(p,obj, current_time);

%% job

t = obj.TimeStamps(find( (current_time >= obj.TimeStamps), 1, 'last'));

points = find(obj.time == t, 1, 'first');  % TODO need test
if isempty(points)
    warning('Koichi:MetaEventChan:prevSpike:points','points not found');
end
end