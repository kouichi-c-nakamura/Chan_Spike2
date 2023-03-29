function h = plot(obj, varargin)
% h = plot(obj)
% h = plot(obj, 'Param', Value)
% h = plot(obj, ax, 'Param', Value, ...)
%      'Param', Value pairs for line function
%
% TODO doesn't support text marks on plot
%
%
%TODO doesn't support code1 to code3!!!
% How to define the code for color and text?
% you need to specify which one is used for plot
% see MarkShow() function in Spike2
%
%TODO support state draw mode
% h = plot(obj, ax, 'mode', 'Param', Value, ...)???
% mode       'line'
%            'dot'
%            'state'


%% parse
narginchk(1, inf);

if nargin == 1
    fig = figure;
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
            
            fig = get(ax, 'Parent');
            if ~strcmp(get(fig, 'Type'), 'figure')
                warning('K:EventChan:plot:fig:invalid',...
                    'fig is not a valid figure handle.')
            end
            
            PVset = varargin(2:end);
            
        else
            error('K:EventChan:plot:ax:invalid',...
                'not valid axes handle.');
        end
        
         ylim(ax, [-1.3, 1.3]);
       
    else
        fig = figure;
        ax = axes;
        ylim(ax, [-10, 10]);
        
        PVset = varargin;
        %TODO enable to show TextMark? or MarkerName?
        
    end
end

%% job


colorOrder = get(ax, 'ColorOrder');

codeSet = unique(table2array(obj.MarkerCodes(:,1))); % stores the set of all the code numbers used


% spkInfo = obj.getSpikeInfo;
% code0 = spkInfo.code0; % reflects MarkerFilter %TODO
codes = table2array(obj.MarkerCodes(:,1)); % reflects MarkerFilter

times = obj.TimeStamps;  % reflects MarkerFilter
times_forCodes = cell(length(codeSet), 1); % corresponds to each code in codeset

for i = codeSet'
    times_forCodes{i+1} = times(codes == i, :);
end

xlim(ax, [obj.Start, obj.MaxTime]);
set(ax, 'TickDir', 'out', 'Box', 'off');
xlabel(ax, 'Time (sec)');
set(ax, 'YTick', 0, 'YTickLabel', obj.ChanTitle,'TickLabelInterpreter','none');


axes(ax);
hold(ax,'on');

l1 = plot(ax,[obj.Start, obj.MaxTime], [0, 0], 'Color', 'k','Tag','Horizontal Bar');
l2 = cell(length(codeSet), 1); % handle container
t1 = cell(length(codeSet), 1);
for  i = codeSet' % draw code by code
    
    Xcol = times_forCodes{i+1}; % column vector of timestamps
    
    if ~isempty(Xcol)

        l2{i+1} = plot(ax, [Xcol'; Xcol'], [-1, 1],'Tag','Marker Event');
        
        if i == 0 % if code0 use black
            color1 =  [0, 0, 0];
        else
            if rem(i, size(colorOrder, 1)) == 0
                color1 =  colorOrder(size(colorOrder, 1), :);
            else
                color1 =  colorOrder(rem(i, size(colorOrder, 1)), :);
            end
        end
        set(l2{i+1}, 'Color', color1);

        % Text for MarkerCodes
        t1{i+1} = text(Xcol, repmat(1.2, size(Xcol)), ...
            num2str(i, '%x'), 'FontSize', 7, 'HorizontalAlignment', 'center',...
            'Color', color1,'Tag','Marker Code','Clipping','on');
    end
end
hold(ax,'off')

if exist('PVset', 'var') && ~isempty(PVset)
    set(l1, PVset{:});
    set(l2, PVset{:});
end

h.fig = fig;
h.ax = ax;
h.l1 = l1;
h.l2 = l2;

end