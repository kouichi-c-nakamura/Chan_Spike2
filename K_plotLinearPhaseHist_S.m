function [h, N, outdata] = K_plotLinearPhaseHist_S(varargin)
% A wrapper of K_plotLinearPhaseHist
%  
% [h, N, outdata] = K_plotLinearPhaseHist_S(S)
% INPUT ARGUMENTS
% S           structure
%             Output argynebt 'results' of K_PhaseHist. You can also use
%             non-scalar array of such structures as input.
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'C'         'on' (default) | 'off'
%             (Optional) Description about 'C' comes here.
%
% nbin        the number of histogram bins, 20 or 36 is recommended
% 
% axh         axes handle. With this syntax, K_plotLinearPhaseHist will
%             delete axh and draw the main and sub axes in place of axh,
%             so that The outmost rectangle of the main and sub axes tallies
%             with Position of axh.
%
% OUTPUT ARGUMENTS
% 'Color'     ColorSpec
%  
% 'XGrid'     'on' (default) | 'off' (1 or 0)
%  
% 'PlotType'  'line' | 'bar' (default) | 'none'
%  
% 'Errorbar'  'none' (default) | 'std' | 'sem'
%             Effective only when radians is a cell array vector but not
%             a scalar (i.e. group data input)
%  
% 'Title'     string for title
%
% See also
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
% 23-Nov-2016 14:36:10



% initialization

axh = [];
nbin =36;


% cell contents must be all columns or all rows

if nargin == 1 %TODO
    % [h, N] = K_plotLinearPhaseHist(radians)
    
    S = varargin{1};
    PNV = {};
    
elseif nargin >= 2
    
    if ishandle(varargin{1})
        % [h,N] = K_plotLinearPhaseHist(axh, _____)
        
        axh = varargin{1};
        S = varargin{2};
        
        if length(varargin) >=3 && ~ischar(varargin{3})
            % [h,N] = K_plotLinearPhaseHist(axh,radians,nbin)
            
            nbin = varargin{3};
            PNVStart = 4;
        else
            % [h,N] = K_plotLinearPhaseHist(axh,radians)
            
            PNVStart = 3;
        end
        
    else
        % [h,N] = K_plotLinearPhaseHist(radians,nbin)
        
        S = varargin{1};
        
        if ~ischar(varargin{2})
            nbin = varargin{2};
            PNVStart = 3;
        else
            PNVStart = 2;
        end
        
    end
    
    PNV = varargin(PNVStart:end);
end

p = inputParser;

p.addRequired('S', @isstruct);

vfnbin = @(x) isempty(x) ||...
    isnumeric(x) && isscalar(x) &&...
    fix(x) == x && x >=0;
p.addRequired('nbin', vfnbin);

p.addParameter('Color','b',@iscolorspec);

p.addParameter('XGrid','on',@(x) ~isempty(x) &&...
    ischar(x) &&...
    isrow(x) &&...
    ismember(x, {'on','off'}));

p.addParameter('PlotType','line',@(x) ~isempty(x) &&...
    ischar(x) &&...
    isrow(x) &&...
    ismember(x, {'line','bar','none'}));

p.addParameter('ErrorBar','none',@(x) ~isempty(x) &&...
    ischar(x) &&...
    isrow(x) &&...
    ismember(x, {'none','std', 'sem'}));

p.addParameter('Title','',@(x) ~isempty(x) &&...
    ischar(x) &&...
    isrow(x));

vfradallpoints = @(x) ~isempty(x) && isvector(x) && isreal(x) && ...
    fix(length(x)/nbin) == length(x)/nbin;

p.addParameter('RadiansAllPoints',[],...
    @(x) (~iscell(x) ...
    && vfradallpoints(x)) || iscell(x) && ...
    all(cellfun(vfradallpoints, x)));

p.addParameter('rayleighECDF',[],@(x) isvector(x) && isreal(x));

p.parse(S, nbin, PNV{:});

if isempty(nbin) || nbin == 0
    nbin = 36; % default value
end

ColorSpec = p.Results.Color;

xgrid = lower(p.Results.XGrid);
plottype = lower(p.Results.PlotType);
errorBar = lower(p.Results.ErrorBar);
titlestr = p.Results.Title;


%% Job


Sur = [S(:).unitrad];

radians = [{Sur(:).unitrad}];

rayleigh = [Sur(:).raylecdf];


if isempty(axh)
    [h, N, outdata] = K_plotLinearPhaseHist(radians,nbin,...
    'Color',ColorSpec,'XGrid',xgrid,'PlotType',plottype,'Errorbar',errorBar,...
    'Title',titlestr,'rayleighECDF',rayleigh);
else
    
    [h, N, outdata] = K_plotLinearPhaseHist(axh,radians,nbin,...
        'Color',ColorSpec,'XGrid',xgrid,'PlotType',plottype,'Errorbar',errorBar,...
        'Title',titlestr,'rayleighECDF',rayleigh);
end
end

