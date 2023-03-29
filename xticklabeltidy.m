function xticklabeltidy( ax, xtick, precision )
% xticklabeltidy sets XTick and XTickLabel with a vector xtick
%
% xticklabeltidy(axh,xtick,precision) 
%
% INPUT ARGUMENTS
%   axh        axes handle
%
%   xtick      a horizontal vector, monotonically increasing
%
%   precision  A non-negative integer which specifies the number of decimal places
%              If decimalp = 3, then it is to be used as %.3f in num2str
%
% EXAMPLE
%
%   xticklabeltidy(gca, 0:0.5:2, 2)
%
%   axh.XTickLabel = {'0','0.50','1.00','1.50',2.00'}
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 02-Dec-2016 17:10:00
%
% See Also 
% yticklabeltidy, xticklabel, xtickformat, K_XTickLabel

arguments
    
   ax (1,1) {vf_ax(ax)}
   xtick (1,:) {vf_xtick(xtick)}
   precision  (1,1) {mustBeInteger, mustBeNonnegative}
end

% vf2 = @(x) isnumeric(x) &&...
%     issorted(x) &&...
%     (isrow(x) || isempty(x));
% addRequired(p, 'xtick', vf2);


%% job

xtickc = cell(1, length(xtick));
for i = 1:length(xtick)
    if xtick(i) == 0
        xtickc{i} = '0';
    else
        xtickc{i} = num2str(xtick(i), ['%.', num2str(round(precision)),'f']);
    end
end
set(ax, 'XTick', xtick, 'XTickLabel', xtickc, 'TickDir', 'out', 'Box', 'off');


end

function vf_ax(x)

assert(isa(x, 'matlab.graphics.axis.Axes') ||isa(x, 'matlab.graphics.illustration.ColorBar'))

end

function vf_xtick(x)

mustBeNumeric(x)

assert(issorted(x))

mustBeVector(x)

end

