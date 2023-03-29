classdef EventChan < MetaEventChan
    %EventChan is a subclass of MetaEventChan, which in turn is a subclass
    %of Chan class. EventChan class can store time series data
    %Data in event format with an uniform Time vector.
    %
    %
    % properties
    %
    % Data
    %
    % Although actual event data is stored in sparse matrix (16 bit) format
    % implicitly, Data that you can see at run-time is in the usual double
    % (64 bit) format, so you shouldn't have to worry about the format.
    % Because sparse matrix only holds non-zero elements and their indices,
    % this is very much disk space-efficient for recordings of neuronal
    % activities. However, note that because of the overhead for this
    % storage method, frequently modifying Data will be quite slow. Also,
    % repeative calling of Data and other dependent properties can be slow.
    % Rather, you should store data in variables in memory to avoid
    % repeatitive access.
    %
    % When you export data from Spike2, choose "Align and bin all data at
    % ..." option. Then, the constuctor of EventChan class can convert it
    % into sparse matrix for storage.
    %
    %
    % Time
    % Time is a uniform vector of time (double) in second. Time vector is
    % generated at run-time with start, SRate, and Length properties to
    % reduce disk space requirement. Data and Time have the same Length.
    %
    %
    % ISI       length(ISI) == EventChan.Length + 1
    %
    %           ISI(1) == time interval between the beginning of Time and the
    %           first spike
    %
    %           ISI(2:end-1) == time interval between spikes
    %
    %           ISI(end) == time interval between the last spike and the end of
    %           Time
    %
    %           Note that if you only want to use genuine ISIs, you need to
    %           subtract ISI(2:end-1). ISI(0) and ISI(end) are useful in
    %           terms of ISI-based LTS burst detection etc, but should not
    %           be used for actual ISI statistics.
    %
    % Written by Kouichi C. Nakamura Ph.D.
    % MRC Brain Network Dynamics Unit
    % University of Oxford
    % kouichi.c.nakamura@gmail.com
    % 15-Aug-2017 15:23:33
    %
    % See Also 
    % Chan, Record, WaveformChan, MetaEventChan,
    % MarkerChan
    
    
    
    
    
    properties (GetAccess = private, SetAccess = protected, Hidden)
        % SetAccess = protected is important for constructors of subclasses
        DataSparse = sparse([]);
    end
    
    properties (Dependent = true)
        Data % Binary vector (0 or 1) of event data in double format. Data has the same length as the Time. Although actual event data is stored in a sparse matrix implicitly, double-format Data is generated at run-time.
    end
    
