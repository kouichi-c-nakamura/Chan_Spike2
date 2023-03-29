classdef RecordAInfo
    %RecordAInfo Metadata of Record
    %
    % Written by Kouichi C. Nakamura Ph.D.
    % MRC Brain Network Dynamics Unit
    % University of Oxford
    % kouichi.c.nakamura@gmail.com
    % 15-Aug-2017 15:26:52
    %
    % See also
    % Record
    
    properties
        RecordTitle = '' % string
    end
    
    properties %(SetAccess = protected)
        ChanInfos = cell(0);
    end
    
    properties (Dependent = true)
        Paths = {}
        Start = 0;
        SRate = 1;
        Length = 0;
        SInterval
        ChanTitles = {}
        PathRefs = {} % only for MarkerChan. Path of the reference binned data.
        TimeUnit = 'second';
        MaxTime = 0;
        Duration = 0;
    end
    
    methods
        %% Constructor
        function obj = RecordAInfo(varargin)
            % obj = RecordAInfo({ChanInfo1, ChanInfo2, ...})
            % obj = RecordAInfo({Chan1, Chan2, ...})
            % obj = RecordAInfo()
            % obj = RecordAInfo(______, 'Name', 'string')
            % obj = RecordAInfo('Name', 'string')
            % obj = RecordAInfo(matfilename) %TODO
            %
            % obj = RecordAInfo({ChanInfo1, ChanInfo2, ...})
            % ChanInfo1, ... ChanInfo class objects hold meta infomation
            %                about Chan objects, such as those in WaveformChan,
            %                EventChan and MarkerChan class
            %
            % obj = RecordAInfo({chan1, chan2, ...})
            % chan1, ...     Chan class objects, such as WaveformChan,
            %                EventChan and MarkerChan objects
            %
            % obj = RecordAInfo('Name', 'string') creates an empty
            % Record object with a Name.
            %
            % recinfo = RecordAInfo(matfilename)  %TODO            
            % matfilename    Single input. Accepts a valid file path (char
            %                type) of a .mat file that contains Spike2
            %                generated structures of electrophysiological 
            %                recordings
            %
            % obj = RecordAInfo() 
            % creates an empty Record object.
            
            narginchk(0,inf);
            
            if nargin ==1 && isa(varargin{1}, 'RecordAInfo') % by itself
                obj = varargin{1};
                
            elseif nargin>0
                obj = obj.init(varargin{:});
            else
                obj.ChanInfos = [];
            end
        end
        
        %% Property get methods
        function paths = get.Paths(obj)
            if isempty(obj.ChanInfos)
                paths = {};
            else
                paths = cellfun(@(x) x.Path, obj.ChanInfos, 'UniformOutput', false);
            end
        end
        
        function start = get.Start(obj)
            start = getSinglePropVal(obj, 'Start', 0);
        end
        
        function srate = get.SRate(obj)
            srate = getSinglePropVal(obj, 'SRate', 1);
        end
        
        function length = get.Length(obj)
            length = getSinglePropVal(obj, 'Length', 0);
        end
        
        function sinterval = get.SInterval(obj)
            sinterval = 1/obj.SRate;
        end
        
        function chantitles = get.ChanTitles(obj)
            if isempty(obj.ChanInfos)
                chantitles = {};
            else
                chantitles = cellfun(@(x) x.ChanTitle, obj.ChanInfos, 'UniformOutput', false);
            end
        end
        
        function pathrefs = get.PathRefs(obj)
            
            if isempty(obj.ChanInfos)
                pathrefs = {};
            else
                pathrefs = cellfun(@(x) x.PathRef, obj.ChanInfos, 'UniformOutput', false);
            end
            
        end
        
        function timeunit = get.TimeUnit(obj)
            timeunit = getSinglePropVal(obj, 'TimeUnit', 'mV');
            
        end
        
        function maxtime = get.MaxTime(obj)
            if obj.Length >= 1
                maxtime = obj.Start + obj.SInterval*(obj.Length - 1);
            elseif obj.Length == 0
                maxtime = [];
            end
        end
        
        function duration = get.Duration(obj)
            if obj.Length >= 1
                duration = obj.MaxTime - obj.Start;
            elseif obj.Length == 0
                duration = [];
            end
        end
        
        %% Property set methods
        
        function obj = set.ChanInfos(obj, chaninfos)
            assert( isempty(chaninfos) ||...
                iscell(chaninfos) && ...
                iscolumn(chaninfos) && all(cellfun(@(x) isa(x, 'ChanInfo'), chaninfos)),...
                'K:RecordAInfo:set.ChanInfos:chaninfos',...
                'chaninfos must be column cell vector of ChanInfo objects');
            
            if isempty(chaninfos)
                obj.ChanInfos = cell(0);
            else
                obj.ChanInfos = chaninfos;
            end
        end
        
        %% common methods

        obj = addChan(obj, newchan)
        
        obj = removeChan(obj, delChan)
                
        function cellstr = printRows(obj)
            % cellstr = printRows(obj)
            %
            % converts the content of obj into spread sheet-compatible
            % single row-format data per channel
            
            % TODO how to print struct or array?? You will lose quite a lot
            % of data
            
            
            
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
        
        
        
    end
    
    methods (Hidden = true, Access = protected)
        
        obj = init(obj, varargin) %TODO Shouldn't it be protected?

        function out = getSinglePropVal(obj, PropName, defaultval)
            assert(~isempty(PropName) && ischar(PropName) && isrow(PropName) ...
                && any(strcmp(PropName, properties(obj))),...
                'K:RecordAInfo:propGetSingleVal:PropName:invalid',...
                'PropName must be valid property name for RecordAInfo');
            
            
            errid = sprintf('K:Chan:RecordAInfo:%s:invalid', PropName);
            errmsg = sprintf('%s values were not identical among children', PropName);
            
            if isempty(obj.ChanInfos)
                out = defaultval;
            elseif ~isempty(obj.ChanInfos) && ischar(obj.ChanInfos{1}.(PropName))
                % char type
                
                outs = cellfun(@(x) x.(PropName), obj.ChanInfos, 'UniformOutput', false);
                
                assert(all(strcmp(outs{1}, outs)), errid, errmsg)
                out = outs(1);
                
            elseif ~isempty(obj.ChanInfos) && isscalar(obj.ChanInfos{1}.(PropName)) && isnumeric(obj.ChanInfos{1}.(PropName))
                % scalar numeric type
                
                outs = cellfun(@(x) x.(PropName), obj.ChanInfos, 'UniformOutput', true);
                
                errid = sprintf('K:Chan:RecordAInfo:%s:invalid', PropName);
                assert(all(outs(1) == outs), errid, errmsg);
                out = outs(1);
                
            else
                outs = cellfun(@(x) x.(PropName), obj.ChanInfos, 'UniformOutput', true);
                
                errid = sprintf('K:Chan:RecordAInfo:%s:invalid', PropName);
                assert(all(outs(1) == outs), errid, errmsg);
                out = outs(1);
            end
        end
    end
end

