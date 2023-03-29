function pvt_plotCircular_putlabel(direction, zero_pos, axh)
% pvt_plotCircular_putlabel(direction, zero_pos, axh)
%
% See Also
% K_plotCircularSingle, K_plotCircularGroup

axes(axh);

switch lower(direction)
    case 'anti-clockwise'
        switch lower(zero_pos)
            case 'right'
                text(1.2, 0, '0°');
                text(-.05, 1.2, '90°');
                text(-1.3, 0, '180°');
                text(-.05, -1.2, '270°');
            case 'top'
                text(1.2, 0, '270°');
                text(-.05, 1.2, '0°');
                text(-1.3, 0, '90°');
                text(-.05, -1.2, '180°');
            case 'left'
                text(1.2, 0, '180°');
                text(-.05, 1.2, '270°');
                text(-1.3, 0, '0°');
                text(-.05, -1.2, '90°');
            case 'bottom'
                text(1.2, 0, '90°');
                text(-.05, 1.2, '180°');
                text(-1.3, 0, '270°');
                text(-.05, -1.2, '0°');
        end
    case 'clockwise'
        switch zero_pos
            case 'right'
                text(1.2, 0, '0°');
                text(-.05, -1.2, '90°');
                text(-1.3, 0, '180°');
                text(-.05, 1.2, '270°');
            case 'top'
                text(1.2, 0, '90°');
                text(-.05, -1.2, '180°');
                text(-1.3, 0, '270°');
                text(-.05, 1.2, '0°');
            case 'left'
                text(1.2, 0, '180°');
                text(-.05, -1.2, '270°');
                text(-1.3, 0, '0°');
                text(-.05, 1.2, '90°');
            case 'bottom'
                text(1.2, 0, '270°');
                text(-.05, -1.2, '0°');
                text(-1.3, 0, '90°');
                text(-.05, 1.2, '180°');
        end
end