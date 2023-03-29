function [ outdata ] = K_trigger( data, trigger, varargin)
% K_trigger retuns array data for event-triggered analyses
% 
% SYNTAX
% outdata = K_trigger( data, trigger, width, offset, newFs)
%
% outdata = K_trigger( {rec1, rec2, ...}, {metaeventchan1, metaeventchan2,...}, ...)
% outdata = K_trigger( {rec1, rec2, ...}, {timestamps1, timestamps2,...}, ...)
%
% outdata = K_trigger( {Chan1, Chan2, ...}, {metaeventchan1, metaeventchan2,...}, ...)
% outdata = K_trigger( {Chan1, Chan2, ...}, {timestamps1, timestamps2,...}, ...)
%
% outdata = K_trigger( rec1,, metaeventchan1, ...)
% outdata = K_trigger( rec1, timestamps1, ...)
%
% outdata = K_trigger( Chan1, metaeventchan1, ...)
% outdata = K_trigger( Chan1, timestamps1, ...)
%
% outdata = K_trigger(___, width, offset, newFs)
%
%
% outdata = K_trigger(_________________, 'Time','triggerzero')
% outdata = K_trigger(_________________, 'Time','original')
%
% INPUT ARGUMENTS
%   data           a Record object, a Chan object or a
%                  row vector of cell array containing either of these objects
%
%
%   trigger        One of the following is allowed.
%                  1. a column vector of timestamps
%                  2. a row vector of cell containing column vectors of
%                  timestamps, 
%                  3. a row vector of cell containg MetaEventChan objects.
%
%                  The size of the cell array for tirgger must match the
%                  size of the cell array for data. 
%
%
%   width          in seconds (default: 1)
%                  Defines the duration of segments outdata
%
%   offset         in seconds (default: 0.5)
%                  Positive value defines the interval from the beggining
%                  of segments to the triggers and the window contains the
%                  trigger. Negative value means the window starts after
%                  the trigger. If offset > width or offset < 0, the
%                  trigger events are not included in the segments outdata
%
%   newFs          new sampling rate for resample  [Hz](default: 1024)
%                  If you want to keep the original sampling rate Fs, use
%                  Fs as newFs.
%
%
% OPTIONAL PARAM/VAL PAIRS
%
% 'Time'           'triggerzero'    trigger is set to time zero for each   %TODO
%                                   element of output
%
%                  'original'       Original time is maintained in each    %TODO
%                                   element of output. You need to use the
%                                   offset parameter to specify the
%                                   trigger.
%
% 'TimeVector'     column vector for time stamps of all the datapoints
%
% OUTPUT ARGUMENTS
% outdata          A row vector of cell array
%
%                  All the element of cell array contains Record
%                  objects or Chan objects depending on the syntax.
%
%                  These Record or Chan objects are triggered segments whose with
%                  width and offset and Start property is set to - offset.
%
%                  Non-existing data are padded with NaNs. (NOTE: To
%                  support the case one file contains mulitiple trigger
%                  points, structure format whose field names are objects'
%                  ChanTitle property is not useful.)
%
%                  For convinience, for each object obj in output, the
%                  original Start time and offset are stored in the
%                  following, respectively.
%
%                      obj.Header.originalstart
%                      obj.Header.triggeroffset 
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 10-Oct-2020 11:19:00
%
% See also
% K_trigger_test, extractTime, eventTriggeredAverage, WaveformChan.plotTriggered


% warning('K_trigger is not recommended. Use eventTriggeredAverage instead.')

%% parse

narginchk(2, 7);

p = inputParser;

vf_data = @(x) ( iscell(x) && isrow(x) &&...
    (all(cellfun(@(y) isa(y, 'Record'), x)) || all(cellfun(@(y) isa(y, 'Chan'), x))) ) ||... group input as a cell
    ( ~iscell(x) && isa(x, 'Record') ||  isa(x, 'Chan')) ; % single input

addRequired(p, 'data', vf_data);

vf_trigger = @parse_trigger;

