classdef LTSburst
    % LTSburst detects and holds and plots LTS bursts out of spike trains
    %
    % See also
    % K_LTSburst_groupplot, K_LTSburst_detect, LTSburst_test

    %TODO Accessing Groupdata table is slow. I can make it hold values in a
    % hidden property instead of computing every time. Only when parameters
    % or data change it should be updated. SetAccess = private, Dependent =
    % false

    properties

        PreburstSilence_ms (1, 1) {mustBeNonnegative} = 100;
        FirstISImax_ms (1, 1) {mustBeNonnegative} = 5;
        LastISImax_ms (1, 1) {mustBeNonnegative} = 10;

        Spike (1,:) cell     % stores actual data of spike events;
                   %0 or 1 sparse double column vectors in a row vector of cells

        Fs (1,:) double {mustBePositive}       % row vector of sampling frequency [Hz]
        Names (1,:) cell
        StartTime (1,:) double
    end

    properties (SetAccess = protected)

        Groupdata   % a table output for visibility
        %
        % Rows:
        % for records
        %
        % Variables:
        % spikeInfo    non-scalar structure
        % isi          Column vector of double
        % onset        Column vector of double in spike ID
        % offset       Column vector of double in spike ID
        % starttime    double
        % maxtime      double
        % names        char
        % LTSdef       structure
        % tooshort     double array

    end

    properties (Dependent = true, SetAccess = protected)

        Is          % row vector of sampling intervals
        SpikeInfo
        ISI
        Onset       % 0 or 1 logical column vectors in a row vector of cells
        OnsetInfo   % this is a subset of SpikeInfo.
        Offset      % 0 or 1 logical column vectors in a row vector of cells
        OffsetInfo  % this is a subset of SpikeInfo.
        MaxTime

        ISIordinal

        ISIordinalmeta % each data point represent the mean of all the ISIs in the all data pool
        ISIordinalmeta_perRecord % each data point represent the mean of the mean of a Record

        LTSstats % non-scalar structure

    end

    methods
        function obj = LTSburst(varargin)
            % The constructor of an LTSburst object
            %
            % obj = LTSburst(spike, Fs, varargin)
            % obj = LTSburst(spike, Fs, Start_sec, varargin)
            %
            % obj = LTSburst(records, varargin)
            %
            % obj = LTSburst(chans, varargin)
            %
            % obj = LTSburst(_____, param, value)
            %
            % INPUT ARGUEMENTS
            % spike      A cell vector of spike events (i.e. column vectors of 0 and 1)
            %            for group data, or a column vector of 0 or 1 for just one recording data.
            %
            % Fs         A vector of sampling frequency [Hz] with the
            %            same size as spike when spike are cell array.
            %            Or a scalar value for sampling frequency [Hz] when
            %            spike is a column vector of 0 or 1.
            %
            % Start_sec  (Optional) A vector of starting time in second.
            %            Must have the same size as spike.
            %            Default equals to zeros(size(Fs))
			%
            % records    A Record objcet or cell vector of Record objects
            %
            % chans      A MetaEventChan (EventChan or MarkerChan) object
            %            or a cell veoctor of MetaEventChan objects %TODO
            %
            % OPTIONAL PARAMETER/VALUE PAIRS
            %
            % PreburstSilence_ms
            %            100 (default)
            %
            % FirstISImax_ms
            %            5 (default)
            %
            % LastISImax_ms
            %            10 (default)
            %
            % Names      A cell vector of strings of Names. Must have the same size as spike.
            %
            %
            % See also
            % K_LTSburst_detect

            %% Parse

            if nargin == 0

                obj = updateGroupdata(obj);

                return
            end

            narginchk(1, inf);
            paramStart = 0;
            for i = 1:length(varargin)
                if ischar(varargin{i}) && isrow(varargin{i}) && ~isempty(varargin{i})
                    paramStart = i;
                    break
                end
            end
            % paramStart = i +1;


            if paramStart == 0 && nargin == 1 || paramStart == 2
                % obj = LTSburst(records, varargin)
                % obj = LTSburst(chans, varargin)

                if rem(nargin, 2) ~= 1
                    error('K:LTSburst:LTSburst:nargin:invalid','invalid input argument numbers');
                end

                p = inputParser;

                p.addRequired('records', @vfspk1);
                records = varargin{1}; % this is before p.parse

                if isa(records, 'Record') || ...
                    iscell(records) &&  all(cellfun(@(x) isa(x, 'Record'), records))
                    % obj = LTSburst(records, varargin)

                    if isa(records, 'Record')
                        records = {records};
                    end

                    isevent = cellfun(@(x) isa(x, 'MetaEventChan'), records);
                    ev = zeros(1, nnz(isevent));

                    p = local_paramval(obj, p, length(ev));

                    p.parse(records, varargin{2:end});

                    obj.PreburstSilence_ms = p.Results.PreburstSilence_ms;
                    obj.FirstISImax_ms     = p.Results.FirstISImax_ms;
                    obj.LastISImax_ms      = p.Results.LastISImax_ms;

                    startsec = zeros(size(records));

                    c = 0;

                    Fs = zeros(1,nnz(isevent));
                    names = cell(1,nnz(isevent));
                    spike = cell(1,nnz(isevent));

                    for i = 1:length(records)
                        for j = 1:length(records{i}.Chans)

                            if isa(records{i}.Chans{j}, 'MetaEventChan')
                                c = c + 1;

                                spike{c} = records{i}.Chans{j}.Data;
                                Fs(c) = records{i}.Chans{j}.SRate;

                                names{c} = [records{i}.RecordTitle, '|', records{i}.Chans{j}.ChanTitle];

                                startsec(c) = records{i}.Chans{j}.Start;

                            end
                        end
                    end

                    obj.Spike = spike;
                    obj.Fs = Fs;
                    obj.Names = names;
                    obj.StartTime = startsec;

                elseif isa(records, 'MetaEventChan') || ...
                    iscell(records) &&  ...
                    all(cellfun(@(x) isa(x, 'MetaEventChan'), records))
                    % obj = LTSburst(chans, varargin)

                    chans = records;
                    clear reords

                    %TODO
                    if isa(chans, 'MetaEventChan')
                        chans = {chans};
                    end

                    if iscolumn(chans)
                        chans = chans';
                    end

                    % isevent = cellfun(@(x) isa(x, 'MetaEventChan'), chans);
                    ev = zeros(1, length(chans));

                    p = local_paramval(obj, p, length(ev));

                    p.parse(chans, varargin{2:end});

                    obj.PreburstSilence_ms = p.Results.PreburstSilence_ms;
                    obj.FirstISImax_ms = p.Results.FirstISImax_ms;
                    obj.LastISImax_ms = p.Results.LastISImax_ms;

                    startsec = zeros(size(chans));

                    c = 0;

                    Fs = zeros(size(chans));
                    names = cell(size(chans));
                    spike = cell(size(chans));

                    for i = 1:length(chans)

                        if isa(chans{i}, 'MetaEventChan')
                            c = c + 1;

                            spike{c} = chans{i}.Data;
                            Fs(c) = chans{i}.SRate;

                            names{c} = chans{i}.ChanTitle;

                            startsec(c) = chans{i}.Start;

                        end
                    end

                    obj.Spike = spike;
                    obj.Fs = Fs;
                    obj.Names = names;
                    obj.StartTime = startsec;

                else
                    error('K:LTSburst:LTSburst:narginOne:syntax:invalid',...
                        ['In LTSburst(records) or LTSburst(chans) syntax, the first input argument %s must be a MetaEventChan object,',...
                        'Record object or cell vector of MetaEventChan objects or Record objects.',...
                        'Try LTSburst(spike,Fs) syntax instead?'],...
                        inputname(1));

                end

            elseif paramStart == 0 && nargin == 2 || paramStart == 3
                % obj = LTSburst(spike, Fs, varargin)

                if rem(nargin, 2) ~= 0

                    error('K:LTSburst:LTSburst:nargin:invalid','invalid input argument numbers');
                end

                p = inputParser;

                p.addRequired('spike', @vfspk2);
                spike = varargin{1};
                if ~iscell(spike)
                    spike = {spike};
                end

                if iscolumn(spike)
                   spike = spike';
                end

                p.addRequired('Fs', @vffs);
                Fs = varargin{2};

				p.addOptional('Start_sec', zeros(size(spike)), @vfstart);

                p = local_paramval(obj, p, length(spike));

                p.parse(spike, Fs, varargin{3:end});

                obj.PreburstSilence_ms = p.Results.PreburstSilence_ms;
                obj.FirstISImax_ms = p.Results.FirstISImax_ms;
                obj.LastISImax_ms = p.Results.LastISImax_ms;


                obj.Spike = spike;
                obj.StartTime = p.Results.Start_sec;

                if iscolumn(Fs)
                    Fs = Fs';
                end
                obj.Fs = Fs;

                names = p.Results.Names;
                if iscolumn(names)
                    names = names';
                end
                obj.Names = names;

            else
                if paramStart == 1 || paramStart > 4
                    error('K:LTSburst:LTSburst:inputargs','invalid input arguments');
                end
            end

            % turn obj.Spike to sparse double to save memory?
            obj.Spike = cellfun(@(x) sparse(double(x)),obj.Spike,'UniformOutput',false);
            obj = updateGroupdata(obj);

        end


        %% property get methods
        function Is = get.Is(obj)
            Is = 1./obj.Fs;
        end
        %--------------------------------------------------------------------------

        function SpikeInfo = get.SpikeInfo(obj)
			C = obj.Groupdata{:, 1}';
            
