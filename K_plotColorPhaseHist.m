function [h,ind] = K_plotColorPhaseHist(varargin)
% K_plotColorPhaseHist plots heat map representation of phase coupling for
% group data radians. The results are sorted according to vector length.
%
% [h,ind] = K_plotColorPhaseHist(radians)
% [h,ind] = K_plotColorPhaseHist(radians,nbin)
% [h,ind] = K_plotColorPhaseHist(____,'Param',Value)
%
% INPUT ARGUMENTS
% radians        A vector of cell array
%                instantaneous phase values in radian. If radians is a cell
%                vector, each cell contains a numeric vector of phase
%                values from one sample.
%
% nbin           (Optinal) the number of histogram bins, 20 or 36 is recommended
%                Default 36
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'ColorMap'     jet (default) | colormap
%
% 'XGrid'        'on' (default) | 'off' (1 or 0)
%
% 'Title'        string for title
%
% 'CLim'         'auto' (default) | [low high]
%
% OUTPUT ARGUMENTS
% h           Structure of graphic handles
%
% ind         Sorting index for radiands. radians(ind) will return radians
%             sorted by vector length in ascending order
%
% See also
% ribboncoloredZ
% K_PhaseHist
% K_plotLinearPhaseHist 
% K_plotLinearPhaseHist_S  (to directly use output of K_PhaseHist as an input argument)
% K_PhaseHist_histlabel    (add summary text to the plots made by K_PhaseHist)
% K_plotCircPhaseHist_one, K_plotCircPhaseHist_group (for circular plots)
% K_plotColorPhaseHist     (heatmap representation of phase coupling)
% K_ECDFforRayleigh        (ECDF-based correction for Rayleigh's uniformity test)
% K_PhaseHist_test         (UnitTest)
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 10-Jan-2017 14:08:33


p = inputParser;
p.addRequired('radians',@(x) iscell(x) && isvector(x));
p.addOptional('nbin',36,@(x) isscalar(x) && x>0);
p.addParameter('XGrid','on',@(x) ismember(lower(x),{'on','off'}));
p.addParameter('ColorMap',jet);
p.addParameter('CLim','auto',@(x) isequal(x,'auto') || ...
    isnumeric(x) && numel(x) && isrow(x));
p.addParameter('TitleStr',jet);

p.parse(varargin{:});

radians  = p.Results.radians;
nbin     = p.Results.nbin;
ColorMap = p.Results.ColorMap;
XGrid    = p.Results.XGrid;
titlestr = p.Results.TitleStr;
CLim     = p.Results.CLim;


N = length(radians);
vlen = zeros(N,1);

out = preallocatestruct({'x','y','yerr',},[N,1]);
for i = 1:N
    
    [~,~,out(i)] = K_plotLinearPhaseHist(radians{i},nbin,...
        'plottype','none');
    
    vlen(i) = circ_r(radians{i});
    
end

% [~,ind] = sort(vlen,'descend'); % will put NaNs at the top
ind = local_getind(vlen);


x = [out(ind).x];
y = [out(ind).y];


h = K_plotLinearPhaseFrame;

h.main = rmfield(h.main,{'lh1','eh1'});

h.main.surf = ribboncoloredZ(h.main.axh,x,y,1);
set(h.main.surf,'EdgeColor','none');

% swap X and Y axes
for i = 1:length(h.main.surf)
    YData = h.main.surf(i).XData;
    XData = h.main.surf(i).YData;

    h.main.surf(i).XData = XData;
    h.main.surf(i).YData = YData;
end


axis tight
h.main.axh.XTick = 0:90:720;
h.main.axh.XTickLabel = 0:90:720;
h.main.axh.TickDir = 'out';
h.main.axh.YDir = 'reverse';
if isequal(CLim,'auto')
    h.main.axh.CLimMode = 'auto';    
else
    h.main.axh.CLim = CLim;
end

xlim([0 720]);
% view(90,90)
colormap(ColorMap);
h.colorbar = colorbar;


pause(0.1) %NOTE workaround for the chaning position bug

pos1 = h.main.axh.Position;
pos2 = h.sub.axh.Position;

h.sub.axh.Position = [pos1(1), pos2(2), pos1(3), pos2(4)];

% h.sub.axh.Position(1) = h.main.axh.Position(1); % unstable
% h.sub.axh.Position(3) = h.main.axh.Position(3);


if strcmp(XGrid,'on')
    
    h.main.gridline = line(repmat(0:90:720,2,1),repmat(ylim',1,9),repmat([120;120],1,9),...
        'Color','w','LineStyle','--','Tag','X Grid Line');
    
end

xlabel(sprintf('Phase (%s)',char(176)));

ylabel(h.colorbar,sprintf('Firing probability per %.1f (%%)',360/nbin))
ylabel(h.main.axh,'Channels')
h.main.axh.YTick      = 1:length(h.main.surf);
h.main.axh.YTickLabel = 1:length(h.main.surf);

h.main.axh.XGrid = 'off';
h.main.axh.YGrid = 'off';


h.colorbar.TickDirection= 'out';


if ~isempty(titlestr)
    title(titlestr)
end


end


%--------------------------------------------------------------------------

function ind = local_getind(vlen)
% ind is a sorting indices by vector length vlen
% ind places NaNs at the end
%
% ind = local_getind(vlen)
%
% cf.
% [~,ind] = sort(vlen,'descend'); % will put NaNs at the top
%
% See also
% sort

% handle NaN separately (sort(x,'descend') will put NaNs at the top)
tfnan = isnan(vlen);
indnan = find(tfnan);

indNOTnan = find(~tfnan);

[~,ind2sortNOTnan] = sort(vlen(indNOTnan),'descend'); % sort by vector length
ind = [indNOTnan(ind2sortNOTnan);...
    indnan];

end