addRequired(p, 'trigger', vf_trigger);


vf_width = @(x) isscalar(x) && isnumeric(x) &&...
    x > 0;

addOptional(p, 'width', 1, vf_width);


vf_offset = @(x) isscalar(x) && isnumeric(x) &&...
    isreal(x);

addOptional(p, 'offset', 0.5, vf_offset);

vf_newFs = @(x) isscalar(x) && fix(x) == x && ~isnan(x) && x > 0;

addOptional(p, 'newFs', 1024, vf_newFs);

addParameter(p, 'Time', 'triggerzero', @(x) ischar(x) && isrow(x) && ...
    ismember(lower(x), {'triggerzero','original'}));

addParameter(p, 'TimeVector', zeros(1,0),  @(x) iscolumn(x) && isreal(x));

parse(p, data, trigger, varargin{:});

width = p.Results.width;
offset = p.Results.offset;
newFs = p.Results.newFs;
timemode = lower(p.Results.Time);
timeVector = p.Results.TimeVector;

if iscell(data) && ~iscell(trigger) ||...
        ~iscell(data) && iscell(trigger)
    error(eid('data_trigger:cellornot'),...
        'data and trigger must be both row vectors of cell, or both not to be cell.');
end

if iscell(data) && iscell(trigger)
    if length(data) ~= length(trigger)
        error(eid('data_trigger:length_mismatch'),...
            'data and trigger must have the same length as cell arrays');
    end
end

if ~iscell(data)
    % store them into cells
    
    data = {data};
    trigger = {trigger};
    
end


% check if data and trigger share the same Time vector
triggerAsObj = false;
if iscell(trigger) && isa(trigger{1}, 'MetaEventChan')
    triggerAsObj = true;
elseif ~iscell(trigger) &&  isa(trigger, 'MetaEventChan')
    triggerAsObj = true;
end

if iscell(trigger)
    if isa(trigger{1}, 'MetaEventChan')
        for i = 1:length(trigger)
            validateDataTrigger(data{i}, trigger{i}, i);
        end
    end
else
    if isa(trigger, 'MetaEventChan')
        validateDataTrigger(data, trigger, 0);
    end
end


%% prep


n_trig = countNumberOfTriggers(trigger);
%TODO allow or ban overlap between segments? Take care of it later.

[data, trigger] = local_resample(data, trigger, newFs, triggerAsObj);

if triggerAsObj
    trigger = triggerAsTimeStamps(trigger, length(data));
end


%% process

seg = cell(1, n_trig);
k = 0; % trigger point id
for i = 1:length(data)
    for j = 1:length(trigger{i})
        k = k + 1;
  
        seg{k} = local_extract(data{i}, trigger{i}(j), width, offset, timemode, timeVector);

    end
end


%TODO
% seg{1}.plot; %OK
% seg{2}.plot; %OK
% seg{3}.plot; %OK
% seg{4}.plot; %TODO

outdata = seg;



end

%--------------------------------------------------------------------------

function trigger = triggerAsTimeStamps(trigcellobj, len)
% trigcellobj    cell array for trigger containing MetaEventChan object(s)
%
% trigger        (output) a column of timestamps or a row vector of cell array
%                containing those timestamps as column vectors
%
% convert trigger as an MetaEventChan object to timestamps

%% parse
narginchk(2,2);

p = inputParser;

vf_trigcellobj = @(x) isa(x, 'DisceteData');

addRequired(p, 'trigobj', vf_trigcellobj);

vf_len = @(x) ~isempty(x) && (fix(x) == x) && x > 0;

addRequired(p, 'len', vf_len);

%% job

trigger =cell(1, len);
for i = 1:len
    trigger{i} = trigcellobj{i}.TimeStamps;
end

end

%--------------------------------------------------------------------------

function [data, trigger] = local_resample(data, trigger, newFs, triggerAsObj)
% resample data and trigger to newFs

for i = 1:length(data)
    if newFs ~= data{i}.SRate
        data{i} = data{i}.resample(newFs);
        
        if triggerAsObj
            trigger{i} = trigger{i}.resample(newFs);
        end
    end
