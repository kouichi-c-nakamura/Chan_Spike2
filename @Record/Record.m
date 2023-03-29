classdef Record
    %Record holds a group of Chan class objects that share the time vector.
    % Similar to tscollection class for timeseries objects.
    %
    %
    % Written by Kouichi C. Nakamura Ph.D.
    % MRC Brain Network Dynamics Unit
    % University of Oxford
    % kouichi.c.nakamura@gmail.com
    % 15-Aug-2017 15:24:04
    %
    % See Also 
    % Chan, MetaEventChan, WaveformChan, EventChan,
    % MarkerChan, RecordInfo
    
    %TODO Record can be a special case, i.e. a subclass of RecordA
    
    properties
        RecordTitle (1,:) char = '';
    end
    
    properties
        Chans (:,1) cell = cell(0); % Cell array containing the Chan objects with the same Time vector.
    end
    
    properties (Dependent = true, SetAccess = 'protected')
        Time (:,1) double % In Second. Must be shared by all the Chan objects contained.
        Length (1,1) double % Length of Data and Time.
        SInterval (1,1) double % Sampling interval in Second.
        MaxTime (1,1) double % Time at the end of the file in Second.
        Duration (1,1) double % in second
        ChanTitles (:,1) cell % Cell array of strings for the ChanTitle of the Chan objects contained.
    end
    
    properties (Dependent = true, SetAccess = 'public')
        Start (1,1) double % Time at the beginning of the file in Second.
        SRate (1,1) double % Sampling Rate in Hertz.
    end
    
    properties (Hidden, SetAccess = protected, GetAccess = protected)
        Time_ = []; %  In Second. Time vector must be shared by all the Chan objects contained.
        RecordInfo_
    end
    
    methods
        
        %% Constructor
        function this = Record(varargin)
            % Constructor of Record class
            %
            % rec = Record({chan1, chan2, ...})
            % rec = Record()
            % rec = Record(______, 'Name', 'string')
            % rec = Record('Name', 'string')
            % rec = Record(matfilename)
            %
            %
            % rec = Record({chan1, chan2, ...})
            % chan1, ...     Chan class objects, such as WaveformChan,
            %                EventChan and MarkerChan objects            %
            %
            %
            % rec = Record('Name', 'string') creates an empty
            % Record object with a Name.
            %
            %
            % rec = Record(matfilename)              
            % matfilename    Char type single input. Accepts a valid file path 
            %                (char type) of a .mat file that contains Spike2
            %                generated structures of electrophysiological 
            %                recordings
            %
            % rec = Record() 
            % creates an empty Record object.
            %
            %
            % See Also 
            % Record
            
            if nargin ==1 && isa(varargin{1},'Record') % by itself
                this = varargin{1};
                
            elseif  nargin ==1 && ~isempty(varargin{1}) && ischar(varargin{1}) && isrow(varargin{1}) 
                % matfile name input
                
                matfilename = varargin{1};
                try
                    S = load(matfilename);
                catch mexc1
                    if strcmp(mexc1.identifier, 'MATLAB:load:couldNotReadFile')
                        error(eid(),...
                            'The single input variable must be a valid file path for a .mat file that contains Spike2 generated structure of recording data');
                    else
                       throw(mexc1) 
                    end
                    
                end
                
                chantitles = fieldnames(S);
                n_chans = length(chantitles);
                chanarray = cell(n_chans ,1);
                
                ismarkerincluded = false(1, n_chans);
                for i = 1:n_chans
                    
                    if ChanInfo.vf_structEvent(S.(chantitles{i}))
                        chanarray{i} = EventChan(S.(chantitles{i}));
                        
                    elseif ChanInfo.vf_structWaveform(S.(chantitles{i}))
                        chanarray{i} = WaveformChan(S.(chantitles{i}));
                        
                    elseif ChanInfo.vf_structMarker(S.(chantitles{i}))
                        ismarkerincluded(i) =true;
                        % TODO maker channel has not been tested yet
                    elseif strcmp(chantitles{i},'file') && ChanInfo.vf_structFile(S.(chantitles{i}))
                        % this is file information
                        
                        chanarray{i} = NaN;
                    else
                        error(eid('matfileinput:sturcture:invalidfields'), ...
                            'The structure %s contains invalid fields for Chan class construction.', chantitles{i} );
                    end
                end
                
                % exclude file information structure if any
                tf = cellfun(@(x) isnumeric(x) && isnan(x),chanarray);
                if any(tf)
                    assert(nnz(tf) == 1)
                    chanarray(tf) = [];
                    n_chans = n_chans - 1;
                end
                
                %% Marker channel construction
                if any(ismarkerincluded)
                    ref = [];
                   for i = 1:n_chans
                       if isa(chanarray{i}, 'EventChan') || isa(chanarray{i}, 'WaveformChan')
                           ref = S.(chantitles{i}); % find a reference channel that is either waveform or event
                           break
                       end
                   end
                   clear i
                   
                   if ~isempty(ref)
                       ind = 1:n_chans;
                       for i = ind(ismarkerincluded) 
                           
                           chanarray{i} = MarkerChan(S.(chantitles{i}), ref);
                           
                       end
                       clear ind i
                   else
                       error(eid('matfileinput:marker:noref'), ...
                           'To construct a MarkerChan object you need another channel that is either EventChan or WaveformChan. However, the file %s doesn''t contain any.', matfilename);
                   end
                end
                
                %% pass cell array of Chan objects to this.init()
                this = this.init(chanarray);
                [~, name, ext] = fileparts(matfilename);
                this.RecordTitle = [name, ext];
                
                
                
            elseif nargin > 0
                this = this.init(varargin{:});
                
            else % nargin == 0; no input
                this.Chans = cell(0);
            end
        end
        
        %% property get methods
        function chsinfo = get.RecordInfo_(obj)
            if isempty(obj.Chans)
                chsinfo = RecordInfo();
            else
                chsinfo = RecordInfo(obj.Chans, 'Name', obj.RecordTitle); %TODO
            end
        end
        
