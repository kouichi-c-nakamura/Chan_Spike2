function obj = init(obj, varargin)

if all(cellfun(@isempty,varargin))
    % in case contents of cell array (but not the cell array itself) are all empty
    % create an empty Record object
    obj.ChanInfos = cell(0);
    return;
end


%% PV starts
if nargin <= 2
    PNVStart = 0;
else
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
    if isempty(obj.RecordTitle)
        obj.RecordTitle = '';
    end
    if PNVStart>0
        for i=PNVStart:2:ni
            % Set each Property Name/Value pair in turn.
            Property = varargin{i};
            if i+1>ni
                error('K:RecordInfo:init:pvsetNoValue', 'no value input for parameter')
            else
                Value = varargin{i+1};
            end
            % Perform assignment
            switch lower(Property)
                case 'name'
                    %% Assign the name
                    if ~isempty(Value) && ischar(Value)
                        obj.RecordTitle = Value;
                    end
                    
                otherwise
                    error('K:RecordInfo:init:pvsetInvalid', 'invalid parameter')
            end % switch
        end % for
    end
end

%% 

if PNVStart >= 2 || PNVStart == 0
    chaninfos = varargin{1};
    
elseif PNVStart == 1
    obj.ChanInfos =cell(0);
    return;
end


%% check class of input args
if iscell(chaninfos) && all(cellfun(@(x) isa(x, 'Chan'), chaninfos))
        
    chans = chaninfos;
    chaninfos = cell(length(chans), 1);
    
    for i = 1:length(chans)
        chaninfos{i} = chans{i}.getChanInfo();
    end
    clear chans
    
elseif iscell(chaninfos) && all(cellfun(@(x) isa(x, 'ChanInfo'), chaninfos))
    % OK
elseif ischar(chaninfos) && isrow(chaninfos) && ismatchedany(chaninfos, '.mat$')
    % obj = RecordInfo(matfilename)
    
    chs = Record(chaninfos);
    obj = chs.getRecordInfo;
    return
else
    error('K:RecordInfo:init:inputArg:notChanOrChanInfoObj',...
        'Input arguments of Record must be either a cell vector of Chan or ChanInfo objects');
end



%% check if Time vectors are identical between ChanInfos
list.ChanTitle = cell(size(chaninfos))';
list.Start = NaN(size(chaninfos))';
list.SRate = NaN(size(chaninfos))';
list.Length = NaN(size(chaninfos))';
for i = 1:length(chaninfos)
    list.ChanTitle{i} = chaninfos{i}.ChanTitle;
    list.Start(i) = chaninfos{i}.Start;
    list.SRate(i) = chaninfos{i}.SRate;
    list.Length(i) = chaninfos{i}.Length;
end

summary = struct2table(list);

%% check uniqueness of ChanTitle of Chan objects
if length(unique(summary.ChanTitle)) ~= length(summary.ChanTitle)
    error('K:Record:init:ChanTitle', ...
        'ChanTitle must be unique among objects.');
    
end

%% check time identity among ChanInfos
if any(summary.Start(1) ~= summary.Start)|| ...
        any(summary.SRate(1) ~= summary.SRate) || ...
        any(summary.Length(1) ~= summary.Length)
    error('K:Record:init:Time', ...
        'Time is not identical between objects.');
end

%% store ChanInfo objects into RecordInfo

if isrow(chaninfos)
    chaninfos = chaninfos';
end

obj.ChanInfos = chaninfos;% column vector



end