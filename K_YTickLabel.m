function K_YTickLabel( axh, ytick, decimalp )
% K_YTickLabel sets YTick and YTickLabel with a vector ytick
%
% K_YTickLabel(axh,ytick,decimalp) 
%
% INPUT ARGUMENTS
%   axh        axes handle
%   ytick      a horizontal vector, monotonically increasing
%   decimalp   A positive integer which specifies the number of decimal places
%              If decimalp = 3, then it is to be used as %.3f in num2str
%
% EXAMPLE
%
%   K_YTickLabel(gca, 0:0.5:2, 2)
%
%   axh.YTickLabel = {'0','0.50','1.00','1.50',2.00'}
%
% K_YTickLabel is not recommended. Use yticklabeltidy instead
%
% See Also 
% K_XTickLabel, yticklabeltidy

warning('K_YTickLabel is not recommended. Use yticklabeltidy instead')

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
addRequired(p, 'ytick', vf2);

vf3 = @(x) ~isempty(x) &&...
    isnumeric(x) &&...
    isscalar(x) &&...
    fix(x) == x ;
addRequired(p, 'decimalp', vf3);

parse(p, axh, ytick, decimalp);

%% job

ytickc = cell(1, length(ytick));
for i = 1:length(ytick)
    if ytick(i) == 0
        ytickc{i} = '0';
    else
        ytickc{i} = num2str(ytick(i), ['%.', num2str(round(decimalp)),'f']);
    end
end
set(axh, 'YTick', ytick, 'YTickLabel', ytickc, 'TickDir', 'out', 'Box', 'off');


end

