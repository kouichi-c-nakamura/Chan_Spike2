function h = plot(obj,varargin)
% WaveMarkChan.plot is a mehtod to plot WaveMark data either in waveform
% sytle or marker style.
%
% SYNTAX
% l1 = plot(obj,drawmode)
% l1 = plot(____,'Param',value,...)
% l1 = plot(obj,ax,____)
%
% longer description may come here
%
% INPUT ARGUMENTS
% obj         WaveMarkChan object
%
% drawmode    'waveform' (default) | 'marker'
%            (Optional) Specifies the plot style.
% 
%
% OPTIONAL PARAMETER/VALUE PAIRS
% You can add paramter/value pairs to modify line objects.
%
% OUTPUT ARGUMENTS
% h           structure of graphic objects
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 03-Oct-2020 19:47:01
%
% See also
% MarkerChan.plot, WaveformChan.plot


%NOTE varargin{1} can be ax

if ~isempty(varargin) && isscalar(varargin{1}) && isgraphics(varargin{1},'axes')
    ax = varargin{1};
    fig = ancestor(ax,'figure');
    vargs = varargin(2:end);
else
    
    fig = figure;
    ax = axes;
    vargs = varargin;
end

% vargs{1} (after renewal) is always drawmode
drawmode = 'waveform';
if ~isempty(vargs)
    if ischar(vargs{1}) && isrow(vargs{1}) && ...
            ismember(lower(vargs{1}),{'waveform','marker'})
        
        drawmode = lower(vargs{1});
        vargs = vargs(2:end);
        
    end
end


switch lower(drawmode)
    case 'marker'
        
        plot@MarkerChan(obj,ax,vargs{2:end})
        
    case 'waveform'
        
        xlim(ax, [obj.Start, obj.MaxTime]);
        
        set(ax, 'TickDir', 'out', 'Box', 'off');
        xlabel(ax, 'Time (sec)');
        ylabel(ax, sprintf('%s (%s)', obj.ChanTitle, obj.DataUnit),'Interpreter','none');
        
        hold(ax,'on')
        
        l1 = gobjects(obj.NSpikes,1);
        for i = 1:obj.NSpikes
            
            if obj.MarkerCodes{i,1} == 0
                color1 = 'k';
            else
                color1 = defaultPlotColors(obj.MarkerCodes{i,1});
            end
            
            l1(i) = plot(ax, ...
                progression(obj.TimeStamps(i),obj.SInterval,size(obj.Traces,2)),...
                obj.Traces(i,:),'Tag','WaveMark',....
                'Color',color1,...
                'DisplayName',sprintf('spike %d',i));
            
            text(ax,obj.TimeStamps(i),max(obj.Traces(i,:)),sprintf('%d',obj.MarkerCodes{i,1}),...
                'Color',color1,...
                'FontSize',8,...
                'Tag',sprintf('spike %d label',i));
            
            if ~isempty(vargs)
                if rem(length(vargs), 2) == 0
                set(l1(i), vargs{:});
                else
                   error('The parameter/value pairs must be even number.') 
                end
            end
        end
        
        
        hold(ax,'off')
        
        
        h.fig = fig;
        h.ax = ax;
        h.l1 = l1;
        
end