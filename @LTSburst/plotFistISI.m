function h = plotFistISI(obj, varargin)
% plot the first ISIs against the burst size
%
% h = plotFistISI(obj, 'param', value)
% h = plotFistISI(obj, ax, 'param', value)
%
% INPUT ARGUMENTS
%
% ax                  (optional) an Axes object.
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'ErrorbarMode'      'std' | 'sem' (default) | 'none'
%
% 'ErrorbarFunc'      'errorbar' (default) | 'shadederrorbar'
%
% 'ErrorWidth'        [] (defatlt)
%                     Real value for the widht of error
%                     whiskers
%
% 'ShowMarkers'       true (default) | false | 1 | 0
%                     If true, shows markers at each data point.
%
% 'Color'             'b' (default)
%                     colorspec
%
% 'Per'               'isi' (default), 'record'
%
% 'SpikeRange'        example: 2:6, [2 4 5]
%                     Two element vector that specifies the number of spikes
%                     (intergers >= 2) included in bursts to be plotted.
%                     Default is [] which means no limit.
%
% See also
% LTSburst, LTSburst.plotISIordinal, shadederrorbar

[ax,errorbarmode,errorbarfunc,errorwidth,color,per,spikerange,markerseries,...
    markercolor,showmarkers] = parse(obj,varargin{:});

%% Job

switch per
    case 'isi'
        isiordinalmeta = table2cell(obj.ISIordinalmeta);
    case 'record'
        isiordinalmeta = table2cell(obj.ISIordinalmeta_perRecord);
end

[burstmax] = pvt_getBurstmax(obj);
M = max(burstmax);

assert(isempty(spikerange) || max(spikerange) <= M,...
    ['spikerange must be a row vector of integers equal to or larger than 2 ',...
    'and no more than the maximum number of spikes included in bursts'])

if isempty(spikerange)
    SpikeRange = 2:M;
else
    SpikeRange = sort(spikerange);
end

if isempty(ax)
    h.fig = figure;
    h.axes = axes;
    ax = h.axes;
else
    h.axes = ax;
    axes(ax);
    h.fig = gcf;
end

hold on

