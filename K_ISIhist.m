function [out] = K_ISIhist(target, sInterval, maxInterval, binsize, minInterval, varargin)
%[out] = K_ISIhist(target, sInterval, maxInterval, binsize, minInterval, varargin)
%
%% input arguments
% target ...             a logical or binary column vector for spikes
%                        NaN is not supported. 
% sInterval              the sampling interval [sec] for both target and trigger 
% width ...              in sec
% binsize ...            in sec
% minISIshown ...        in sec (works as an offset to set the left end of the X axis)
%
%% OPTIONAL PARAMETER/VAlUE pairs (varargin)
% 'TargetTitle'         any string
% 'PlotType'            'line'   line drawing for PSTH/correlogram
%                       'hist'   histogram for PSTH/correlogram
% 'Unit'                's'      x axis in second (default)
%                       'ms'     x axis in msec


%% parse mandatory input arguments

narginchk(3, inf);

p = inputParser;


vf1 = @(x) iscolumn(x) &&...
    all(x(x ~= 0) == 1); 
addRequired(p, 'target', vf1);


vf2 = @(x) isscalar(x) &&...
    isnumeric(x) && ...
    x > 0;
addRequired(p, 'sInterval', vf2);

vf3 = @(x) isnumeric(x) &&...
    isscalar(x) && ...
    x > 0 && ...
    x < inf;
addRequired(p, 'maxInterval', vf3);

vf4 = @(x) isnumeric(x) &&...
    isscalar(x) && ...
    x > 0 && ...
    x < inf;
addRequired(p, 'binsize', vf4);

vf5 = @(x) isnumeric(x) &&...
    isscalar(x) && ...
    x >=0 && ...
    maxInterval >= x ;
addRequired(p, 'minInterval', vf5); %OK down to here

parse(p, target, sInterval, maxInterval, binsize, minInterval);


%% parse varargin ... Parameter/Value set

% initialization
target_title = [];
plotAsHist = false;
millisecond = false;

% parse parameter/value pairs
ni = length(varargin); % ni >= 1
PNVStart = 1;
for i=PNVStart:2:ni
    % Set each Property Name/Value pair in turn.
    Property = varargin{i};
    if i+1>ni
        error(eid('options:pvsetNoValue'), 'Value is missing')
    else
        Value = varargin{i+1};
    end
    
    % Perform assignment
    switch lower(Property)
        case 'targettitle'
            %% Assign the value
            if ~isempty(Value) && ischar(Value) && isrow(Value)
                % Name has been specified
                target_title = Value;
            else
                error(eid('options:TargetTitle:invalid'), 'TargetTitle value invalid')
            end
        case 'plottype'
            if ~isempty(Value) && ischar(Value) && isrow(Value)
                Value = validatestring(Value, {'line', 'hist'});
                if strcmpi(Value, 'line');
                    plotAsHist = false;
                elseif strcmpi(Value, 'hist');
                    plotAsHist = true;
                else
                    error(eid('options:PlotType:invalid'), 'PlotType value invalid')
                end
            else
                error(eid('options:PlotType:invalid'), 'PlotType value invalid')
            end    
        case 'unit'
            if ~isempty(Value) && ischar(Value) && isrow(Value)
                if strcmpi(Value, 's');
                    millisecond = false;
                elseif strcmpi(Value, 'ms');
                    millisecond = true;
                else
                    error(eid('options:Unit:invalid'), 'Unit value invalid')
                end
            else
                error(eid('options:Unit:invalid'), 'Unit value invalid')
            end
        otherwise
            error(eid('option:pvsetInvalid'), 'Parameter and values are invalid')
    end % switch
end % for

%% job starts here

target = int8(full(target)); % to save memory, use int8
ind = find(target);
timestamps = ind * sInterval;

if millisecond
    timestamps = timestamps .* 1000;
end

ISI = diff(timestamps);

edges = minInterval:binsize:maxInterval;

if millisecond
    edges = edges .* 1000;
end

[n, bin] = histc(ISI, edges); % the core code


fig1 = figure;
ax1 = axes;

if plotAsHist
    h1 = bar(ax1, edges, n);
elseif ~plotAsHist
    h1 = plot(ax1, edges, n);
end

if ~millisecond
    xlim([minInterval, maxInterval]);
    xlabel('ISI [sec]');
elseif millisecond
    xlim([minInterval*1000, maxInterval*1000]);
    xlabel('ISI [msec]');
end
ylabel('Counts');
title(sprintf('ISI histogram: %s', target_title));
set(ax1, 'TickDir', 'out', 'Box', 'off');


out.n = n;
out.bin = bin;
out.edges = edges;
out.fig1 = fig1;
out.ax1 = ax1;
out.h1 = h1;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K:
%
%
% input argument
% str (Optional) string in char type (row vector)
%
% output argument
% eid an error id composed of 'K:(functionname):str'

narginchk(0, 1);
p = inputParser;
p.addOptional('str', '', @(x) isempty(x) || ischar(x) && isrow(x));
p.parse(varargin{:});
str = p.Results.str;

if isempty(str)
str = '';
else
str = [':', str];
end

[~,m,~] = fileparts(mfilename('fullpath'));

eid = ['K:', m, str];


end