%         function title = get.RecordTitle(obj) %TODO
%             title = obj.RecordInfo_.RecordTitle;
%         end
        
        function SRate = get.SRate(obj)
            SRate = obj.RecordInfo_.SRate;
        end
        
        function Start = get.Start(obj)
            Start = obj.RecordInfo_.Start;
        end
        
        function dur = get.Duration(obj)
            dur = obj.RecordInfo_.Duration;
        end
        
        function chanTitles = get.ChanTitles(obj)
            chanTitles = obj.RecordInfo_.ChanTitles;
        end
        
        function maxTime = get.MaxTime(obj)
            maxTime = obj.RecordInfo_.MaxTime;
        end
        
        function length = get.Length(obj)
            length = obj.RecordInfo_.Length;
        end
        
        function sInterval = get.SInterval(obj)
            sInterval = obj.RecordInfo_.SInterval;
        end
        
        function Time = get.Time(obj)
            if ~isempty(obj.Chans)
                if obj.Length >= 1
                    Time = (obj.Start:obj.SInterval:(obj.Start+obj.SInterval*(obj.Length - 1)))';
                elseif obj.Length == 0
                    Time = [];
                end
            else
                Time = [];
            end
        end
        
        
        %% property set methods
        function obj = set.Chans(obj, newChans)
            % obj = set.Chans(obj, newChans)
            %
            % TODO support subsasgn?
            % TODO support sort order specification?
            % Param    'Sort'
            % Values   'cannumber'
            %          'unchanged'
            %          'chantitle'
            %          'chankind'
            
            narginchk(2,2);
            
            p = inputParser;
            vf1 = @(x) isempty(x) ||...
                iscell(x) &&...
                isvector(x) && ...
                all(cellfun(@(y) isa(y, 'Chan'), x));
            
            addRequired(p, 'newChans', vf1);
            parse(p, newChans);
            
            if isempty(newChans)
                obj.Chans = [];
                return;
            end
            
            if iscell(newChans) && isrow(newChans)
                newChans = newChans';
            end
            
            chans = newChans'; %row vector
            
            %% check if Time vectors are identical
            
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
            
            summary = struct2dataset(list);
            
            % unique name check
            if length(unique(summary.ChanTitle)) ~= length(summary.ChanTitle)
                error(eid('setChans:ChanTitle'), ...
                    'ChanTitle must be unique among objects.');
            end
            
            % time identity
            if any(summary.Start(1) ~= summary.Start)|| ...
                    any(summary.SRate(1) ~= summary.SRate) || ...
                    any(summary.Length(1) ~= summary.Length)
                error(eid('setChans:Time'), ...
                    'Time is not identical between objects.');
            end
            
            obj.Chans = newChans;
            
            %TODO sort the Chan onjects according to ChanNumner, ChanTitle
            %etc?
            % Ideally you should be able to change the order when necessary
            
        end
        
        function obj = set.Start(obj, newStart)
            % set Time-related Start property of Chans at the same time
            %
            %% parse
            p = inputParser;
            
            vf_newStart = @(x) isa(x, 'double') &&...
                isscalar(x) &&...
                isreal(x) &&...
                isfinite(x) &&...
                ~isnan(x) ; % accept minus value
            
            addRequired(p, 'newStart', vf_newStart);
            parse(p, newStart);
            
            
            %% job
            
            chans = obj.Chans;
            
            n = length(chans);
            
            for i = 1:n
                
                chans{i}.Start = newStart;
                
            end
            
            out = Record(chans);
            
            out.RecordTitle = obj.RecordTitle;
            clear obj
            
            obj = out;
            %not sure if this works for handle class though
            
        end
        
        function obj = set.SRate(obj, newSRate)
            % set Time-related Start property of Chans at the same time
            %
            %% parse
            p = inputParser;
            
            vf_newSRate = @(x) isa(x, 'double') &&...
                isscalar(x) &&...
                isreal(x) &&...
                x > 0;
            
            addRequired(p, 'newStart', vf_newSRate);
            parse(p, newSRate);
            
            
            %% job
            
            chans = obj.Chans;
            
            n = length(chans);
            
            for i = 1:n
                
                chans{i}.SRate = newSRate;
                
            end
            
            out = Record(chans);
            
            out.RecordTitle = obj.RecordTitle;
            clear obj
            
            obj = out;
            %not sure if this works for handle class though
            
        end
       
        function obj = set.RecordTitle(obj, newTitle)
            % obj = set.RecordTitle(obj, newTitle)
            %
            %% parse
            p = inputParser;
            
            vf_newTitle = @(x) ischar(x) && isrow(x) || isempty(x);
            
            addRequired(p, 'newTitle', vf_newTitle);
            parse(p, newTitle);
            
            
            %% job
              
            obj.RecordTitle = newTitle;
                        
        end
        
        
        function obj = set.SInterval(obj, newinverval)
            % set Time-related Start property of Chans at the same time
            %
            %% parse
            p = inputParser;
            
            vf_newinterval = @(x) isa(x, 'double') &&...
                isscalar(x) &&...
                isreal(x) &&...
                x > 0;
            
            addRequired(p, 'newinverval', vf_newinterval);
            parse(p, newinverval);
            
            
            %% job
            
            chans = obj.Chans;
            
            n = length(chans);
            
            for i = 1:n
                
                chans{i}.SRate = 1/newinverval;
                
            end
            
            out = Record(chans);
            
            out.RecordTitle = obj.RecordTitle;
            clear obj
            
            obj = out;
            
        end
        
        
        
        %% methods
        function summaryT = summaryTable(this)
            % summaryds = summaryTable(this)
            
            chans = this.Chans;
            if isrow(chans)
                chans = chans';
            end
            
            c = cell(size(chans));
            nans = NaN(size(chans));
            
            summary.ChanTitle = c;
            summary.Classname = c;
            summary.ChanNumber = nans;
            summary.Path = c;
            summary.Start = nans;
            summary.MaxTime = nans;
            summary.Duration = nans;
            summary.TimeUnit = c;
            summary.SRate = nans;
            summary.SInterval = nans;
            summary.Length = nans;
            summary.DataUnit = c;
                        
            if isempty(chans)
                summaryT = struct2table(summary) ;
                return;
            else
                
                for i = 1:length(chans)
                    summary.ChanTitle{i} = chans{i}.ChanTitle;
                    summary.Classname{i} = class(chans{i});
                    summary.ChanNumber(i) = chans{i}.ChanNumber;
                    summary.Path{i} = chans{i}.Path;
                    summary.Start(i) = chans{i}.Start;
                    summary.MaxTime(i) = chans{i}.MaxTime;
                    summary.Duration(i) = chans{i}.MaxTime - chans{i}.Start;
                    summary.TimeUnit{i} = chans{i}.TimeUnit;
                    summary.SRate(i) = chans{i}.SRate;
                    summary.SInterval(i) = chans{i}.SInterval;
                    summary.Length(i) = chans{i}.Length;
                    summary.DataUnit{i} = chans{i}.DataUnit;
                    
                end
                
                summaryT = struct2table(summary);
                summaryT.Properties.VariableUnits = {'','','','',...
                    'sec', 'sec', 'sec', '', 'Hz', 'sec', 'points', ''}; % length(Units) must match the number of columns
                
            end
            
        end
        
        
        function out = resample(obj, newRate,varargin)
            % out = resample(obj, newRate)
            % Resample all the Chan objects contained at a new
            % sampling rate specified by newRate.
            %
            % See Also Record
            
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('newRate');
            p.addOptional('modestr','normal',@(x) ismember(x, {'normal','ignore'}));
            p.parse(obj,newRate,varargin{:});
            
            modestr = p.Results.modestr;

            
            out = Record;
            
            for i = 1:length(obj.Chans)
                chan = resample(obj.Chans{i}, newRate,modestr);
                out = out.addchan(chan);
            end
            
            out.RecordTitle = obj.RecordTitle;
            
        end
        
        function chanbelsinfo = getRecordInfo(obj)
            % chanbelsinfo = getRecordInfo(obj)
            % returns a RecordInfo object that corresponding to obj
            %
            % See Also RecordInfo
            
            chanbelsinfo = obj.RecordInfo_;
            %TODO
            
        end
        
        function tf = testProperties(obj)
            tf = K_testProperties(obj);
        end
        
        function eqstate = eq(obj1, obj2)
            
            if ~strcmp(class(obj1), class(obj2)) % different class
                eqstate = false;
            else
                
                propnames = properties(obj1);
                eqstate = true;
                
                for i = 1:length(propnames)
                    if  ~isequaln(obj1.(propnames{i}), obj2.(propnames{i}))
                        eqstate = false;
                        
                        %disp(propnames{i});
                        break
                    end
                end
            end
            
        end
        
        function s = saveobj(obj)
            
            s.Chans = obj.Chans;
            s.RecordInfo_ = obj.RecordInfo_;
            s.RecordTitle = obj.RecordTitle;
            s.Time_ = obj.Time_;
            
        end
        
    end
    
    methods (Access = protected)
        
        this = init(this, varargin) % separate file
        
        
    end
    
    methods (Static)
        
        function obj = loadobj(s)
      
            obj = Record;
            obj.Chans = s.Chans;
            obj.RecordInfo_ = s.RecordInfo_;
            obj.RecordTitle = s.RecordTitle;
            obj.Time_ = s.Time_;
            
        end
        
    end
    
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