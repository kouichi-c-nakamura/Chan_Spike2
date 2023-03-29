function [t, points] = nextSpike(obj, current_time)
% nextSpike method returns next event in time and data points
%
% [t, points] = nextSpike(obj, current_time)
%
% See also
% MetaEventChan.prevSpike

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

t = obj.TimeStamps(find( (current_time <= obj.TimeStamps), 1, 'first'));

points = find(obj.time == t, 1, 'first'); % TODO need test
if isempty(points)
    warning('Koichi:MetaEventChan:nextSpike:points','points not found');
end


end