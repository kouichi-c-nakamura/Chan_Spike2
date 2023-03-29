classdef WaveMarkChan < MarkerChan
    %
    % Implementation of this class is very least. 
    %
    % Supported methods:
    %   WaveMarkChan.overdrawwavemark
    %   WaveMarkChan.plot
    %   WaveMarkChan.extractTime
    %   WaveMarkChan.vertcat
    %   Record.plot
    %   Record.writesmrx
    %   
    %
    % On the other hand, many methods won't work properly:
    %   resample, saveobj, loadobj
    % 
    % You cannot save objects of this class yet.
    
   properties
       
       Traces double = [] % array of waveform traces: rows, spikes; columns, time (data point). %TODO Spike2 support up to 4 traces of the same length per spike .... if we need it, use the 3rd dimension?
       Scale (1,1) double {mustBeReal} =  1/double(intmax('int16'));% cf. WaveformChan
       Offset (1,1) double {mustBeReal} = 0
       Trigger (1,1) double {mustBePositive, mustBeInteger} = 1 % scalar positive integer defining the trigger point
       
   end
   
   
   properties (Hidden, SetAccess = private)
        TracesAll_
   end
   
   
   methods
       
       function obj = WaveMarkChan(data, start, srate, codes, traces, scale, ...
               offset, trigger, chantitle)
           % short description comes here
           %
           % SYNTAX
           % obj = WaveMarkChan(data, start, srate, codes, traces, scale, ...
           %    offset, trigger, chantitle)
           % [D] = func1(A,B)
           % [D] = func1(____,'Param',value)
           %
           % longer description may come here
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
           % traces
           % scale
           % offset
           % trigger           
           % chantitle   string
           %
           % OUTPUT ARGUMENTS
           % obj         WaveMark object
           %
           % Written by Kouichi C. Nakamura Ph.D.
           % MRC Brain Network Dynamics Unit
           % University of Oxford
           % kouichi.c.nakamura@gmail.com
           % 01-Oct-2020 16:12:05
           %
           % See also
           % MarkerChan
                      
       
           switch nargin 
               case 9
                   superargin = {data, start, srate, codes, chantitle};
               case 0
                   superargin = {};
               otherwise 
                   error('wrong input arguments')
           end
           
           
           obj = obj@MarkerChan(superargin{:}); %NOTE must be top level and only once
           
           switch nargin
               case 9
                   obj.Traces = traces; % array data for WaveMarks
                   
                   obj.Scale = scale;
                   obj.Offset= offset;
                   
                   obj.Trigger = trigger; % scalar positive integer defining the trigger point
                   obj.DataUnit = 'mV'; %TODO 
           end
     
       end
       
       function traces = get.Traces(obj)
                      
           traces = obj.TracesAll_(obj.VisibleSpikes_,:);
                      
       end
       
       function obj = set.Traces(obj,newTraces)
           
           assert(size(newTraces,1) == obj.NSpikesAll_)
           
           obj.TracesAll_ = newTraces;
           
       end
       
       function h = overdrawwavemark(obj,ax,args)
           % WaveMarkChan.overdrawwavemark draws overdraw wavemarks and average
           % spike waveform.
           %
           % If you want wavemark overdraw for a specific subset of spikes,
           % you can do so by using obj.MakerCodes and obj.MarkerFilter
           %
           % SYNTAX
           % h = overdrawwavemark(obj)
           % h = overdrawwavemark(obj,ax)
           % h = overdrawwavemark(____,'Param',value)
           %
           % INPUT ARGUMENTS
           % obj         WaveMarkChan object
           %
           % ax          axes
           %             (Optional) Target Axes object to draw in.
           %
           %
           % OPTIONAL PARAMETER/VALUE PAIRS
           % 'OverdrawColor'
           %             colorspec | [0.5 0.5 0.5] (default)
           %             (Optional) Specifies the color of WaveMark overdraw.
           %
           % 'OverdrawAlpha'
           %             scalar ! 0.5 (default)
           %             (Optional) Must be between 0 and 1. Specifies alpha of
           %             WaveMark overdraw.
           %
           % 'MarkerCodesCol'   non-negative interger (1 to 4)
           %             Which column of MarkerCodes to be considered.
           %
           % 'OverdrawLimit'
           %             [] (default) | non-negative number
           %             Maximum number of spike waveforms to be overdrawn.
           %             If you put 0, no overdraw will be shown.
           %
           %
           % OUTPUT ARGUMENTS
           % h           structure of graphic objects
           %
           % Written by Kouichi C. Nakamura Ph.D.
           % MRC Brain Network Dynamics Unit
           % University of Oxford
           % kouichi.c.nakamura@gmail.com
           % 04-Oct-2020 08:29:
           %
           % See also
           % MarkerChan
           
           
           
           arguments
               
               obj
               
               ax {vf_ax(ax)} = []
               
               args.OverdrawColor {vf_OverdrawColor(args.OverdrawColor)} = [0.5 0.5 0.5]
               
               args.OverdrawAlpha (1,1) double {mustBeGreaterThanOrEqual( args.OverdrawAlpha, 0), ...
                   mustBeLessThanOrEqual( args.OverdrawAlpha, 1)} = 0.5;
               
               args.AverageColor {vf_AverageColor(args.AverageColor)} = []
               
               args.MarkerCodesCol (1,1) double {mustBeInteger, ...
                   mustBeGreaterThanOrEqual(args.MarkerCodesCol, 1), ...
                   mustBeLessThanOrEqual(args.MarkerCodesCol, 4)} = 1
               
               args.OverdrawLimit double {vf_OverdrawLimit(args.OverdrawLimit)} = [];
           end
                      
           codes = unique(obj.MarkerCodes{:,args.MarkerCodesCol});
           AX = ax;
           
           if ~isempty(AX)
                assert(length(AX) == length(codes));
           end
           
           fig = gobjects(length(codes),1);
           l2 = gobjects(length(codes),1);
           hg = gobjects(length(codes),1);
           
           if isempty(args.AverageColor)
               
               if any(codes == 0)
                   aveColor(1,:) = [0 0 0];
                   if ~isempty(codes(codes ~= 0))
                       aveColor(2:end,:) = defaultPlotColors(codes(codes ~= 0));
                   else
                       aveColor = defaultPlotColors(codes);

                   end
               else
                   aveColor = defaultPlotColors(codes);
                   
               end
           else
               aveColor = args.AverageColor;
           end

           
           for c = 1:length(codes)

           
           
               if isempty(AX)
                   clear ax % NOTE needed for type change
                   fig(c) = figure;
                   ax(c) = axes;
               else
                   fig(c) = ancestor(ax(c),'figure');
               end
               
               t_ms = ((obj.Trigger -1)*obj.SInterval : obj.SInterval : ...s
                   (size(obj.Traces,2) - obj.Trigger)*obj.SInterval) * 1000;
               
               hg(c) = hggroup(ax(c));
               
               
               
               tf = false(nnz(obj.MarkerCodes{:,args.MarkerCodesCol} == codes(c)),1);
               if isempty(args.OverdrawLimit)  || length(tf) <= args.OverdrawLimit
                   tf(:) = true;
               else
                   
                   tf(randperm(length(tf), args.OverdrawLimit)) = true;
                   
               end
               
               k = 0;
               for i = 1:size(obj.Traces,1)
                   if obj.MarkerCodes{i,args.MarkerCodesCol} == codes(c)
                       k = k + 1;
                       if tf(k)
                           l = linealpha(ax(c),t_ms,obj.Traces(i,:), args.OverdrawColor, ...
                               args.OverdrawAlpha);
                           l.Parent = hg(c);
                       end
                   end
               end
               
               
               if c > size(aveColor,1)
                   j = rem(c,size(aveColor,1));
                   if j == 0
                       j = size(aveColor,1);
                   end
               else
                   j = c;
               end
               
               l2(c) = line(ax(c),t_ms, mean(obj.Traces,1),'Color', aveColor(j,:),...
                   'LineWidth',1.5,...
                   'DisplayName','Average Spike Waveform');
               
               xlabel(ax(c),'Time (ms)');
               ylabel(ax(c),sprintf('%s (%s)', obj.ChanTitle, obj.DataUnit),...
                   'Interpreter','none');
               title(sprintf('%s, #%d',...
                   obj.ChanTitle,...
                   codes(c)),...
                   'Interpreter','none')
               
               tickdir(ax(c),'out')
               

           end
           
           h.fig = fig;
           h.ax = ax;
           h.l1 = hg;
           h.l2 = l2;
           
           
       end
       
       function mk = getMarkerChan(obj)
           
           mk = MarkerChan;
           
           mk.ChanTitle = obj.ChanTitle;           
           mk.Data = obj.Data;
           mk.MarkerFilter = obj.MarkerFilter;
           mk.MarkerName = obj.MarkerName;
           mk.TextMark = obj.TextMark;
           mk.MarkerCodes = obj.MarkerCodes;
           mk.SRate = obj.SRate;
           mk.Start = obj.Start;
           mk.Header = obj.Header;
           % mk.Path = obj.Path;           
           mk.DataUnit = obj.DataUnit;
           mk.ChanNumber = obj.ChanNumber;
           
       end
    
       function s = saveobj(obj)
           
           s.ChanInfo_    = obj.ChanInfo_;
           s.Data_        = obj.Data_;

           s.MarkerFilter = obj.MarkerFilter;
           % s.MarkerName   = obj.MarkerName;                      
           s.Traces = obj.Traces;
           
           s.Scale = obj.Scale;
           s.Offset = obj.Offset;
           s.Trigger = obj.Trigger;
       end
           
       
   end
   
   methods (Static)
       
       function obj = loadobj(s)
           
           assert(~isempty(s))
           
           obj = WaveMarkChan;
           obj.ChanInfo_    = s.ChanInfo_;
           obj.Data_        = s.Data_;

           obj.MarkerFilter = s.MarkerFilter;
           % obj.MarkerName   = s.MarkerName;
           obj.Traces = s.Traces;
           
           obj.Scale = s.Scale;
           obj.Offset = s.Offset;
           obj.Trigger = s.Trigger;
           
       end
       
   end
   
   
    
    
    
end


function vf_ax(x)

assert(isempty(x) || all(isgraphics(x,'axes')))

end

function vf_OverdrawColor(x)

assert(all(iscolorspec(x)))

end

function vf_AverageColor(x)

assert(isempty(x) || all(iscolorspec(x)))

end


function vf_OverdrawLimit(x)

assert(isempty(x) || isscalar(x) && x >=0)

end