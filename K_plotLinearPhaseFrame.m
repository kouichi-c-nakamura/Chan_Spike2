function h = K_plotLinearPhaseFrame(varargin)
% K_plotLinearPhaseFrame prepares empty axes for K_plotLinearPhaseWave and
% K_plotLinearPhaseHist
%
% h = K_plotLinearPhaseFrame
% h = K_plotLinearPhaseFrame('param',value,...)
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'TitleStr'  
%             (Optional) Description about 'C' comes here.
%
% 'YLabelType'  
%             (Optional) Description about 'C' comes here.
%
% 'YLabelStr'  
%             (Optional) Description about 'C' comes here.
%
% 'nbin'  
%             (Optional) Description about 'C' comes here.
%
% 'axh'       [] | an Axes object | two Axes objects
%             Axes handle. This can be empty, scalar or two-element array.
%             For scalar axh, this function will delete axh and draw the
%             main and sub axes in place of axh, so that The outmost
%             rectangle of the main and sub axes tallies with Position of
%             axh. If axh has two elements, then axh(1) will be the main
%             axes and axh(2) will be the sub axes.
%
%
% OUTPUT ARGUMENTS
% h           Structure containing graphic handles
%                 h.fig 
%                 h.main
%                 h.sub 
%                 h.titlepane
%
%
% See also
% K_plotLinearPhaseWave, K_plotLinearPhaseHist, plotLinearPhase
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 26-Jan-2017 07:29:06


p = inputParser;
p.addParameter('TitleStr','',@(x) ischar(x) && isrow(x));
p.addParameter('YLabelType','phasehist',@(x) ismember(lower(x),{'phasehist','phasewave'}));
p.addParameter('YLabelStr','',@(x) ishcar(x) && isrow(x));
p.addParameter('nbin',36,@(x) isscalar(x));
p.addParameter('axh',[],@(x) numel(x) <= 2 && all(isgraphics(x,'axes')));

p.parse(varargin{:});

titlestr = p.Results.TitleStr;
ylabeltype = lower(p.Results.YLabelType);
ylabelstr = p.Results.YLabelStr;
nbin = p.Results.nbin;
axh = p.Results.axh;

if isempty(ylabelstr)
    switch ylabeltype
        case 'phasehist'
            ylabelstr = sprintf(['Firing Probability per %.1f', char(176),...
                ' (%%)'], 360/nbin);
        case 'phasewave'
            ylabelstr = 'Average Potential (mV)';
    end
    
end

x =1;
y =1;
yerr=[];
analysismode = 'one';
ColorSpec = 'b';
xgrid = 'on';
plottype = 'line';
errorBar ='none';

if isempty(axh)
    figure;
    axh = axes;
end

[h] = plotLinearPhase(axh,x,y,yerr,analysismode,ColorSpec,xgrid,plottype,...
    titlestr,ylabelstr,errorBar);

delete(h.main.lh1);


end