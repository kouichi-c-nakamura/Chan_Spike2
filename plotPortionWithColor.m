function axh = plotPortionWithColor(W,varargin)
%
% axh = plotPortionWithColor(W)
% axh = plotPortionWithColor(W,indSel)
% axh = plotPortionWithColor(W,indSel,colorSel)
% axh = plotPortionWithColor(_____,'colorBase',colorspec)
%
%
% This can be a method of WaveformChan
%
% INPUT ARGUMENTS
% W           WaveformChan object
%
% indSel      (Optional) column vector of numeric indicies for W.Data
%
% colorSel    [1 0 0] (default) | RGB triplet | character vector of color name | 'none'
%             (Optional) color for the data points specified by indSel. 
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'colorBase' [0 0 0] (default) | RGB triplet | character vector of color name | 'none'
%             Color of the data points other than those specified by indSel
%             Note that if you choose 'none' the "base" line (line with all
%             data points) will not show up but it is only invisible.
%
%  'base'     'on' (default) | 'off'
%             'off' will not keep the "base" (line with all data points)
%             line
%
% OUTPUT ARGUMENTS
% axh         Axes handle
%
%
% See also
% WaveformChan.getBUA
% WaveformChan.plot,Record.plot

p = inputParser;
p.addRequired('W',@(x) isscalar(x) && isa(W,'WaveformChan'));
p.addOptional('indSel','r',@(x) iscolumn(x) && all(x > 0) && all(x < W.Length));
p.addOptional('colorSel','r',@(x) iscolorspec(x));
p.addParameter('colorBase','k',@(x) iscolorspec(x));
p.addParameter('base','on',@(x) ismember(lower(x),{'on','off'}));
p.parse(W,varargin{:});
          
indSel    = p.Results.indSel;
colorSel  = p.Results.colorSel;
colorBase = p.Results.colorBase;
base      = p.Results.base;

tfSel = false(W.Length,1);
tfSel(indSel) = true;

Wrep = W;
Wrep.Data(~tfSel) = NaN;
 
rec = Record({W});
h = rec.plot;
linh = findobj(h.axh,'Type','line');
linh.Color = colorBase;
linh.Tag = 'base';
axh = gca;

Wrep.plot('Color',colorSel,'Tag','selection');
axh2 = gca;
linselh = findobj(axh2,'Type','line');


copyobj(linselh,h.axh);
close(axh2.Parent)

if strcmpi(base,'off')
   delete(linh);
end

title(W.ChanTitle,'Interpreter','none')


end