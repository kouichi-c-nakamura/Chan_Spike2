classdef MarkerChan < MetaEventChan
    %MarkerChan is a subclass of MetaEventChan, which in turn is a subclass
    %of Chan class. MarkerChan class can store time series data
    %Data in marker or textmark format with an uniform Time vector.
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
    % When you export marker/textmark channels from Spike2, you CANNOT
    % choose "Align and bin all data at ..." option to keep marker codes
    % information. Thus, marker/textmark channels need to be exported
    % separately into timestamp format without binning. Then, the
    % constuctor of MarkerChan class can convert it into sparse matrix for
    % storage.
    %
    % Time
    % Time is a uniform vector of time (double) in second. Time vector is
    % generated at run-time with Start, SRate, and Length properties to
    % reduce disk space requirement. Data and Time have the same Length.
    %
    %
    % Written by Kouichi C. Nakamura Ph.D.
    % MRC Brain Network Dynamics Unit
    % University of Oxford
    % kouichi.c.nakamura@gmail.com
    % 15-Aug-2017 15:25:46
    %
    % See Also 
    % MarkerChan_test, Chan, Record, WaveformChan, MetaEventChan,
    % EventChan
    
    properties (GetAccess = protected, SetAccess = protected, Hidden)
        Data_ % 6 columns; Data_(:,1), index for all events; Data_(:,2:5), Four MarkerCodes for all ; Data_(:,6), TextMark for all
    end
    
    properties (Dependent = true)
        Data % can be filtered
    end
    
    properties (Dependent = true, SetAccess = protected)
        % SpikeInfo % table spreadsheet for all visible events with MarkerFilter
        % SpikeInfoAll % table spreadsheet for all events
        IsMarkerFilterOn logical % true or false.
        %TODO IsMarkerFilterOn = true causes an error when loading saved object
    end
    
    properties (SetAccess = public) % (SetAccess = protected)
        MarkerFilter % ON/OFF states for all four marker codes
        % This property affects the following properties.
        %         IsMarkerFilterOn
        %         VisibleSpikes_
        %         Data
        %         NSpikes
        %         MarkerCodes
        %         TextMark
        %         SpikeInfo
    end
    
    properties (SetAccess = private)
        MarkerName table = array2table(repmat({'unnamed'}, 256, 4),...
            'VariableNames',{'mask0','mask1','mask2','mask3'},...
            'RowNames',strcat(repmat({'value'},256,1), num2str((0:255)','%-d'))); % You can set names for each marker codes
    end
    
    properties (Hidden, SetAccess = private, Dependent)
        VisibleSpikes_
        NSpikesAll_
    end
    
    %% Related to each event/spike
    properties (SetAccess = public)
        TextMark (:, 1) % can be filtered; TextMark strings
    end
    
    properties (SetAccess = public)
        MarkerCodes = array2table(uint8(zeros(0,4)),'VariableNames',{'code0','code1','code2','code3'}); % can be filtered; MarkerCodes(i , j) , i th spike, j code0 to code3
    end
    
    
    %%
    methods
        
        function obj = MarkerChan(varargin)
            % obj = MarkerChan(data, start, srate, codes, chantitle);
            % obj = MarkerChan(StructMark, StructBinned);
            %
            % obj = MarkerChan(data, start, srate, chantitle);
            %
            %
            % INPUT ARGUMENTS
            % data        a column vector of 0 and 1. Default is [].
            %
            % start       a scalar number equal to or larger than 0. 
            %             Default is 0.
            %
            % srate       Sampling rate [Hz]. A positive scalar number. 
            %             Default is 1 Hz.
            %
            % codes       NSpikes by 4 array of integers (0 to 255)
            %
            %               size(codes) == [NSpikes, 4]
            %
            %             Values must be numeric 0 to 255
            %             Raws correspond to non-zeor data points in order.
            %             Elements outside the range will be ignored with
            %             a warning.
            %             If the size is smaller than NSpikes x4, gaps will
            %             be filled with 0
            %
            %             See "Marker Filter" and "MarkMask()" in Spike2
            %             documentation for more details     
            %             
            % chantitle   string
            %
            % StructMark  structure containg a marker channnel data
            %             prepared by Spike2 FileSaveAs function with
            %             "BinFreq=0|MarkAs=1" option or a textmark channel
            %             data with "BinFreq=0|TMarkAs=2" option
            %
            % StructBinned  
            %             structure containing binned output from the same
            %             data file as StructMark but with BinFreq larger than 0.
            %             This is required to get start, interval, and
            %             length fields. Actual data in
            %
            %             StructBinned.values will not be used.
            %             StructBinned.start     double
            %             StructBinned.interval  double, > 0
            %             StructBinned.length    positive integer
            %
            % See Also 
            % MarkerChan
            
            
            %% parse input arguments
            narginchk(0,5);
            
            info = ChanInfo();
            
            info.Start = 0;
            info.SRate = 1;
            info.ChanTitle = '';
            
            p = inputParser;
            aO = @addOptional;
            aR = @addRequired;
            
            vf_data = @(x) iscolumn(x) &&...
                ( islogical(x) || isnumeric(x) &&...
                (isempty(x) || all(x(x ~= 0) == 1)) );
            
            vf_start = @(x) isa(x, 'double') &&...
                isscalar(x) &&...
                isreal(x) &&...
                ~isnan(x) ; % accept minus value
            
            vf_srate = @(x) isa(x, 'double') &&...
                isscalar(x) &&...
                isreal(x) &&...
                x > 0;
            
            if  nargin ==0 || ~isa(varargin{1}, 'struct')
                %% parse
                vf_codes = @(x) isnumeric(x) &&...
                    ismatrix(x) &&...
                    all(all(x >= 0)) &&...
                    all(all(x <=255)) &&...
                    all(all(fix(x) == x));
                
                vf_name = @(x) ischar(x) &&...
                    isrow(x) || isempty(x);
                
                
                aO(p, 'data', [], vf_data);
                aO(p, 'start', 0, vf_start);
                aO(p, 'srate', 1, vf_srate);
                aO(p, 'codes', '', vf_codes);
                aO(p, 'chantitle', '', vf_name);
                
                parse(p, varargin{:});
                
                %% job
                
                data = sparse(p.Results.data);
                info.Start = p.Results.start;
                info.SRate = p.Results.srate;
                info.ChanTitle = p.Results.chantitle;
                
                
                %% job .. MarkerCodes without calling obj.NSpikes
                
                codes = p.Results.codes;
                
                needtoexpand = false;
                rowsmore = 0;
                colsmore = 0;
                
                if isempty(data)
                    NSpikes = 0;
                    
                    obj.Data_ = [num2cell(zeros(0,1)), num2cell(uint8(zeros(0, 4))), repmat({''}, NSpikes, 1)];
                else
                    NSpikes = nnz(data(:, 1));
                    if size(codes, 1) < NSpikes
                        % warning('K:MarkerChan:codes:rows', ...
                        %    'the number of rows in codes is smaller than NSpikes.  The gap is filled with zeros.');
                        needtoexpand = true;
                        rowsmore = NSpikes - size(codes, 1);
                    end
                    
                    if size(codes, 2) < 4
                        %  warning('K:MarkerChan:codes:cols', ...
                        %   'the number of coulmns in codes is smaller than 4. The gap is filled with zeros.');
                        needtoexpand = true;
                        colsmore = 4 - size(codes, 2);
                    end
                    
                    if needtoexpand
                        codes = [codes; zeros(rowsmore, size(codes, 2))];
                        codes = [codes, zeros(NSpikes, colsmore)]; %TODO
                    end
                    
                    if size(codes, 1) > NSpikes ||...
                            size(codes, 2) > 4
                        warning('K:MarkerChan:codes:size', ...
                            'the size of rows in codes is larger than needed. The exceeding elements will be ignored.');
                    end
                    
                    obj.Data_ = [num2cell(find(data)), num2cell(uint8(codes(1:NSpikes, 1:4))), repmat({''}, NSpikes, 1)];

                end
                
                %                 obj.MarkerCodes = uint8(codes(1:NSpikes, 1:4)); % the only set access to MarkerCodes
                %                 obj.TextMark = repmat({''}, NSpikes, 1);
                
                % MarkerFilter initialization
                obj.MarkerFilter= true(256, 4);
                                
                info.Length = length(data);
                
                obj.ChanInfo_ = info;
                
            else % if isa(varargin{1}, 'struct') % Struct inputs
                %% parse
                narginchk(2,2);
                                               
                S = varargin{1};
                Sbin = varargin{2};
                
                if ~ChanInfo.vf_structMarker(S)
                    error('K:Chan:MarkerChan:MarkerChan:struct:invalid',...
                       'struct doesn''t seem Spike2 marker format'); 
                end
                
                vf_Sbin = @(x) isscalar(x) &&...
                    isfield(x, 'values') &&...
                    isfield(x, 'title') &&...
                    isfield(x, 'comment') &&...
                    isfield(x, 'interval') &&...
                    isfield(x, 'start') &&...
                    isfield(x, 'length');
                
                aR(p, 'Sbin', vf_Sbin);
                parse(p, Sbin);
                
                %% job
                start = Sbin.start;
                stop = start + Sbin.interval*(Sbin.length - 1);
                srate = 1/Sbin.interval;
                
                data = sparse(timestamps2binned(S.times, start, stop, srate));
                info.Start = start;
                info.SRate = srate;
                info.ChanTitle = S.title;
                
                codes = S.codes;
                if ~isa(codes, 'uint8')
                    error('Kouchi:MarkerChan:Scodes','codes must be uint8 class');
                end
                
                % MarkerFilter initialization
                obj.MarkerFilter = true(256, 4);
                
                if isfield(S, 'text') && isfield(S, 'items') % textmark
                    txtmrk = cellstr(S.text); % char(length, items)
                else
                    txtmrk = repmat({''}, S.length, 1);
                end
                
                if isempty(data)
                    obj.Data_ = cell(0, 6);
                else
                    obj.Data_ = [num2cell(find(data)), num2cell(codes), txtmrk];
                end
                               
                info.Length = Sbin.length;
                
                obj.ChanInfo_ = info;
                
            end
        end
        
        function this = setMarkerName(this, i, j, markername)
            %this = setMarkerName(this, i, j, markername)
            %% parse
            narginchk(4,4);
            
            p = inputParser;
            
            vf_i = @(x) ~isempty(x) &&...
                isnumeric(x) &&...
                isscalar(x) && ...
                (fix(x) == x )&&...
                x >= 0 && ...
                x <= 255;
            
            vf_j = @(x) ~isempty(x) &&...
                isnumeric(x) &&...
                isscalar(x) && ...
                (fix(x) == x )&&...
                x >= 1 && ...
                x <= 4;
            
            vf_markername = @(x) ~isempty(x) &&...
                ischar(x) &&...
                isrow(x);
            
            addRequired(p, 'i', vf_i);
            addRequired(p, 'j', vf_j);
            addRequired(p, 'markername', vf_markername);
            parse(p, i, j, markername);
            
            
            %% job
            this.MarkerName{i+1,j} = {markername}; % confusing
        end
        
        function obj = set.Data(obj, newdata)
            
            %% parse inputs
            narginchk(2,2);
            
            p = inputParser;
            vf_newdata = @(x) isempty(x) || ...
                iscolumn(x) &&...
                ( ...
                islogical(x) ||...
                isnumeric(x) && ( all(x(x ~= 0) == 1)) ...
                );
            addRequired(p, 'newdata', vf_newdata);
            parse(p, newdata);
            
            %% job
            
            codes = table2array(obj.MarkerCodes);
            textmark = obj.TextMark;
            
            
            
            if isempty(newdata)
                obj.Data_ = cell(0,6);
            else
                if length(newdata) == obj.Length
                    % This is likely to be subsasgn operation, so check if the
                    % indices of events are equal.
                    
                    [~, iinherit, ikeep] = intersect(find(newdata), find(obj.Data));
                    % [~, inew, ~] = setxor(find(newdata), find(obj.Data));
                    
                    % keep codes for the common indices
                    % otherwise fill with zeros or empty strings
                    
                    newcodes = zeros(length(find(newdata)), 4);
                    newcodes(iinherit) = codes(ikeep);
                    
                    newtextmark = repmat({''}, length(find(newdata)), 1);
                    newtextmark(iinherit) = textmark(ikeep);
                    
                else
                    % if the Length is different
                    % this is likely to be assignment of brand new data
                    %NOTE MarkerCodes and TextMark will be discarded
                    
                    newcodes = zeros(length(find(newdata)), 4);
                    newtextmark = repmat({''}, length(find(newdata)), 1);
                    
                    warning(['The length of newdata is different from obj.Length.\n',...
                        'The previous MarkerCodes and TextMark are all discarded.\n']);
                    
                end
                if nnz(newdata) > 0
                    obj.Data_ = [num2cell(find(newdata)), num2cell(uint8(newcodes)), newtextmark];
                else
                    obj.Data_ = cell(0,6);
                end
            end
            
            info = obj.ChanInfo_;
            info.Length =  length(newdata);%TODO
            obj.ChanInfo_ = info;
            
            
        end
        
        function obj = set.MarkerFilter(obj, filterStates)
            % obj = set.MarkerFilter(obj, filterStates)
            % filterStates      logical or binary numeric matrix
            %                   if the matrix is larger than (256, 4),
            %                   exceeding cells are ignored.
            %                   Each row defines code value0 to value255.
            %                   Each column defines mask0 to mask3, each of
            %                   which corresponds to code0 to code3.
            %
            %
            % Examples:
            % obj.MarkerFilter(1:2, 1) = false(2, 1)       % hide subset
            % obj.MarkerFilter{'value1', 'mask0'} = false  % hide one code with value 1
            % obj.MarkerFilter{2, 1} = false               % hide one code with value 1 
            %
            % obj.MarkerFilter = []            % show all  
            % obj.MarkerFilter = 'show'        % show all  
            % obj.MarkerFilter = true(256,4)   % show all 
            % 
            % obj.MarkerFilter(2:5,1) = []     % show subset
            % obj.MarkerFilter(2:5,1) = 'show' % show subset
            %
            % obj.MarkerFilter = 'hide'        % hide all
            % obj.MarkerFilter = false(256,4)  % hide all
            % 
            % obj.MarkerFilter(2:5,1) = 'hide' % hide subset
            %
            % <NOT ALLOWED>
            % obj.MarkerFilter = false
            % obj.MarkerFilter = [false; false] 
            % obj.MarkerFilter = table(false, 'VariableNames', 'mask0', 'RowNames', 'value1')
            
            %% parse inputs
            narginchk(2, 2);
            
            p = inputParser;
            vf_filterStates = @(x) isempty(x) || ...
                ( islogical(x) || isnumeric(x) ) && ...
                ismatrix(x) &&...
                all(all(x(x ~= 0) == 1)) || ...
                isa(x, 'table') || ...
                (ischar(x) && any(strcmpi(x, {'show','hide'})));
            
            addRequired(p, 'filterStates', vf_filterStates);
            parse(p, filterStates);
            
            %% job
            obsnames = repmat({'value'}, 256,1);
            obsnames = cellfun(@(x, y ) [x, num2str(y)], obsnames, num2cell(0:255)', 'UniformOutput', false);
            
            if isempty(filterStates)
                obj.MarkerFilter = array2table(true(256, 4), 'VariableNames', {'mask0', 'mask1', 'mask2', 'mask3'},...
                    'RowNames', obsnames );
                return
            end
            
            if size(filterStates, 1) ~= 256
                error('K:MarkerFilter:newstate:rows', ...
                    'the number of rows in newstate must be 256.');
            end
            
            if size(filterStates, 2) ~= 4
                error('K:MarkerFilter:newstate:cols', ...
                    'the number of coulmns in newstate must be 4.');
            end
                            
            if isa(filterStates, 'table')
                if ~all(ismember(filterStates.Properties.RowNames, obsnames))
                   error('K:MarkerFilter:filterStates:size', ...
                        'RowNames of filterStates must be one of value0 ... value255.'); 
                end
                
                if ~all(ismember(filterStates.Properties.VariableNames, {'mask0', 'mask1', 'mask2', 'mask3'}))
                   error('K:MarkerFilter:filterStates:size', ...
                        'RowNames of filterStates must be one of mask0 ... mask3.'); 
                end

                obj.MarkerFilter = filterStates;
                
            else % numeric or logical input

                obj.MarkerFilter= array2table(logical(filterStates), ...
                    'VariableNames', {'mask0', 'mask1', 'mask2', 'mask3'}, 'RowNames', obsnames);
            end
        end
        
        function obj = set.MarkerCodes(obj, codes)
            % codes     size(codes) == [NSpikes, 4]
            %           Values must be numeric 0 to 255
            %           Elements outside the range will be ignored with
            %           warning
            %           If the size(codes) is smaller than [NSpikes, 4], gaps will
            %           be filled with 0
            %
            % Note: requires access to obj.NSpikesAll_ property
            
            %% parse
            p = inputParser;
            
            vf_codes = @(x) istable(x) || ...
                isnumeric(x) &&...
                ismatrix(x) &&...
                ~any(any(isnan(x))) &&...
                all(all(x >= 0)) &&...
                all(all(x <=255)) &&...
                all(all(fix(x) == x));
            addRequired(p, 'codes', vf_codes);
            parse(p, codes);
            
            
            if istable(codes)
                
                assert(size(codes,2) == 4);
                
                assert(isequal(codes.Properties.VariableNames, ...
                    {'code0'  'code1'  'code2'  'code3'}));
                
                assert(all(codes.code0 >= 0) &&...
                    all(codes.code1 >= 0) &&...
                    all(codes.code2 >= 0) &&...
                    all(codes.code3 >= 0));
                
                assert(all(codes.code0 <= 255) &&...
                    all(codes.code1 <= 255) &&...
                    all(codes.code2 <= 255) &&...
                    all(codes.code3 <= 255));
                
                assert(all(fix(codes.code0) == codes.code0) &&...
                    all(fix(codes.code1) == codes.code1) &&...
                    all(fix(codes.code2) == codes.code2) &&...
                    all(fix(codes.code3) == codes.code3));
                
                codes = table2array(codes);
                
            end
            
            
            %% job
            
            needtoexpand = false;
            rowsmore = 0;
            colsmore = 0;
            
            numSpkAll = obj.NSpikesAll_;
            %NOTE: A set method for a non-Dependent property should not access another property ('NSpikesAll_').
            
            if size(codes, 1) < numSpkAll
                % warning('K:MarkerChan:codes:rows', ...
                %     'the number of rows in codes is smaller than NSpikes.');
                needtoexpand = true;
                rowsmore = numSpkAll - size(codes, 1);
            end
            
            if size(codes, 2) < 4
                % warning('K:MarkerChan:codes:cols', ...
                %     'the number of coulmns in codes is smaller than 4.');
                needtoexpand = true;
                colsmore = 4 - size(codes, 2);
            end
            
            if needtoexpand
                codes = [codes; zeros(rowsmore, size(codes, 2))];
                codes = [codes, zeros(numSpkAll, colsmore)];
            end
            
            if size(codes, 1) > numSpkAll
                warning('K:MarkerChan:setMarkerCodes:codes:size:rows', ...
                    'the size of rows in codes (%d) is larger than needed. The exceeding elements will be ignored.', size(codes, 1));
            end
            
            if size(codes, 2) > 4
                warning('K:MarkerChan:setMarkerCodes:codes:size:columns', ...
                    'the size of columns in codes (%d) is larger than needed. The exceeding elements will be ignored.', size(codes, 2));
            end
            
            obj.Data_(:,2:5) =  num2cell(uint8(codes(1:numSpkAll, 1:4))); % the only set access to MarkerCodes
            
        end
        
        function obj = set.TextMark(obj, newtext)
            % obj = set.TextMark(obj, newtext)
            %
            % newtext     A column vector of cellstr.
            %             If numel(newtext) is larger than NSpikesAll_,
            %             exceeing elements will be ignored with warning.
            %             If  numel(newtext) is smaller than NSpikesAll_,
            %             the rest will be filled with '' (empty char).
            
            %% parse
            narginchk(2,2);
            
            p = inputParser;
            
            vf_newtext = @(x) (iscellstr(x) || isstring(x)) &&...
                iscolumn(x);
            
            addRequired(p, 'newtext', vf_newtext);
            parse(p, newtext);
            
            
            %% job
            
            needtoexpand = false;
            rowsmore = 0;
            
            if isstring(newtext) %#ok<ISCLSTR>
                newtext = cellstr(newtext);
            end
            
            numSpkAll = obj.NSpikesAll_;
            if length(newtext) > numSpkAll
                needtoexpand = true;
                rowsmore = numSpkAll - length(newtext);
            end
            
            if needtoexpand
                newtext = [newtext; repmat({''}, rowsmore, 1)];
            end
            
            if length(newtext) > numSpkAll
                warning('K:MarkerChan:setTextMark:newtext:size:rows', ...
                    'the size of rows in newtext (%d) is larger than needed. The exceeding elements will be ignored.', length(newtext));
            end
            
            obj.Data_(:,6) = newtext(1:numSpkAll,:); %TODO causes error when loading saved object
            
        end
        
        function MarkerCodes = get.MarkerCodes(obj)
            % reflects MarkerFilter
            %
            % Use table2array to convert MarkerCodes (table) to unit8 array
            
            markercodes = cell2mat(obj.Data_(:,2:5));  % require cell2mat conversion
            if isempty(markercodes)
                MarkerCodes = array2table(uint8(zeros(0,4)),'VariableNames',{'code0','code1','code2','code3'});
            else
                MarkerCodes = array2table(markercodes(obj.VisibleSpikes_, :),'VariableNames',{'code0','code1','code2','code3'});
            end
        end
        
        function TextMark = get.TextMark(obj)
            % reflects MarkerFilter
            
            textmark = obj.Data_(:,6);
            
            TextMark = textmark(obj.VisibleSpikes_);
            
        end
        
        function Data = get.Data(obj)
            
            ind = cell2mat(obj.Data_(:,1)); % require cell2mat conversion
            
            Data = zeros(obj.Length, 1);
            Data(ind) = 1;

            Data(ind(~obj.VisibleSpikes_)) = 0; %NOTE a lot faster than assigning hide = ~obj.VisibleSpikes_;
            
        end
        
        function spikeInfo = getSpikeInfo(obj)
            % spikeInfo    Table data containing the spec of each spike/event
            %              MarkerFilter is applied.
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
            
            spikeInd = find(obj.Data); % visible spikes
            c = cell([length(spikeInd), 1]);
            zero = num2cell(zeros(size(c)));
            
            S = struct('id', zero,...
                'point', c,...
                'time', c,...
                'ISIbef', c,...
                'ISIaft', zero,...
                'InstantRate',zero);
            clear c zero;
            
            id = num2cell(1:length(spikeInd));
            [S(:).id] = id{:};
            
            point = num2cell(spikeInd);
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
            
            
            vis = obj.VisibleSpikes_;
            visspk = nominal(vis, {'hidden','Visible'},[0, 1]);
            
            %%  
            %   ds1 = struct2table(S);
            %   size(ds1)
            %
            %   ds2 = array2table(obj.MarkerCodes(select, :), 'VariableNames', {'code0', 'code1', 'code2', 'code3'});
            %   size(ds2)
            %
            %   ds3 = array2table(visspk(select, :), 'VariableNames', 'MarkerFilter');
            %   size(ds3)
            %
            %   ds4 = array2table(obj.TextMark(select, :), 'VariableNames', 'TextMark');
            %   size(ds4)
            
            %%
            if any(vis)
                spikeInfo = [struct2table(S), ...
                    obj.MarkerCodes,...
                    array2table(visspk(vis, :), 'VariableNames', {'MarkerFilter'}),...
                    array2table(obj.TextMark, 'VariableNames', {'TextMark'})];
            else
                spikeInfo = 'No spikes to show. (They may be hidden by MarkderFilter.)';
            end
            
        end
        
        function spikeInfoAll = getSpikeInfoAll(obj)
            % spikeInfoAll    column structure containing the spec of each spike/event
            %                 MarkerFilter is not applied.
            %
            % .id           x th spike
            % .point        data point index
            % .time         time in second
            % .ISIbef       ISI before this spike (
            %       for the first spike, interval between 0 to the first spike
            % .ISIaft       ISI after this spike
            %       for the last spike, interval between the last spike
            %       to the end of the file
            % .InstantRate  inverse of spikeInfo.ISIbef
            
            spikeInd = cell2mat(obj.Data_(:,1)); % require cell2mat conversion
            
            c = cell([length(spikeInd), 1]);
            zero = num2cell(zeros(size(c)));
            
            S = struct('id', zero,...
                'point', c,...
                'time', c,...
                'ISIbef', c,...
                'ISIaft', zero,...
                'InstantRate',zero);
            clear c zero;
            
            id = num2cell(1:length(spikeInd));
            [S(:).id] = id{:};
            
            point = num2cell(spikeInd);
            [S(:).point] = point{:};
            
            TimeStamps = spikeInd*obj.SInterval;
            time = num2cell(TimeStamps);
            [S(:).time] = time{:};
            
            if ~isempty(TimeStamps)
                ISI = [TimeStamps(1) - obj.Start;
                    diff(TimeStamps);
                    obj.MaxTime - TimeStamps(end)];
            else
                ISI = [];
            end
            
            ISIbef = num2cell(ISI(1:end-1));
            [S(:).ISIbef] = ISIbef{:};
            
            ISIaft = num2cell(ISI(2:end));
            [S(:).ISIaft] = ISIaft{:};
            
            InstantRate = num2cell(1./ISI(1:end-1));
            [S(:).InstantRate] = InstantRate{:};
            
            visspk = nominal(obj.VisibleSpikes_, {'hidden','Visible'},[0, 1]);
            
            if obj.NSpikesAll_ == 0
                spikeInfoAll = [];
            else
                spikeInfoAll = [struct2table(S), ...
                    array2table(cell2mat(obj.Data_(:,2:5)), 'VariableNames', {'code0', 'code1', 'code2', 'code3'}),...
                    array2table(visspk, 'VariableNames', {'MarkerFilter'}),...
                    array2table(obj.Data_(:,6), 'VariableNames', {'TextMark'})];
            end
        end
        
        function IsMarkerFilterOn = get.IsMarkerFilterOn(obj)
            if all(all(table2array(obj.MarkerFilter)))
                IsMarkerFilterOn = false; % all codes are visible
            else
                IsMarkerFilterOn = true;
            end
            
        end
        
        function nSpikesAll_ = get.NSpikesAll_(obj)
            
            nSpikesAll_ = length(obj.Data_(:,1));
            
        end
        
        function visiblespikes = get.VisibleSpikes_(obj)
            % visiblespikes = get.VisibleSpikes_(obj)
            %
            % visiblespikes   an array of logical with the size of
            %                 (NSpikesAll_, 4). Determines the visibility of
            %                 all spikes for all four MarkerCodes
            %
                        
            markerShow = logical(double(obj.MarkerFilter{:,:}));
            markercodesAll = cell2mat(obj.Data_(:,2:5)); %TODO slow
            
            tf = true(size(markercodesAll));
            
            if isempty(tf)
                % if there is no event at all
                visiblespikes = true(0, 4);
            else
%                 tic
%                 
%                 for i = 1:4
%                     
%                     tf(:, i)= arrayfun(@(x) markerShow(x+1, i), markercodesAll(:,i)); %TODO slow
%                     
%                 end
%                 toc %0.015

%                 tic
                for i = 1:4
                
                    uq = unique(markercodesAll(:,i));
                    
                    for j = 1:length(uq)
                       
                        tf(markercodesAll(:,i) == uq(j), i) =  markerShow(uq(j)+1,i); % >3 times faster, but depends on how many marker types you have
                        
                    end
                    
                end
                
%                 toc %0.0051
                
                
                
                visiblespikes = all(tf, 2);
            end
            
        end
        
        function  obj2= resample(obj, newRate,varargin)
            % obj2= resample(obj, newRate)
            %
            % the length of resmaple(x, p, q) is defined as follows:
            % ceil(length(x)*p/q)
            
            outlen = ceil(obj.Length*newRate/obj.SRate);
            
            
            mFilter = obj.MarkerFilter;
            obj.MarkerFilter = true(256,4); % make all visible
            
            newdata = timestamps2binned(obj.TimeStamps, obj.Start, ...
                obj.Start + 1/newRate*(outlen - 1), newRate);
            
            obj2 = MarkerChan(newdata, obj.Start, newRate, table2array(obj.MarkerCodes), obj.ChanTitle);
            obj2.DataUnit = obj.DataUnit;
            obj2.Header = obj.Header;
            obj2.TextMark = obj.TextMark;
            
            obj2.MarkerFilter = mFilter; % put the filter back
            obj2.MarkerName = obj.MarkerName;
        end
        
        function tf = getstatesAsLogical(obj,varargin)
            % returns logical vector with the same size as Data to
            % represent state changes. 
            %
            % SYNTAX
            % tf = getstatesAsLogical(obj)
            % tf = getstatesAsLogical(obj,codeN)
            %
            %
            % INPUT ARGUMENTS
            % obj         MarkerChan object
            %
            % codeN       'code0' (default) | 'code1' | 'code2' | 'code3'
            %             (Optional) Specifies which of the four codes to
            %             be used.           
            %
            % OUTPUT ARGUMENTS
            % tf          logical column
            %             The same size as obj.Data. Data points at or following
            %             the beginning of Data or any events with marker
            %             code 0 are false. Data points at or following any
            %             events with marker code > 0 are true.          
            %
            % Written by Kouichi C. Nakamura Ph.D.
            % MRC Brain Network Dynamics Unit
            % University of Oxford
            % kouichi.c.nakamura@gmail.com
            % 24-Nov-2019 12:21:05
            %
            % See also
            % find

            spikeInfo = obj.getSpikeInfo;
            
            tf = false(size(obj.Data));
            
            spikeInfo.StateChange = spikeInfo.code0 > 0;
            
            onpts = spikeInfo.point(spikeInfo.StateChange);
            
            offpts = spikeInfo.point(~spikeInfo.StateChange);
            
            
            for i = 1:length(onpts)
            
               k = find(onpts(i) < offpts,1, 'first');
                
               tf(onpts(i):offpts(k)) = true;
                
            end

            
        end
        
        function struct = chan2struct(obj, varargin)
            % struct = chan2struct(obj, format)
            %
            % format    optional string
            %           'marker' (default), 'event', 'binned'
            
            %% parse
            narginchk(1,2);
            
            p = inputParser;
            
            vf_format = @(x) ischar(x) && ...
                isrow(x) && ...
                any(strcmpi(x, {'marker','event','binned'}));
            
            addOptional(p, 'format', 'marker', vf_format);
            
            parse(p, varargin{:});
            
            format = p.Results.format;
            
            %% job
            
            header = obj.Header;
            
            if ~isempty(header)
                if isfield(header, 'title')
                    header = rmfield(header, 'title');
                end
                if isfield(header, 'comment')
                    header = rmfield(header, 'comment');
                end
                if isfield(header, 'interval')
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
                case 'marker'
                    struct.title = obj.ChanTitle;
                    if isempty(header)
                        struct.comment = 'No comment';
                    else
                        struct.comment = obj.Header.comment;
                    end
                    struct.resolution = obj.SInterval;
                    struct.length = length(obj.TimeStamps);
                    struct.times = obj.TimeStamps;
                    struct.codes = obj.MarkerCodes;
                    
                    %% prepare char array
                    
                    text = obj.TextMark;
                    txtnone = strcmp('',text);
                    
                    if all(txtnone) % (n, 36) blank char array
                        struct.text = repmat(blanks(36), length(obj.TimeStamps), 1);
                    else
                        
                        maxlen = max(cellfun(@(x) length(x), text(~txtnone)));
                        
                        text(txtnone) = repmat({blanks(maxlen)}, nnz(txtnone), 1);
                        
                        struct.text = char(text{:});
                        
                        if maxlen < 36 % padding
                            struct.text = [struct.text, ...
                                repmat(blanks(36 - maxlen), length(obj.TimeStamps), 1)];
                        end
                        
                    end
                    
                    
                case 'event'
                    struct.title = obj.ChanTitle;
                    if isempty(header)
                        struct.comment = 'No comment';
                    else
                        struct.comment = obj.Header.comment;
                    end
                    
                    struct.resolution = obj.SInterval;
                    struct.length = length(obj.TimeStamps);
                    struct.times = obj.TimeStamps;
                    
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
            
            s.ChanInfo_    = obj.ChanInfo_;
            s.Data_        = obj.Data_;
%             s.Length      = obj.Length;
            s.MarkerFilter = obj.MarkerFilter;
            s.MarkerName   = obj.MarkerName;

        end
        
        
        
        objout = addEvents(obj, time, codes, textmarks)
        %TODO
        
        chanout = importEvents(chan1, chan2)
        %TODO
        
        objout = deleteEvents(obj, varargin)
        %TODO
        %                by points?
        %                by id?
        %                or by time range?
        
        markerfilter(obj) %?
        
        h = plot(this, varargin)
    end
    
    methods (Static)
        function chanout = ts2chan(ts) %OK
            p = inputParser;
            vf_ts = @(x) isa(x, 'timeseries');
            addRequired(p, 'ts', vf_ts);
            parse(p, ts);
            
            sInterval = ts.TimeInfo.Increment;
            if isempty(sInterval)
                sInterval = (ts.Time(end) - ts.Time(0))/(ts.Length - 1);
            end
            
            chanout =MarkerChan(ts.Data, ts.Time(1), sInterval, ts.Name);
        end

        mk = bw2markerchandata(data,start, srate, chantitle, varargin)
        
        mk = uint2markerchandata(uintdata, start, srate, chantitle, varargin)

        function obj = loadobj(s)
            %TODO apparently conflicts with parfor
            
            assert(~isempty(s))

%             assert(isequal(sort(fieldnames(s)),...
%                 sort({'ChanInfo_';...
%                 'Data_';...
%                 'Length';...
%                 'MarkerFilter';...
%                 'MarkerName'})));  
            
            obj = MarkerChan;
            obj.ChanInfo_    = s.ChanInfo_;
            obj.Data_        = s.Data_;
%             obj.Length       = s.Length;
            obj.MarkerFilter = s.MarkerFilter;
            obj.MarkerName   = s.MarkerName;
            
        end
        
    end
    
end