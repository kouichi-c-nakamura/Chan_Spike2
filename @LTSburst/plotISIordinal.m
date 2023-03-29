function h = plotISIordinal(obj, varargin)
% plot ISIs against ISI ordinal
%
% h = plotISIordinal(obj, 'param', value)
% h = plotISIordinal(obj, ax,'param', value)
%
% INPUT ARGUMENTS
%
% ax                  (optional) an Axes object.
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'errorbarmode'      'std'  | 'sem' (default) | 'none'
%
% 'errorwidth'        [] (defatlt)
%                     Real value for the widht of error
%                     whiskers
%
% 'nudgeinterval'     0.05 (default)
%                     Real value for the gap to avoid overlap
%
% 'nudgelimit'        0.4 (default)
%                     Defines how far data points can go off the original x value.   
%
% 'color'             'b' (default)
%                     colorspec
%
% 'per'               'isi' (default), 'record'
%
% 'spikerange'        example: 2:6, [2 4 5]
%                     Two element vector that specifies the number of spikes 
%                     (intergers >= 2) included in bursts to be plotted.
%                     Default is [] which means no limit.
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 15-Aug-2017 16:04:02
%
% See also
% LTSburst.plotFistISI


[ax,errorbarmode,errorwidth,color,per,spikerange,nudgeinterval,nudgelimit,M]...
    = parse(obj,varargin{:});

%% Job

if isempty(ax)

    h.fig = figure;
    h.axes = axes;
    ax = h.axes;
    

else
    h.axes = ax;
    axes(ax);
    h.fig = gcf;
    
end

if isnan(M)
   warning('Nothing to plot.') 
   xlabel(ax,'ISI Ordinal');
   ylabel(ax,'Intraburst ISI (ms)');
   h = [];
    
end

hold(h.axes,'on')
if verLessThan('matlab','8.4.0')
    h.line = zeros(M, 1);
    h.e1 = zeros(M, 1);
else
    h.line = gobjects(M, 1);
    h.e1 = gobjects(M, 1);
end
TF = false(M, 1); % true for included data
markerseries = {'o','^','s','p','v','x','d'}; % seven markers
markercolor = {'none', color};
legendstr = cell(1, M);

nudgeleft = nudgeinterval*(M - 2)/2;

if nudgeleft > nudgelimit 
    nudgeleft = nudgelimit; % limit the nudgeleft to avoid overlapping with next size
end

for i = spikerange
    switch per
        case 'isi'
            isiordinalmeta = table2cell(obj.ISIordinalmeta);
        case 'record'
            isiordinalmeta = table2cell(obj.ISIordinalmeta_perRecord);
    end
    if ~isempty(isiordinalmeta{i,1})
        TF(i) = true;
        if nudgeleft < nudgelimit
            j = i-2;
        else
            j = rem(i-2,fix(nudgelimit*2/nudgeinterval)); % cycle the position
        end
        X = (1:(i-1)) - nudgeleft + nudgeinterval*j;
        
        switch lower(errorbarmode)
            case 'std'
                h.line(i) = errorbar(ax,X, nanmean([isiordinalmeta{i,:}], 1)*1000, ...
                    nanstd([isiordinalmeta{i,:}], 0, 1)*1000);
                set(h.line(i),'Tag',sprintf('Mean and STD %d',i));
            case 'sem'
                n_samples = nnz(~isnan([isiordinalmeta{i,:}]));
                
                h.line(i) = errorbar(ax,X, nanmean([isiordinalmeta{i,:}], 1)*1000, ...
                    nanstd([isiordinalmeta{i,:}], 0, 1)*1000/sqrt(n_samples));
                set(h.line(i),'Tag',sprintf('Mean and SEM %d',i));
                clear n_samples
            otherwise
                h.line(i) = line(ax,X, nanmean([isiordinalmeta{i,:}], 1)*1000,...
                'Tag',sprintf('Mean %d',i));
        end
        
        set(h.line(i),...
            'Color', color, ...
            'Marker', markerseries{rem((i-2),7) + 1},... %Cycle through markers
            'MarkerFaceColor', markercolor{rem(floor((i-2)/7),2) +1}); % alternate face color
        
        if ~isempty(spikerange)
            if ~ismember(i,spikerange)
                set(h.line(i), 'Visible', 'off');
                
                TF(i) = false;
            end
            
        end
        
        if ~isempty(errorwidth)
            child1 = get(h.line(i), 'Children');
            local_seterrorwidth(child1(2), errorwidth);
        end
        
        legendstr{i} = sprintf('%d (n = %d)', i, length(isiordinalmeta{i,1}));
        
    end