if M > 0
    switch lower(errorbarmode)
        case 'std'
            switch lower(errorbarfunc)
                case 'errorbar'
                    h.line = errorbar(ax,SpikeRange, ...
                        cellfun(@(X) nanmean(X,1)*1000, isiordinalmeta(SpikeRange,1)'),...
                        cellfun(@(X) nanstd(X,1)*1000, isiordinalmeta(SpikeRange,1)'));
                    set(h.line,'Tag','Mean and STD');
                case 'shadederrorbar'
                    h.errorrange = shadederrorbar(ax,SpikeRange, ...
                        cellfun(@(X) nanmean(X,1)*1000, isiordinalmeta(SpikeRange,1)'),...
                        cellfun(@(X) nanstd(X,1)*1000, isiordinalmeta(SpikeRange,1)'),...
                        color,color);

                    h.line = line(ax,SpikeRange,cellfun(@(X) nanmean(X,1)*1000, isiordinalmeta(SpikeRange,1)'));
                    set(h.line,'Tag','Mean and STD');
                
              end
        case 'sem'
            switch lower(errorbarfunc)
                case 'errorbar'
                    h.line = errorbar(ax,SpikeRange, ...
                        cellfun(@(X) nanmean(X,1)*1000, isiordinalmeta(SpikeRange,1)'),...
                        cellfun(@(X) nanstd(X,1)*1000/sqrt(nnz(~isnan(X))), isiordinalmeta(SpikeRange,1)'));
                    set(h.line,'Tag','Mean and SEM');
                case 'shadederrorbar'
                    h.errorrange = shadederrorbar(ax,SpikeRange, ...
                        cellfun(@(X) nanmean(X,1)*1000, isiordinalmeta(SpikeRange,1)'),...
                        cellfun(@(X) nanstd(X,1)*1000/sqrt(nnz(~isnan(X))), isiordinalmeta(SpikeRange,1)'),...
                        color,color);

                    h.line = line(ax,SpikeRange,cellfun(@(X) nanmean(X,1)*1000, isiordinalmeta(SpikeRange,1)'));
                    set(h.line,'Tag','Mean and STD');
        
            end
        otherwise
            h.line = line(ax,SpikeRange, cellfun(@(X) nanmean(X,1)*1000, isiordinalmeta(SpikeRange,1)',...
                'Tag','Mean'));
    end

    set(h.line, 'Color', color);

    legendstr = cell(1, M);
    TF = false(M, 1); % true for included data
    for i=SpikeRange
        if ~isempty(isiordinalmeta{i,1})
            TF(i) = true;

            h.mark(i) = line(ax,i, cellfun(@(X) nanmean(X,1)*1000, isiordinalmeta(i,1)'),...
                'LineStyle', 'none', ...
                'MarkerEdgeColor', color, ...
                'Marker', markerseries{rem((i-2),7) + 1},... %Cycle through markers (see above)
                'MarkerFaceColor', markercolor{rem(floor((i-2)/7),2) +1},... % alternate face color (see above)
                'Tag',sprintf('Markers %d',i));

            legendstr{i} = sprintf('%d (n = %d)', i, length(isiordinalmeta{i,1}));
        end
    end

    if ~showmarkers
        set(h.mark(isgraphics(h.mark)),'Visible','off')
    end

    if ~isempty(errorwidth)
        child2 = get(h.line, 'Children');
        local_seterrorwidth(child2(2), errorwidth);
    end
else
    h.mark = [];
    legendstr = '';
    TF = false;
end

xticklabeltidy(ax, 2:(max(SpikeRange)-1), 0);
yticklabeltidy(ax, 0:0.5:10, 1);
ylim(ax,'auto');
ylim(ax,[0 max(ylim(ax))]);
if M > 0
    xlim(ax,[1, max(SpikeRange)+1]);
end
xlabel(ax,'The number of spikes in bursts');
ylabel(ax,'The first ISI in bursts (ms)');

dummy = line(ax,0,0,'Marker','none','LineStyle','none','Tag','Dummy');

switch per
    case 'isi'
        dummystr = {'Spikes/Burst (n per ISI)'};
    case 'record'
        dummystr = {'Spikes/Burst (n per Record)'};
end
h.leg = legend(ax,[dummy,h.mark(TF)], [dummystr,legendstr(TF)], ...
    'Location','southeast', 'FontSize', 9);
h.leg.Box = 'off';


if ~showmarkers
    h.leg.Visible = 'off';
end

end

%--------------------------------------------------------------------------

function [ax,errorbarmode,errorbarfunc,errorwidth,color,per,spikerange,...
  markerseries,markercolor,showmarkers] = parse(obj,varargin)

p = inputParser;
p.addRequired('obj');
p.addOptional('ax',[],@(x) isscalar(x) && isgraphics(x,'axes'));
p.addParameter('errorbarmode', 'sem', @(x) ismember(x, {'none','std', 'sem'}));
p.addParameter('errorbarfunc', 'errorbar', @(x) ismember(x, {'errorbar', 'shadederrorbar'}));
p.addParameter('errorwidth', [], ...
    @(x)  isnumeric(Value)  && isempty(Value) || isreal(Value) && Value >= 0 );
p.addParameter('color', 'b', @(x) iscolorspec(x) );
p.addParameter('per', 'isi', @(x) ismember(x, {'isi','record'}));

p.addParameter('spikerange', [], @(x) isrow(x) && all(x >= 2) && all(fix(x) == x));
p.addParameter('showmarkers', true, @(x) isscalar(x) && x == 1 || x == 0);

p.parse(obj, varargin{:});

ax = p.Results.ax;

errorbarmode = p.Results.errorbarmode;
errorbarfunc = p.Results.errorbarfunc;
errorwidth = p.Results.errorwidth;
color = p.Results.color;
per = p.Results.per;
spikerange = p.Results.spikerange;
showmarkers = p.Results.showmarkers;

markerseries = {'o','^','s','p','v','x','d'}; % seven markers
markercolor = {'none', color};

end
