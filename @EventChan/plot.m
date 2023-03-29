function h = plot(obj, varargin)
% h = plot(obj)
% h = plot(obj, 'Param', Value)
% h = plot(obj, ax, 'Param', Value, ...)
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'Param', Value pairs for line function are available
%
% See also
% WaveformChan.plot, MarkerChan.plot

%% parse
narginchk(1, inf);
 
if nargin == 1
    figh = figure;
    ax = axes;
    ylim(ax, [-10, 10]);

    
elseif nargin >=2
    if ishandle(varargin{1})
        ax = varargin{1};
        if isscalar(ax) && ishandle(ax)
        
            if ~strcmp('axes', get(ax, 'Type'))
                error('K:EventChan:plot:ax:invalid',...
                    'not valid axes handle.');
            end
        
            figh = get(ax, 'Parent');
            if ~strcmp(get(figh, 'Type'), 'figure')
               warning('K:EventChan:plot:figh:invalid',...
                   'figh is not a valid figure handle.') 
            end
           
            PVset = varargin(2:end);
            
        else
            error('K:EventChan:plot:ax:invalid',...
                'not valid axes handle.'); 
        end
        
    else
        figh = figure;
        ax = axes;
        ylim(ax, [-10, 10]);

        PVset = varargin;
    end
end

%% job

xlim(ax, [obj.Start, obj.MaxTime]);
set(ax, 'TickDir', 'out', 'Box', 'off');
xlabel(ax, 'Time (sec)');
% ylabel(ax, obj.ChanTitle);
set(ax, 'YTick', 0, 'YTickLabel', obj.ChanTitle,'TickLabelInterpreter','none'); %TODO 'TickLabelInterpreter','none' might result in disappearance of YTickLabels when there are many (50+) channels to show


hold(ax,'on')
ts = obj.TimeStamps; % column
l1 = plot(ax,[obj.Start, obj.MaxTime], [0, 0], 'Color', 'k','Tag','Horizontal Bar');
if isempty(ts)
    l2 = gobjects(0);
else
    
    % l2 = plot(ax,[ts, ts]', [-1, 1]', 'Color', 'k','Tag','Event'); %NOTE much slower
    
    X = [ts, ts, NaN(size(ts))]';
    X = X(:);
    
    Y = [-1*ones(size(ts)), ones(size(ts)), NaN(size(ts))]';
    Y = Y(:);   
    
    l2 = plot(ax, X, Y, 'Color', 'k','Tag','Event');
    
end
hold(ax,'off')

if exist('PVset', 'var') && ~isempty(PVset)
    set(l1, PVset{:});
    set(l2, PVset{:});
end

ylim(ax,[-1.2, 1.2])

h.figh = figh;
h.ax = ax;
h.l1 = l1;
h.l2 = l2;

%TODO ref:_00Di0Ha1u._5000Z1GkYIU:ref
if verLessThan('matlab','9.7.0')
    pan(ax,'xon');zoom(ax,'xon');
else
    pan(ax,'on');zoom(ax,'on');
end    


end