function h = K_plotCircPhaseHist_group_S(varargin)
% K_plotCircPhaseHist_group_S is a wrappwer of K_plotCircPhaseHist_group
%
% h = K_plotCircPhaseHist_group_S(varargin)
%
% INPUT ARGUMENTS
% 
% S           structure
%             Output argynebt 'results' of K_PhaseHist. You can also use
%             non-scalar array of such structures as input.
%
% axh         Axes handle (optional)
% 
% OPTIONS (paramter/value pairs)
% 'Color'     ColorSpec 
%
% 'ZeroPos'   String. 
%             'top' (default) | 'right' | 'left' |'bottom'
%
% 'Direction' String. 
%             clockwise' (default) | 'anti'
%
% 'GroupMean' 'on' | 'off' (default)
%
%
% OUTPUT ARGUMENTS
%
% h           A structure of handles for graphic objects.
%
% See also
% K_plotCircPhaseHist_group
% K_plotCircPhaseHist_one, K_PhaseHist, K_PhaseHist_test
% pvt_K_plotCircPhaseHist_parseInputs
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 23-Nov-2016 15:27:13





% initialize
axh = [];
ColorSpec  = 'b';
zeropos = 'top';
plotdir = 'clockwise';
groupmean = 'off';

% vfrad = @(x) isnumeric(x) &&...
%     isvector(x);

if nargin == 1
    % h = K_plotCircPhaseHist_one(radians)

    p = inputParser;
    
    addRequired(p, 'S', @isstruct);
    parse(p, varargin{:});
    
    S = varargin{1};
    
elseif nargin >= 2
    % h = K_plotCircPhaseHist_one(radians)
    % h = K_plotCircPhaseHist_one(axh, ______)
    % h = K_plotCircPhaseHist_one(_____, 'Param', Value, ...)
    
    if ishandle(varargin{1})
        % h = K_plotCircPhaseHist_one(axh,radians,Param,Value)

        axh = varargin{1};
        S = varargin{2};

        PNVStart = 3;
        
    else
        % h = K_plotCircPhaseHist_one(radians,Param,Value)

        S = varargin{1};
        
        PNVStart = 2;
        
    end
    
    PNV = varargin(PNVStart:end);
    
    p = inputParser;
    
    p.addRequired('S', @isstruct);
    
    p.addParameter('Color',ColorSpec,@iscolorspec);
        
    p.addParameter('ZeroPos',zeropos,@(x) ~isempty(x) && ischar(x) ...
        && isrow(x) && ismember(x,{'top','left','right','bottom'}));
    
    p.addParameter('Direction',plotdir,@(x) ~isempty(x) && ischar(x) && isrow(x) ...
        && ismember(x,{'clockwise','anti'}));
    
    p.addParameter('GroupMean',groupmean,@(x) ~isempty(x) && ischar(x) && isrow(x) ...
        && ismember(x,{'on','off'}));
    
    p.parse(S, PNV{:});
    
    ColorSpec = p.Results.Color;
    zeropos = lower(p.Results.ZeroPos);
    plotdir = lower(p.Results.Direction);
    groupmean = lower(p.Results.GroupMean);

end


%% Job
Sur = [S(:).unitrad];

radians = [{Sur(:).unitrad}];

rayleigh = [Sur(:).raylecdf];


if isempty(axh)
h = K_plotCircPhaseHist_group(radians,...
    'Color',ColorSpec,'ZeroPos',zeropos,'Direction',plotdir,'GroupMean',...
    groupmean,'RayleighECDF',rayleigh);

else
h = K_plotCircPhaseHist_group(axh,radians,...
    'Color',ColorSpec,'ZeroPos',zeropos,'Direction',plotdir,'GroupMean',...
    groupmean,'RayleighECDF',rayleigh);
    
    
end

end