end

if M > 0
    if isempty(spikerange)
        xlim(ax,[0, M+1]);
        xticklabeltidy(ax, 1:(M - 1), 0);
    else
        xlim(ax,[0, max(spikerange) + 1]);
        xticklabeltidy(ax, 1:(max(spikerange) - 1), 0);        
    end
end
ylim(ax,[0 max(ylim(ax))]);
xlabel(ax,'ISI Ordinal');
ylabel(ax,'Intraburst ISI (ms)');

% legend
dummy = line(ax,0,0,'Marker','none','LineStyle','none','Tag','Dummy');

switch per
    case 'isi'
        dummystr = {'Spikes in Burst (n per ISI)'};
    case 'record'
        dummystr = {'Spikes in Burst (n per Record)'};
end
h.leg = legend(ax,[dummy;h.line(TF)], [dummystr,legendstr(TF)], ...
    'Location','southeast', 'FontSize', 9);
h.leg.Box = 'off';


%% store parameters in axes.UserData

h.axes.UserData.PreburstSilence_ms = obj.PreburstSilence_ms;
h.axes.UserData.FirstISImax_ms     = obj.FirstISImax_ms;
h.axes.UserData.LastISImax_ms      = obj.LastISImax_ms;
h.axes.UserData.Fs                 = obj.Fs;
h.axes.UserData.StartTime          = obj.StartTime;
h.axes.UserData.Names              = obj.Names;

end

%--------------------------------------------------------------------------

function [ax,errorbarmode,errorwidth,color,per,spikerange,nudgeinterval,...
    nudgelimit,M] = parse(obj,varargin)

p = inputParser;
p.addRequired('obj');
p.addOptional('ax',[],@(x) isscalar(x) && isgraphics(x,'axes'));
p.addParameter('errorbarmode', 'sem', @(x) ismember(x, {'none','std', 'sem'}));
p.addParameter('errorwidth', [], ...
    @(x)  isnumeric(x)  && isempty(x) || isreal(x) && x >= 0 );
p.addParameter('nudgeinterval', 0.05, ...
    @(x)   ~isempty(x) && isscalar(x) && isreal(x) && x >= 0 );
p.addParameter('nudgelimit', 0.4, @(x) ~isempty(x) && isscalar(x) && isreal(x)...
    && x >= 0 && x <= 0.5);
p.addParameter('color', 'b', @(x) iscolorspec(x) );
p.addParameter('per', 'isi', @(x) ismember(x, {'isi','record'}));
p.addParameter('spikerange', [], @(x) isrow(x) && all(x >= 2) && all(fix(x) == x));

p.parse(obj, varargin{:});

ax = p.Results.ax;

errorbarmode  = p.Results.errorbarmode;
errorwidth    = p.Results.errorwidth;
color         = p.Results.color;
per           = p.Results.per;
spikerange    = p.Results.spikerange;
nudgeinterval = p.Results.nudgeinterval;
nudgelimit    = p.Results.nudgelimit;

M = max(pvt_getBurstmax(obj));

assert(isempty(spikerange) || max(spikerange) <= M,...
    ['spikerange must be a row vector of integers equal to or larger than 2 ',...
    'and no more than the maximum number of spikes included in bursts'])

if isempty(spikerange)
    spikerange = 2:M;
end
end