%     properties (Dependent = true, SetAccess = protected)
%         SpikeInfo % dataset spreadsheet for all events
%     end
    
    methods
        function obj = EventChan(varargin)
            %obj = EventChan(data, start, srate, chantitle)
            %obj = EventChan(struct)
            %obj = EventChan(chanInfo)
            %
            % Constructs an EventChan object. All four input arguments are
            % optional.
            % data      a column vector of 0 and 1. Default is [].
            %
            % start     a scalar number equal to or larger than 0. Default
            %           is 0.
            % srate     Sampling rate [Hz]. A positive scalar number. Default is
            %           1 Hz.
            % ChanTitle ChanTitle of EventChan. Could be different from the
            %           variable name. Default is ''.
            %
            % struct    Instead of specifying each parameters, you can
            %           simply use Struct exported by Spike2 as a sole input.
            %           Struct must contain 'values' field holding
            %           0 or 1 data of an event channel.
            %
            % chanInfo  an object of ChanInfo class that hold file path
            %           (.Path) of a .mat file that contains Spike2 struct
            %
            % See Also EventChan
            
            %% parse inputs
            narginchk(0,4);
            
            info = ChanInfo();
            
            info.Start = 0;
            info.SRate = 1;
            info.ChanTitle = '';
            
            p = inputParser;
            aO = @addOptional;
            vf_data = @(x) iscolumn(x) &&...
                ( islogical(x) || isnumeric(x) &&...
                (isempty(x) || all(x(x ~= 0) == 1)) );
            
            if  nargin ==0 || ~isa(varargin{1}, 'struct') ...
                    &&  ~isa(varargin{1}, 'ChanInfo') ...
              
                vf_start = @(x) isa(x, 'double') &&...
                    isscalar(x) &&...
                    isreal(x) &&...
                    ~isnan(x) ; % accept minus value
                
                vf_srate = @(x) isa(x, 'double') &&...
                    isscalar(x) &&...
                    isreal(x) &&...
                    x > 0;
                
                vf_name = @(x) ischar(x) &&...
                    isrow(x) || isempty(x);
                
                aO(p, 'data', [], vf_data);
                aO(p, 'start', 0, vf_start);
                aO(p, 'srate', 1, vf_srate);
                aO(p, 'chantitle', '', vf_name);
                
                parse(p, varargin{:});
                
                %% job
                
                obj.Data = p.Results.data;
                info.Start = p.Results.start;
                info.SRate = p.Results.srate;
                info.ChanTitle = p.Results.chantitle;
                info.Length = size(obj.Data,1);
                
            elseif isa(varargin{1}, 'struct')
                narginchk(1,1);
                
                S = varargin{1};
                
                if ~ChanInfo.vf_structEvent(S)
                   error('K:Chan:EventChan:EventChan:struct:invalid',...
                       'struct doesn''t seem struct format for Spike2 event data');
                end
                
                obj.Data = S.values;
                info.Start = S.start;
                info.SRate = 1/S.interval;
                info.ChanTitle = S.title;
                info.Header = rmfield(S, 'values');
                info.Length = size(obj.Data,1);

                
            elseif  isa(varargin{1}, 'ChanInfo')
                narginchk(1,1);
                              
                info = varargin{1}; % ChanInfo
                s = load(info.Path, info.ChanStructVarName);
                S = s.(info.ChanStructVarName);
                clear s;
                
                obj.Data = S.values;
                info.Start = S.start;
                info.SRate = 1/S.interval;
                info.ChanTitle = S.title;
                
                info.Header = rmfield(S, 'values'); %TODO
                info.Length = size(obj.Data,1);

                
            end
            
            obj.ChanInfo_ = info; 
            
        end
        
        function Data = get.Data(obj)
            Data = full(obj.DataSparse);
        end
        
        function obj = set.Data(obj, newdata)
            
            %% parse inputs
            narginchk(2,2);
            
            if isempty(newdata)
                obj.DataSparse = sparse([]);
                return;
            end
            
            p = inputParser;
            vf1 = @(x) iscolumn(x) &&...
                ( islogical(x) || isnumeric(x) &&...
                (isempty(x) || all(x(x ~= 0) == 1)) );
            addRequired(p, 'newdata', vf1);
            parse(p, newdata);
            
            %% job
            if islogical(newdata) % added on 11/25/2013
                newdata = double(newdata);
            end
            
            obj.DataSparse = sparse(newdata);
            
            
            info = obj.ChanInfo_;
            info.Length = size(newdata,1);
            obj.ChanInfo_ = info;
        end
        
        
        function spikeInfo = getSpikeInfo(obj)
            % spikeInfo    Table data containing the spec of each spike/event
            %
            % VARIABLES
            %  id           x th spike
            %
            %  point        data point index
            %
            %  time         time in second
            %
            %  ISIbef       ISI before this spike 
            %               for the first spike, interval between 0 to the first spike
            %
            %  ISIaft       ISI after this spike
            %               for the last spike, interval between the last spike
            %               to the end of the file
            %
            %  InstantRate  inverse of spikeInfo.ISIbef 
            
            if ~isempty(obj.Data)
                
                spikeind = find(obj.Data);
                c = cell([length(spikeind), 1]);
                zero = num2cell(zeros(size(c)));
                
                S = struct('id', zero,...
                    'point', c,...
                    'time', c,...
                    'ISIbef', c,...
                    'ISIaft', zero,...
                    'InstantRate',zero);
                clear c zero;
                
                id = num2cell(1:length(spikeind));
                [S(:).id] = id{:};
                
                point = num2cell(spikeind);
                [S(:).point] = point{:};
                
                time = num2cell(obj.TimeStamps);
                [S(:).time] = time{:};
                
                ISI = obj.ISI;
                
                if ~isempty(obj.Data)
                    
                    TimeStamps = obj.TimeStamps;
                    
                    if ~isempty(TimeStamps)
                        ISIplus = [TimeStamps(1) - obj.Start;
                            ISI;
                            obj.MaxTime - TimeStamps(end)];
                    else
                        ISIplus = [];
                    end
                    
                else
                    ISIplus = [];
                end
                
                ISIbef = num2cell(ISIplus(1:end-1));
                [S(:).ISIbef] = ISIbef{:};
                
                ISIaft = num2cell(ISIplus(2:end));
                [S(:).ISIaft] = ISIaft{:};
                
                InstantRate = num2cell(1./ISIplus(1:end-1));
                [S(:).InstantRate] = InstantRate{:};
                
                spikeInfo = struct2table(S);
                
            else
                spikeInfo = [];
            end
            
        end
        
        
        function obj2 = resample(obj, newRate, varargin)
            % obj2= resample(obj, newRate)
            % obj2= resample(obj, newRate, 'ignore')
            %
            %
            % the length of resmaple(x, p, q) is defined as follows:
            % ceil(length(x)*p/q)
            %
            % The 'ignore' option will ignore the case when multiple events
            % fall into single bins and treat all the events per single bin
            % as a single event (and thus lose some close events)
            
            p=inputParser;
            p.addRequired('obj');
            p.addRequired('newRate');
            p.addOptional('modestr','normal',@(x) ismember(x, {'normal','ignore'}));
            p.parse(obj,newRate,varargin{:});
            
            modestr = p.Results.modestr;
            
            outlen = ceil(obj.Length*newRate/obj.SRate);
            
            newdata = timestamps2binned(obj.TimeStamps, obj.Start, ...
                obj.Start + 1/newRate*(outlen - 1), newRate,modestr);
            if isrow(newdata)
                newdata = newdata';
            end
            obj2 = EventChan(newdata, obj.Start, newRate, obj.ChanTitle);
            obj2.DataUnit = obj.DataUnit;
            obj2.Header = obj.Header;
        end
        
        function struct = chan2struct(obj, varargin)
            % struct = chan2struct(obj, format)
            %
            % format    optional string
            %           'binned' (default), 'timestamp' 

             %% parse
            narginchk(1,2);
            
            p = inputParser;
            
            vf_format = @(x) ischar(x) && ...
                isrow(x) && ...
                any(strcmpi(x, {'binned','timestamp'}));
            
            addOptional(p, 'format', 'binned', vf_format);
            
            parse(p, varargin{:});
            
            format = p.Results.format;
            
            %% job
            
            header = obj.Header;
            
            if ~isempty(header)
                if isfield(header, 'title')
                    header = rmfield(header, 'title');
                end
                if isfield(header, 'comment');
                    header = rmfield(header, 'comment');
                end
                if isfield(header, 'interval');
                    header = rmfield(header, 'interval');
                end
                if isfield(header, 'start')
                    header = rmfield(header, 'start');
                end
                if isfield(header, 'length')
                    header = rmfield(header, 'length');
                end
            end
            
            switch lower(format)
                case 'binned'
                    struct.title = obj.ChanTitle;
                    if isempty(header)
                        struct.comment = 'No comment';
                    else
                        struct.comment = obj.Header.comment;
                    end
                    struct.interval = obj.SInterval;
                    struct.start = obj.Start;
                    struct.length = obj.Length;
                    
                    struct.values = obj.Data;
                case 'timestamp'
                    struct.title = obj.ChanTitle;
                    if isempty(header)
                        struct.comment = 'No comment';
                    else
                        struct.comment = obj.Header.comment;
                    end
                    
                    struct.resolution = obj.SInterval;
                    struct.length = length(obj.TimeStamps); 
                    struct.times = obj.TimeStamps; 
            end
            
            %% save the other fields of Header property
            if ~isempty(header)
                finames = fieldnames(header);
                
                for i = 1:length(finames)
                    struct.(finames{i}) = header.(finames{i});
                end
            end
            
        end
        
        function s = saveobj(obj)
            s.ChanInfo_ = obj.ChanInfo_;
            s.DataSparse = obj.DataSparse;
            
        end
        
        %
        %         function plotMeanFiringRate(obj, timewidth)
        %             %TODO
        % % % The mean frequency is calculated at each event by counting the number
        % % of events in the previous period set by Bin size. The result is measured
        % % in units of events per second unless the Per minute box is checked. The
        % % mean frequency at the current event time is given by:
        % %
        % % (n-1)/(te-tl)        if (te-t1) > tb/2 n/tb                if (te-t1) <=
        % % tb/2
        % %
        % % where:
        % %
        % % tb is the bin size set, te is the time of the current event, t1 time of
        % % the first event in the time range and n is the events in the time range
        % %
        % % A constant input event rate produces a constant output until there are
        % % less than two events per time period. You should set a time period that
        % % would normally hold several events.
        %
        %         end
        %
        %         function plotInstantRate(obj)
        %             %TODO easy to implement
        %         end
        %
        %         function plotRateHistogram(obj, timewidth)
        % %  Rate mode counts how many events fall in each time period set by the
        % %  Time width field, and displays the result as a histogram. The result is
        % %  not divided by the bin width. This form of display is especially useful
        % %  when the event rate before an operation is to be compared with the event
        % %  rate afterwards.
        %         end
        
    end
    
    methods (Static)
        function chanout = ts2chan(ts) %OK
            p = inputParser;
            vf = @(x) isa(x, 'timeseries');
            addRequired(p, 'ts', vf);
            parse(p, ts);
            
            sInterval = ts.TimeInfo.Increment;
            if isempty(sInterval)
                sInterval = (ts.Time(end) - ts.Time(0))/(ts.Length - 1);
            end
            
            chanout = EventChan(ts.Data, ts.Time(1), 1/sInterval, ts.Name);
            chanout.Header = ts.UserData;
            
        end
        
        function obj = loadobj(s)
            
           obj = EventChan;
           obj.ChanInfo_ = s.ChanInfo_;
           obj.DataSparse = s.DataSparse;
            
        end
        
    end
    
end