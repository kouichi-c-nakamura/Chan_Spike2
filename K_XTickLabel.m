function K_XTickLabel( axh, xtick, decimalp )
% K_XTickLabel sets YTick and YTickLabel with a vector ytick
%
% K_XTickLabel(axh,ytick,decimalp) 
%
% INPUT ARGUMENTS
%   axh        axes handle
%   ytick      a horizontal vector, monotonically increasing
%   decimalp   A positive integer which specifies the number of decimal places
%    ??????????If decimalp = 3, then it is to be used as %.3f in num2str
%
% EXAMPLE
%
%   K_XTickLabel(gca, 0:0.5:2, 2)
%
%   axh.XTickLabel = {'0','0.50','1.00','1.50',2.00'}
%
% K_XTickLabel is not recommended. Use xticklabeltidy instead
%
% See Also 
% K_YTickLabel, xticklabeltidy

warning('K_XTickLabel is not recommended. Use xticklabeltidy instead')


%% parse inputs

narginchk(3, 3);

p = inputParser;

vf1 = @(x) ~isempty(x) &&...
    isscalar(x) && ...
    ishandle(x);
addRequired(p, 'axh', vf1);

vf2 = @(x) isnumeric(x) &&...
    issorted(x) &&...
    (isrow(x) || isempty(x));
addRequired(p, 'XTick', vf2);

vf3 = @(x) ~isempty(x) &&...
    isnumeric(x) &&...
    isscalar(x) &&...
    fix(x) == x &&...
    x >= 0;
addRequired(p, 'decimalp', vf3);

parse(p, axh, xtick, decimalp);

%% job

xtickc = cell(1, length(xtick));
for i = 1:length(xtick)
    if xtick(i) == 0
        xtickc{i} = '0';
    else
        xtickc{i} = num2str(xtick(i), ['%.', num2str(round(decimalp)),'f']);
    end
end
set(axh, 'XTick', xtick, 'XTickLabel', xtickc, 'TickDir', 'out', 'Box', 'off');


end

