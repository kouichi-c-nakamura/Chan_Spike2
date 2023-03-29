function rec = init(rec, varargin)

if all(cellfun(@isempty,varargin))
    % in case contents of cell array (but not the cell array itself) are all empty
    % create an empty Record object
    rec.Chans = cell(0);
    return;
end

%% PV starts

ni = nargin-1; % ni >= 1
DataInputs = 0;
PNVStart = 0;
while DataInputs<ni && PNVStart==0
    nextarg = varargin{DataInputs+1};
    if ischar(nextarg) && isvector(nextarg)
        PNVStart = DataInputs+1;
    else
        DataInputs = DataInputs+1;
    end
end

%% Deal with PV set
% initialize name
if isempty(rec.RecordTitle) %TODO
    rec.RecordTitle = '';
end
if PNVStart>0
    for i=PNVStart:2:ni
        % Set each Property Name/Value pair in turn.
        Property = varargin{i};
        if i+1>ni
            error('K:Record:init:pvsetNoValue', 'no value input for parameter')
        else
            Value = varargin{i+1};
        end
        % Perform assignment
        switch lower(Property)
            case 'name'
                %% Assign the name
                if ~isempty(Value) && ischar(Value)
                    % Name has been specified
                    rec.RecordTitle = Value;
                end
                
            otherwise
                error('K:Record:init:pvsetInvalid', 'invalid parameter')
        end % switch
    end % for
end

%%

if PNVStart >= 2 || PNVStart == 0
    chans = varargin{1};
elseif PNVStart == 1
    
    rec.Chans = cell(0);
    return;
end

vf = @(x) isa(x, 'Chan');

tf = cellfun(vf, chans);

if ~all(tf)
    error(''); % they all have to be Chan
end

%% check if Time vectors are identical among Chans

list.ChanTitle = cell(size(chans))';
list.Start = NaN(size(chans))';
list.SRate = NaN(size(chans))';
list.Length = NaN(size(chans))';
for i = 1:length(chans)
    list.ChanTitle{i} = chans{i}.ChanTitle;
    list.Start(i) = chans{i}.Start;
    list.SRate(i) = chans{i}.SRate;
    list.Length(i) = chans{i}.Length;
end

% summary = struct2dataset(list); % requires Statistics TOOLBOX

%% unique name check
assert(length(unique(list.ChanTitle)) == length(list.ChanTitle),...
    'K:Record:init:ChanTitle', ...
    'ChanTitle must be unique among objects.');

%% time identity check
% assert(all(list.Start(1) == list.Start) && ...
%     all(list.SRate(1) == list.SRate) && ...
%     all(list.Length(1) == list.Length),...
%     'K:Record:init:Time', ...
%     'Time is not identical between objects.');

% store Chan into Record

rec.Chans = chans'; % column vecotr


end