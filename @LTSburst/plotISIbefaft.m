function h = plotISIbefaft(obj, varargin)
% h = plotISIbefaft(obj, 'param', value)
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'Color'           colorspec
%
% 'MarkerSize'      positive real number
%
% 'Marker'          valid marker symbol (char row)
%
% OUTPUT ARGUMENTS
% h         structure with the following fields:
%           fig    figure handle
%           axh    axes handle
%           line   line handles

p = inputParser;
p.addRequired('obj');
p.addParameter('color', 'b', @(x) iscolorspec(x) );
p.addParameter('MarkerSize', 3, @(x) isreal(x) && isscalar(x) && x > 0 );
p.addParameter('Marker', '.');
p.addParameter('PlotType', 'loglog', @(x) ismember(lower(x), {'loglog', 'scatterhist'}));


p.parse(obj, varargin{:});
color = p.Results.color;
MarkerSize = p.Results.MarkerSize;
Marker = p.Results.Marker;
PlotType = lower(p.Results.PlotType);


spikeInfo = obj.SpikeInfo;
n = length(spikeInfo);

h.fig = figure;
h.axh = gobjects(1);
h.line = zeros(n,1);

switch PlotType
    case 'loglog'
        for s = 1:n
            if ~isempty(spikeInfo{s})
                h.line(s) = loglog([spikeInfo{s}.ISIbef].*1000, [spikeInfo{s}.ISIaft].*1000, ...
                    'LineStyle', 'none', 'Marker', Marker, 'MarkerSize', MarkerSize, ...
                    'Color', color, 'Tag',sprintf('Markers %d',s));
                hold on
            end
        end
    case 'scatterhist'
    
        %TODO  does this work for group data?
        TFempty = cellfun(@isempty, spikeInfo);
        
        x = vertcat(spikeInfo{~TFempty}.ISIbef);

        y = vertcat(spikeInfo{~TFempty}.ISIaft);

        h.scatterhist = scatterhist(x, y, ...
            'Marker', Marker, 'MarkerSize', MarkerSize, 'Color', color,...
            'Direction', 'out', 'Location', 'Northeast' );
        
        set(h.scatterhist(1), 'XScale', 'log', 'YScale', 'log',...
            'Box', 'off', 'TickDir', 'out');
        axis equal
        axis square
        
        %TODO the builitin scatterhist does not suppot log scale histogram
        % or axis square
        %
        % need to use histc function etc
        
                        
end
xlabel('ISI before spike (ms)');
ylabel('ISI after spike (ms)');
set(gca, 'Box', 'off', 'TickDir', 'out');
h.axh = gca;

end