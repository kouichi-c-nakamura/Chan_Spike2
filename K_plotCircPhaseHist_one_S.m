function h = K_plotCircPhaseHist_one_S(varargin)
%
%
%   h = K_plotCircPhaseHist_one_S(S)
%   h = K_plotCircPhaseHist_one_S(S,nbin)
%   h = K_plotCircPhaseHist_one_S(axh, ______)
%   h = K_plotCircPhaseHist_one_S(_____, 'Param', Value, ...)
%
% INPUT ARGUMENTS
%
% S           structure
%             Output argynebt 'results' of K_PhaseHist.
%
% nbin             The number of histogram bins
%
% axh              Axes handle (optional)
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'Color'          ColorSpec
%
% 'ZeroPos'        String.
%                  'top' (default) | 'right' | 'left' |'bottom'
%
% 'Direction'      String.
%                  'clockwise' (default) | 'anti'
%
% 'MeanVector'     'on' (default) | 'off'
%
% 'SmallCircle'    'on' (default) | 'off'
%
% 'SmallCircleSize' Positive number. Default is 10.
%
% 'Histogram'       'on' (default) | 'off'
%
% 'HistLimPercent'  Option for nomalized histogram rather than counts. You
%                   can specifiy the outerlimit of the circular histogram in
%                   percent. If HistLimPercent is 0, the outerlimit is
%                   automatically set.If Histbin is not provided,
%                   HistLimPercent will be ignored.
%
% 'rayleighECDF'    Test results (P value) of Rayleigh's test (cirt_rtest) in
%                   vector. The length must be the same as that of the sample
%                   number of radians (1 if radians is numeric vector,
%                   numel(radians) if cell vector).
%
% OUTPUT ARGUMENTS
%
% h                 A structure of handles for graphic objects.
%
%
% See Also
% K_plotCircPhaseHist_group, K_PhaseHist, K_PhaseHist_test,
% K_plotLinearPhaseHist,
% pvt_K_plotCircPhaseHist_parseInputs





% initialize
axh = [];
ColorSpec  = 'b';
nbin = 36;
zeropos = 'top';
plotdir = 'clockwise';
histlimpercent = [];
meanvector = 'on';
smallcircle = 'on';
histogram = 'on';
smallcirclesize = 10;

% vfrad = @(x) isnumeric(x) &&...
%     isvector(x);

if nargin == 1
    % h = K_plotCircPhaseHist_one(radians)
    
    p = inputParser;
    
    addRequired(p, 'S', isstruct(x) && isscalar(x));
    parse(p, varargin{:});
    
    S = varargin{1};
    
elseif nargin >= 2
    % h = K_plotCircPhaseHist_one(radians, nbin) %TODO
    % h = K_plotCircPhaseHist_one(axh, ______)
    % h = K_plotCircPhaseHist_one(_____, 'Param', Value, ...)
    
    if ishandle(varargin{1})
        % h = K_plotCircPhaseHist_one(axh, ______)
        
        axh = varargin{1};
        S = varargin{2};
        
        if length(varargin) >=3 && ~ischar(varargin{3})
            % h = K_plotCircPhaseHist_one(axh,radians,nbin)
            
            nbin = varargin{3};
            PNVStart = 4;
        else
            % h = K_plotCircPhaseHist_one(axh,radians)
            
            PNVStart = 3;
        end
        
    else
        S = varargin{1};
        
        if ~ischar(varargin{2})
            nbin = varargin{2};
            PNVStart = 3;
        else
            PNVStart = 2;
        end
        
    end
    
    PNV = varargin(PNVStart:end);
    
    p = inputParser;
    
    p.addRequired('S', @(x) isstruct(x) && isscalar(x));
    
    vf2 = @(x) isempty(x) ||...
        isnumeric(x) && isscalar(x) &&...
        fix(x) == x && x >=0;
    p.addRequired('nbin', vf2);
    
    p.addParameter('Color',ColorSpec,@iscolorspec);
    
    p.addParameter('MeanVector',meanvector,@(x) ~isempty(x) && ischar(x) && isrow(x) ...
        && ismember(lower(x),{'on','off'}));
    
    p.addParameter('ZeroPos',zeropos,@(x) ~isempty(x) && ischar(x) ...
        && isrow(x) && ismember(lower(x),{'top','left','right','bottom'}));
    
    p.addParameter('SmallCircle',smallcircle,@(x) ~isempty(x) && ischar(x) && isrow(x) ...
        && ismember(lower(x),{'on','off'}));
    
    p.addParameter('SmallCircleSize',smallcirclesize,@(x) isscalar(x) && isreal(x) && x > 0)
    
    p.addParameter('Direction',plotdir,@(x) ~isempty(x) && ischar(x) && isrow(x) ...
        && ismember(lower(x),{'clockwise','anti'}));
    
    p.addParameter('Histogram',histogram,@(x) ~isempty(x) && ischar(x) && isrow(x) ...
        && ismember(lower(x),{'on','off'}));
    
    p.addParameter('HistLimPercent',histlimpercent,@(x) isempty(x) ...
        || isnumeric(x) && isscalar(x) && x >= 0);
        
    p.parse(S, nbin, PNV{:});
    
    if isempty(nbin) || nbin == 0
        nbin = 36; % default value
    end
    
    ColorSpec = p.Results.Color;
    meanvector = lower(p.Results.MeanVector);
    histogram = lower(p.Results.Histogram);
    smallcircle = lower(p.Results.SmallCircle);
    histlimpercent = p.Results.HistLimPercent;
    zeropos = lower(p.Results.ZeroPos);
    smallcirclesize = p.Results.SmallCircleSize;
    plotdir = lower(p.Results.Direction);
    
end


%% Job

radians = S.unitrad.unitrad;

rayleigh = S.unitrad.raylecdf;

if isempty(axh)
    h = K_plotCircPhaseHist_one(radians,nbin,...
        'Color',ColorSpec,'MeanVector',meanvector,'SmallCircle',smallcircle,...
        'SmallCircleSize',smallcirclesize,...
        'Histogram',histogram,'HistLimPercent',histlimpercent,...
        'ZeroPos',zeropos,'Direction',plotdir,...
        'RayleighECDF',rayleigh);
else
    h = K_plotCircPhaseHist_one(axh,radians,nbin,...
        'Color',ColorSpec,'MeanVector',meanvector,'SmallCircle',smallcircle,...
        'SmallCircleSize',smallcirclesize,...
        'Histogram',histogram,'HistLimPercent',histlimpercent,...
        'ZeroPos',zeropos,'Direction',plotdir,...
        'RayleighECDF',rayleigh);
end


end