end

end

%--------------------------------------------------------------------------

function n_trig = countNumberOfTriggers(trigger)
% get the number of tigger events

triggerAsObj = false;
if isa(trigger{1}, 'MetaEventChan')
    triggerAsObj = true;
end


n_trig = 0;

if triggerAsObj
    
    for i = 1:length(trigger)
        n_trig = n_trig + length(trigger{i}.TimeStamps);
    end
    
elseif ~triggerAsObj
    for i = 1:length(trigger)
        n_trig = n_trig + length(trigger{i});
    end
end
end

%--------------------------------------------------------------------------

function validateDataTrigger(data, trigger, i)
% check if the formats of data and tigger are matched.

if data.Start ~= trigger.Start
    if i ~= 0
        error(eid('data_trigger:mismatch:Start'),...
            'data{%d} and trigger{%d} must have the same Start properties.', i);
    else
        error(eid('data_trigger:mismatch:Start'),...
            'data and trigger must have the same Start properties.');
    end
end
if data.SRate ~= trigger.SRate
    if i~= 0
        error(eid('data_trigger:mismatch:SRate'),...
            'data{%d} and trigger{%d} must have the same SRate properties.', i);
    else
        error(eid('data_trigger:mismatch:SRate'),...
            'data and trigger must have the same SRate properties.');
    end
end
if data.Length ~= trigger.Length
    if i ~= 0
        error(eid('data_trigger:mismatch:Length'),...
            'data{%d} and trigger{%d} must have the same Length properties.', i);
    else
        error(eid('data_trigger:mismatch:Length'),...
            'data and trigger must have the same Length properties.');
    end
    
end
end

%--------------------------------------------------------------------------

function segment = local_extract(obj, thistrigger, width, offset, timemode, timeVector)
% segments Chan objects for time at thistrigger with width and
% offset

%% parse
if thistrigger < 0 || thistrigger > obj.MaxTime
    warning(eid('local_extract:triggerOutOfRange'),...
        'trigger %f is out of range of data %s', thistrigger, obj.ChanTitle);
end

%% job

if isa(obj,'Record')
    segment = obj.extractTime(thistrigger - offset, thistrigger - offset + width, 'extend');
else
    segment = obj.extractTime(thistrigger - offset, thistrigger - offset + width, 'extend', timeVector);    
end

if isa(segment, 'Chan')
    segment.Header.originalstart = segment.Start;
    segment.Header.triggeroffset = offset;

elseif isa(segment,'Record')
    
    
    for i = 1:length(segment.Chans)
        segment.Chans{i}.Header.originalstart = segment.Start;
        segment.Chans{i}.Header.triggeroffset = offset;
        
    end
end


switch timemode
    case 'triggerzero' 
        segment.Start = - offset; %TODO
    case 'original'
        % keep it!
end
        

end

%--------------------------------------------------------------------------

function tf = parse_trigger(x)

if iscell(x) && isrow(x)
    % a row vector of cell arrays
    if all(cellfun(@(y) isa(y, 'MetaEventChan'), x))
        % containing DicreteData objects
        
        tf = true;
        
    elseif all(cellfun(@(y) iscolumn(y) , x)) && ...
            all(cellfun(@(y) isreal(y) , x)) && ...
            ~any(cellfun(@(y) any(isnan(y)) , x)) && ...  exclude NaN
            all(cellfun(@(y) all(diff(y) > 0), x )) 
        % containing column vectors of monotonically increasing timestamps
    
        tf = true;
        
    else
        tf = false;
    end
elseif ~iscell(x)
    
    if isa(x, 'MetaEventChan') && isscalar(x)
        % a DicreteData object
        
        tf = true;
        
    elseif iscolumn(x) &&  all(diff(x) > 0)
        % a column vector of monotonically increasing timestamps
        
        tf = true;
        
    else
        tf = false;
    end
    
else
    
    tf = false;
    
end

end

%--------------------------------------------------------------------------

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