%             tic
%             SpikeInfo = cellfun(@(x) struct2table(x,'AsArray',true),C,...
%                 'UniformOutput',false); %NOTE "cj = {s.(fnames{j})}';" in tabular.container2vars called by struct2table is SLOW
%             toc % 1.3 sec
%             
%             tic
            
            SpikeInfo = cellfun(@(x) local(x),C,...
                'UniformOutput',false);
            
           % toc % 0.70 sec
            
            function out = local(x)
                
                vn = fieldnames(x);
                c = struct2cell(x);
                k = size(c,1);
                
                C_ = cell(1,k);
                for i = 1:k
                   C_{i} = cell2mat(c(i,:))';
                end

                
                out = table(C_{:},'VariableNames',vn');
                
            end
            
            
        end
        %--------------------------------------------------------------------------

        function ISI = get.ISI(obj)
			ISI = obj.Groupdata{:, 2}';

        end
        %--------------------------------------------------------------------------

        function Onset = get.Onset(obj)

            onset_ind = obj.Groupdata{:, 3};

            spikeInfo = obj.SpikeInfo;

            Onset = cell(1,length(spikeInfo));

            if isempty(onset_ind)
                for i = 1:length(spikeInfo)
                    Onset{i} = false(size(obj.Spike{i}));
                end

            else

                for i = 1:length(spikeInfo)
                    Onset{i} = zeros(size(obj.Spike{i}));

                    Onset{i}([spikeInfo{i}.point(onset_ind{i})]) = 1;

                    Onset{i} = logical(Onset{i});
                end
            end
        end
        %--------------------------------------------------------------------------

        function OnsetInfo = get.OnsetInfo(obj)

			onset_ind = obj.Groupdata{:, 3};
            spikeInfo = obj.SpikeInfo;

            OnsetInfo = cell(1,length(spikeInfo));
			for i = 1:length(spikeInfo)
                if isempty(onset_ind) || isempty(onset_ind{i})
                    % it is supposed to be a struct

                    vn = spikeInfo{i}.Properties.VariableNames;
                    OnsetInfo{i} = cell2table(cell(0,9),'VariableNames',vn);

                else
                    OnsetInfo{i} = spikeInfo{i}(onset_ind{i},:); %TODO slow
                end
			end

        end
        %--------------------------------------------------------------------------

        function Offset = get.Offset(obj)

            offset_ind = obj.Groupdata{:, 4};
            spikeInfo = obj.SpikeInfo;

            Offset = cell(1,length(spikeInfo));

            if isempty(offset_ind)
                for i = 1:length(spikeInfo)
                    Offset{i} = false(size(obj.Spike{i}));
                end
            else

            for i = 1:length(spikeInfo)
                %TODO see get.OnsetInfo(obj)
                Offset{i} = zeros(size(obj.Spike{i}));

                Offset{i}([spikeInfo{i}.point(offset_ind{i})]) = 1;

                Offset{i} = logical(Offset{i});
            end
            end
        end
        %--------------------------------------------------------------------------

        function OffsetInfo = get.OffsetInfo(obj)

			offset_ind = obj.Groupdata{:, 4};
            spikeInfo = obj.SpikeInfo;

            OffsetInfo = cell(1,length(spikeInfo));
			for i = 1:length(spikeInfo)

                if isempty(offset_ind) || isempty(offset_ind{i})
                    % it is supposed to be a struct

                    vn = spikeInfo{i}.Properties.VariableNames;
                    OffsetInfo{i} = cell2table(cell(0,9),'VariableNames',vn);

                else

                    OffsetInfo{i} = spikeInfo{i}(offset_ind{i},:); %TODO slow
                end
			end
        end
        %--------------------------------------------------------------------------

        function MaxTime = get.MaxTime(obj)

			MaxTime = obj.Groupdata{:, 6}';

            % MaxTime = arrayfun(@(x) obj.Is(x)*(length(obj.Spike{x})-1), 1:size(obj.Spike,2))';
        end
        %--------------------------------------------------------------------------


        function ISIordinal = get.ISIordinal(obj)
			[~, ~, ISIordinal] = ...
                K_LTSburst_groupplot(table2cell(obj.Groupdata), 'errorbarmode', 'std', 'doplot', false);
            ISIordinal = ISIordinal';

        end
        %--------------------------------------------------------------------------

        function ISIordinalmeta = get.ISIordinalmeta(obj)
			[~, ~, ~, ISIordinalmeta] = ...
                K_LTSburst_groupplot(table2cell(obj.Groupdata), 'errorbarmode', 'std', 'doplot', false);

        end
        %--------------------------------------------------------------------------

        function ISIordinalmeta_perRecord = get.ISIordinalmeta_perRecord(obj)

			[~, ~, ~, ISIordinalmeta_perRecord] = ...
                K_LTSburst_groupplot(table2cell(obj.Groupdata), 'errorbarmode', 'std',...
                'doplot', false, 'isiordinalmode', 'record');
        end
        %--------------------------------------------------------------------------

        function LTSstats = get.LTSstats(obj)
            % LTSstats = get.LTSstats(obj)
            %
            % LTSstats          Stats of LTS bursts
            %
            %   LTSrate                 mean rate of LTS burst occurence [bursts/sec]
            %   burstduration           duration of LTS bursts [sec]
            %   burstdurationmean       mean duration of LTS bursts [sec]
            %   intraburstISImean       mean intraburst ISI per burst [sec]
            %   intraburstISImeanmean   mean of mean intraburst ISI [sec]
            %   n_bursts                number of burst incidents
            %   spikesperburst          number of spikes in each burst
            %   spikesperburstmean      mean number of spikes in each burst
            %   spikes_all              number of all spikes
            %   spikes_in_burst         number of all spike included in LTS bursts
            %   spikes_in_burst_percent percentage of all spikes included in LTD bursts
            %
            % See also
            % K_LTSburst_groupplot


            n = length(obj.Spike);

            c = cell([n, 1]);
            LTSstats = struct('intraburstISImean', c,...
                'intraburstISImeanmean', c,...
                'intraburstISImedian',c,...
                'intraburstISImedianmedian',c,...
                'spikesperburst', c,...
                'spikesperburstmean', c,...
                'spikesperburstmedian', c,...
                'n_bursts', c,...
                'burstduration', c,...
                'burstdurationmean', c,...
                'burstdurationmedian', c,...
                'LTSrate', c,...
                'spikes_all', c,...
                'spikes_in_burst', c,...
                'spikes_in_burst_percent', c );

            ltsstats = orderfields(LTSstats);
            clear c

            for s =1:n %slow %NOTE parfor is not compatible

                if isempty(obj.OnsetInfo{s})
                    onset_id = [];
                else
                    onset_id = obj.OnsetInfo{s}.id;
                end

                if isempty(obj.OffsetInfo{s})
                    offset_id = [];
                else
                    offset_id = obj.OffsetInfo{s}.id;
                end

                spikeInfo = obj.SpikeInfo{s};
                isi       = obj.ISI{s};

                % mean intraburst ISI [sec]
                % median intraburst ISI [sec]

                ltsstats(s).intraburstISImean = zeros(size(onset_id));
                ltsstats(s).intraburstISImedian = zeros(size(onset_id));

                for i = 1:length(onset_id)
                    ltsstats(s).intraburstISImean(i) = mean(isi(onset_id(i)+1:offset_id(i)));
                    ltsstats(s).intraburstISImedian(i) = median(isi(onset_id(i)+1:offset_id(i)));
                end
                ltsstats(s).intraburstISImeanmean = mean(ltsstats(s).intraburstISImean);
                ltsstats(s).intraburstISImedianmedian = median(ltsstats(s).intraburstISImedian);

                % mean number of spikes per burst

                ltsstats(s).spikesperburst = obj.OnsetInfo{s}.burstsize;
                ltsstats(s).spikesperburstmean = mean(ltsstats(s).spikesperburst);
                ltsstats(s).spikesperburstmedian = median(ltsstats(s).spikesperburst);

                % number of bursts

                ltsstats(s).n_bursts = length(onset_id);

                % mean burstduration of LTS bursts [sec]

                ltsstats(s).burstduration = spikeInfo.time(offset_id) - spikeInfo.time(onset_id);
                ltsstats(s).burstdurationmean = mean(ltsstats(s).burstduration);
                ltsstats(s).burstdurationmedian = median(ltsstats(s).burstduration);


                % mean rate of LTS burst occurence [bursts/sec]
                ltsstats(s).LTSrate = ltsstats(s).n_bursts/(obj.MaxTime(s) - obj.StartTime(s));

                % mean interburst interval
                % TODO how to define? onset-offset? or inverse of LTSrate?

                ltsstats(s).name = obj.Names{s};

                ltsstats(s).spikes_all = size(spikeInfo,1);
                ltsstats(s).spikes_in_burst = sum(ltsstats(s).spikesperburst);

                ltsstats(s).spikes_in_burst_percent = ltsstats(s).spikes_in_burst/...
                    ltsstats(s).spikes_all * 100;

            end

           % LTSstats = (orderfields(ltsstats))';           
%            tic
%            S = (orderfields(ltsstats))';
%                       
%            vn = fieldnames(S);
%            C = struct2cell(S);
%            k = size(C,1);
%            
%                       
%            C_ = cell(1,k);
%            for i = 1:k
%                if all(cellfun(@isnumeric,C(i,:))) ...
%                    && all(cellfun(@isscalar,C(i,:))) 
%                    C_{i} = cell2mat(C(i,:));
%                elseif all(cellfun(@isstring,C(i,:)))
%                    C_{i} = string(C(i,:));
%                else
%                    C_{i} = C(i,:);
%                end
%            end           
%            
%            LTSstats = table(C_{:},'VariableNames',vn);
%            toc
% 
%            tic
           
           LTSstats = struct2table((orderfields(ltsstats))','AsArray',true);
           %NOTE "cj = {s.(fnames{j})}';" in tabular.container2vars called by struct2table is SLOW
           
%           toc %NOTE in this case struct2table is faster than using
%           struct2cells
           
           
 
                
                 
            
        end



        %% Property set methods

        function obj = set.PreburstSilence_ms(obj,value)

            narginchk(2,2);
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('value', @vfpre);
            p.parse(obj,value);

            obj.PreburstSilence_ms = value;

            %TODO prepare Groupdata
            obj = updateGroupdata(obj);

        end
        %--------------------------------------------------------------------------

        function obj = set.FirstISImax_ms(obj,value)

            narginchk(2,2);
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('value', @vfpre);
            p.parse(obj,value);

            obj.FirstISImax_ms = value;

            %TODO prepare Groupdata
            obj = updateGroupdata(obj);

        end
        %--------------------------------------------------------------------------

        function obj = set.LastISImax_ms(obj,value)

            narginchk(2,2);
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('value', @vfpre);
            p.parse(obj,value);

            obj.LastISImax_ms = value;

            %TODO prepare Groupdata
            obj = updateGroupdata(obj);

        end
        %--------------------------------------------------------------------------

        function obj = set.Names(obj,value)

            narginchk(2,2);
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('value', @vfnames);
            p.parse(obj,value);

            assert(length(value) == length(obj.Spike),...
                'K:LTSburst:setNames:length:invalid',...
                'The Names must be provided for all the columns of obj.Spike');

            obj.Names = value;

            %TODO prepare Groupdata
            obj = updateGroupdata(obj);

        end
        %--------------------------------------------------------------------------

        function obj = set.Fs(obj,value)

            narginchk(2,2);
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('value', @vffs);
            p.parse(obj,value);

            assert(length(value) == length(obj.Spike),...
                'K:LTSburst:setFs:length:invalid',...
                'The Fs must be provided for all the columns of obj.Spike');

            obj.Fs = value;

            %TODO prepare Groupdata
            obj = updateGroupdata(obj);

        end
        %--------------------------------------------------------------------------

        function obj = set.StartTime(obj,value)

            narginchk(2,2);
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('value', @vfstart);
            p.parse(obj,value);

            assert(length(value) == length(obj.Spike),...
                'K:LTSburst:setStartTime:length:invalid',...
                'The StartTime must be provided for all the columns of obj.Spike');

            obj.StartTime = value;

            %TODO prepare Groupdata
            obj = updateGroupdata(obj);

        end

        %--------------------------------------------------------------------------

        function obj = set.Spike(obj,value)
            % obj = set.Spike(obj,value)
            %
            % INPUT ARGUMENTS
            % obj         LTSburst object
            %
            % value       0/1 vector | cell vector of 0/1 vectors |
            %             a Record object | cell vector of Record objects
            %

            vfspk = @(x) ...
                 isvector(x) ...
                 &&     (iscell(x) ...
                 &&         all(cellfun(@(y) all(full(y) == 0 | full(y) == 1), x))...
                 ||         all(cellfun(@(y) isa(y, 'Record'), x))) ...
                 ||     all(x == 0 | x == 1) ...
                 || isscalar(x) ...
                 &&    isa(x, 'Record');

            narginchk(2,2);
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('value', vfspk);
            p.parse(obj,value);

            if iscell(value)
                if all(cellfun(@(y) all(full(y) == 0 | full(y) == 1), value))

                    value = cellfun(@(x) sparse(double(x)), value,...
                        'UniformOutput',false);

                elseif all(cellfun(@(y) isa(y, 'Record'), x))
                    %TODO refactor some code in the constructor
                    error('not implemented yet')

                end

            elseif isnumeric(value) || islogical(value)
                value = {sparse(double(value))};
            elseif isa(value,'Record')
                error('not implemented yet')

            elseif isa(value,'FileList')
                error('not supported')
            end

            obj.Spike = value;

            %TODO prepare Groupdata
            obj = updateGroupdata(obj);

        end
        %% General methods

        function objout = selectchan(obj,ind)
            % Only to keep the data in Spike properties that is specified
            % by an index ind. Extract subset of data.
            %
            % objout = selectchan(obj,ind)
            %


            p = inputParser;
            p.addRequired('obj');
            p.addRequired('ind',@(x) isvector(x) && all(fix(x) == x) && all(x >= 0));
            p.parse(obj,ind);

            objout = obj;
            objout.Spike = obj.Spike(ind);
            objout.Names = obj.Names(ind);
            objout.Fs = obj.Fs(ind);
            objout.StartTime = obj.StartTime(ind);


            objout = updateGroupdata(objout);

        end
        %--------------------------------------------------------------------------

        function s = saveobj(obj)

            s.PreburstSilence_ms = obj.PreburstSilence_ms;
            s.FirstISImax_ms = obj.FirstISImax_ms;
            s.LastISImax_ms = obj.LastISImax_ms;

            s.Spike = obj.Spike;
            s.Fs = obj.Fs;
            s.Names = obj.Names;
            s.StartTime = obj.StartTime;

            s.Groupdata = obj.Groupdata;

        end
        %--------------------------------------------------------------------------


        function E = constructOnsetAsEvent(obj)
            if length(obj.Spike) >= 1
                E = cell(length(obj.Spike),1);
            else
               E = [];
               return
            end

            for i = 1:length(obj.Spike)

                E{i} = EventChan(obj.Onset{i},obj.StartTime(i),obj.Fs(i),'onset');

            end

            if length(obj.Spike) >= 1
                E = E{1};
            end


        end
        %--------------------------------------------------------------------------

        function E = constructOffsetAsEvent(obj)

            if length(obj.Spike) >= 1
                E = cell(length(obj.Spike),1);
            else
               E = [];
               return
            end

            for i = 1:length(obj.Spike)

                E{i} = EventChan(obj.Offset{i},obj.StartTime(i),obj.Fs(i),'offset');

            end

            if length(obj.Spike) >= 1
                E = E{1};
            end

        end
        %--------------------------------------------------------------------------

        function M = constructBurstAsMarker(obj)

            if length(obj.Spike) >= 1
                M = cell(length(obj.Spike),1);
            else
               M = [];
               return
            end

            for i = 1:length(obj.Spike)

                data = obj.Onset{i} | obj.Offset{i};

                spkinfo = obj.SpikeInfo{i};

                spkinfo.codes = NaN(height(spkinfo),1);

                spkinfo.codes(logical(spkinfo.onset)) = 1;
                spkinfo.codes(logical(spkinfo.offset)) = 0;


                code00 = spkinfo.codes;

                code00(isnan(spkinfo.codes)) = [];

                codes = [code00, zeros(length(code00),3)];

                M{i} = MarkerChan(data,obj.StartTime(i),obj.Fs(i),codes,'LTS burst');

                M{i}.MarkerName{2,1} = {'onset'};
                M{i}.MarkerName{1,1} = {'offset'};

                newtext = cell(M{i}.NSpikes,1);

                if M{i}.NSpikes > 0
                    newtext(code00(:,1) == 1) = {'onset'};
                    newtext(code00(:,1) == 0) = {'offset'};
                    M{i}.TextMark = newtext;
                end


            end

            if length(obj.Spike) >= 1
                M = M{1};
            end


        end

    end


    methods (Access = private)
        function obj = updateGroupdata(obj)

            groupdata = cell(length(obj.Spike), 9);

            if length(obj.Spike) == length(obj.Fs) ...
                    && length(obj.Spike) == length(obj.StartTime)...
                    && length(obj.Spike) == length(obj.Names)

                for i = 1:length(obj.Spike)

                    [spikeInfo, isi, onset, offset, starttime, maxtime,LTSdef,tooshort] = ...
                        K_LTSburst_detect(obj.Spike{i}, obj.Fs(i), ...
                        'Start_sec', obj.StartTime(i),...
                        'PreburstSilence_ms', obj.PreburstSilence_ms, ...
                        'FirstISImax_ms', obj.FirstISImax_ms,...
                        'LastISImax_ms', obj.LastISImax_ms);

                    groupdata(i, :) = {spikeInfo, isi, onset, offset, starttime, ...
                        maxtime, obj.Names{i},LTSdef,tooshort}; %TODO data type of onset and offset is unpredictable

                end
            end

            groupdata = cell2table(groupdata,'VariableNames',{'spikeInfo',...
                'isi','onset','offset','starttime','maxtime','names','LTSdef','tooshort'});

            % when using cell2table, numeric arrays in cell can be stored
            % as either cell array or numeric array depending on the size
            % of the numeric arrays

            if ~iscell(groupdata.spikeInfo)
                groupdata.spikeInfo = num2cell(groupdata.spikeInfo);
            end

            if ~iscell(groupdata.isi)
                groupdata.isi = num2cell(groupdata.isi);
            end

            if ~iscell(groupdata.onset)
                groupdata.onset = num2cell(groupdata.onset);
            end

            if ~iscell(groupdata.offset)
                groupdata.offset = num2cell(groupdata.offset);
            end

            obj.Groupdata = groupdata;

        end
        %--------------------------------------------------------------------------

        function [burstmax, LTS_i_spikes, onsetLTS_i_spikes] = pvt_getBurstmax(obj)
            %
            % burstmax      a column vector of double containig the maximum
            %               size of LTS bursts for each data in obj.SpikeInfo
            %
            % LTS_i_spikes  Cell column vector containing subsets of
            %               obj.SpikeInfo. All the spikes included in LTS
            %               bursts with N spikes.
            %
            % onsetLTS_i_spikes
            %               Cell column vector containing indices of onset of LTS bursts with N spikes.

            spikeInfo = obj.SpikeInfo;
            n = length(spikeInfo);

            burstmax = nan(n, 1);
            LTS_i_spikes = cell(n, 1);
            onsetLTS_i_spikes = cell(n, 1);

            for s = 1:n % each data

                if ~isempty(max(spikeInfo{s}.burstsize))

                    burstmax(s) = max(spikeInfo{s}.burstsize);
                    LTS_i_spikes{s} = cell(burstmax(s),1);
                    onsetLTS_i_spikes{s} = cell(burstmax(s),1);

                    for i = 2:burstmax(s)
                        try
                            LTS_i_spikes{s}{i} = spikeInfo{s}(spikeInfo{s}.burstsize == i,:);

                            onsetLTS_i_spikes{s}{i} = find(spikeInfo{s}.burstsize' == i & ...
                                spikeInfo{s}.onset' == 1);

                        catch ME
                            getReport(ME, 'extended');
                            keyboard;
                        end
                    end

                else

                end
            end
        end
    end
    %--------------------------------------------------------------------------

    methods (Static)
        function obj = loadobj(s)
            obj = LTSburst;
            obj.PreburstSilence_ms = s.PreburstSilence_ms;
            obj.FirstISImax_ms = s.FirstISImax_ms;
            obj.LastISImax_ms = s.LastISImax_ms;

            obj.Spike = s.Spike;
            obj.Fs = s.Fs;
            obj.Names = s.Names;
            obj.StartTime = s.StartTime;

            obj.Groupdata = s.Groupdata;
        end


    end
end

%--------------------------------------------------------------------------

function p = local_paramval(obj, p, L)

assert(isscalar(L))

p.addParameter('Names', repmat({''}, 1, L), @vfnames);

p.addParameter('PreburstSilence_ms', obj.PreburstSilence_ms, @vfpre);
p.addParameter('FirstISImax_ms', obj.FirstISImax_ms, @vfpre);
p.addParameter('LastISImax_ms', obj.LastISImax_ms, @vfpre);

end

%--------------------------------------------------------------------------

function TF = vfpre(x)

TF = ~isempty(x) && isnumeric(x) && isscalar(x) && isreal(x) && x >= 0;

end

%--------------------------------------------------------------------------

function TF = vffs(x)

TF = isvector(x) && isreal(x) && all(x > 0);

end

%--------------------------------------------------------------------------

function TF = vfnames(x)

TF = ~isempty(x) && iscellstr(x) && isvector(x);

end

function TF = vfstart(x)

TF = ~isempty(x) && isnumeric(x) && isvector(x) && isreal(x);

end

%--------------------------------------------------------------------------

function TF = vfspk(x)

TF = false;

if isvector(x)
    if iscell(x)
        if  all(cellfun(@(y) isa(y, 'Record'), x))....
                || all(cellfun(@(y) isa(y, 'MetaEventChan'), x))
            TF = true;
        elseif all(cellfun(@(y) all(full(y) == 0 | full(y) == 1), x))
            TF = true;
        end
    end
elseif isscalar(x)
    if isa(x, 'Record')...
            || isa(x, 'MetaEventChan')
        TF = true;
    end

end
end

%--------------------------------------------------------------------------

function TF = vfspk1(x)

TF = false;

if isvector(x)
    if iscell(x)
        if  all(cellfun(@(y) isa(y, 'Record'), x))....
            || all(cellfun(@(y) isa(y, 'MetaEventChan'), x))
        TF = true;
        end

    else
        if all(x == 0 | x == 1)
            TF = true;
        end
    end
elseif isscalar(x)
    if isa(x, 'Record')...
            || isa(x, 'MetaEventChan')
        TF = true;
    end

end
end

%--------------------------------------------------------------------------

function TF = vfspk2(x)

TF = false;

if isvector(x)
    if iscell(x)
        if all(cellfun(@(y) all(full(y) == 0 | full(y) == 1), x))
            TF = true;
        end
    else
        if all(x == 0 | x == 1)
            TF = true;
        end
    end
end
end
