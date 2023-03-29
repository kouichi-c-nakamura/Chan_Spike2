function axh = pvt_plotCircular_drawcircle(axh)
% axh = pvt_plotCircular_drawcircle(axh)
%
%
% See also
% K_plotCircularSingle, K_plotCircularGroup

% complex number for Polar plot
zz = exp(1i*linspace(0, 2*pi, 360));

if isempty(axh)
    figure('Color', [1 1 1]); hold on;
    axis square;
    axh = gca;
else
    axes(axh);
    set(gcf, 'Color', [1 1 1]);
end
set(gca, 'TickDir', 'out');
set(gca, 'XTick', [-1 0 1], 'YTick', [-1 0 1]);
set(gca, ...
'Visible','off',...        
'Box', 'off',...
'PlotBoxAspectRatioMode', 'manual',...
'Units', 'centimeters',...
'Position', [2,2,8,8]);


% draw concentric circles
plot(real(zz), imag(zz), 'Color', 'k', 'LineWidth', 1.5);
plot(1/2*real(zz), 1/2*imag(zz), 'Color', [0.5 0.5 0.5]);

% draw vertical and holizontal lines
line([0 0],[-1 1],'Color', [0.5 0.5 0.5]);
line([-1 1],[0 0],'Color', [0.5 0.5 0.5]);



end