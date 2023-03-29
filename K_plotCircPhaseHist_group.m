function h = K_plotCircPhaseHist_group(varargin)
% K_plotCircPhaseHist_group create the following out of phase values in radians.
%
%    1. Multiple vectors representing circular mean and vector length of one 
%    sample.
%    2. Small circles at the perimeter that indicate circular mean of one
%    sample.
%    3. Also create a group vector with 'Tag' property set to 'Vector per
%    Group'. However, this is by default hidden by 'Visible','off'.
%    You can make it visible by:
%    set(findobj(gca,'Tag','Vector per Group'),'Visible','on')
%
% h = K_plotCircPhaseHist_group(radians)
% h = K_plotCircPhaseHist_group(axh, ______)
% h = K_plotCircPhaseHist_group(_____, 'Param', Value, ...)
% 
% INPUT ARGUMENTS
% 
% radians          A cell vector containing a vector of phase values in             
%                  radian. Each cell represent one sample.
%
% axh              Axes handle (optional)
% 
% OPTIONS (paramter/value pairs)
% 'Color'          ColorSpec 
%
% 'ZeroPos'        String. 
%                 'top' (default) | 'right' | 'left' |'bottom'
%
% 'Direction'      String. 
%                 'clockwise' (default) | 'anti'
%
% 'GroupMean'      'on' | 'off' (default)
%
% 'rayleighECDF'   A vector of real numbers with the length same as the
%                  sample number of radians (i.e. the length of radians if
%                  radians is a cell vector or one if it is a numeric vector)
%
% 'RadiusForHistScale'
%                  [0.60, 1.10] (default) | [inner, outer]
%                  Determines the positions of texts indicating scales
%
% 'RadiusForAngles'
%                  [1.2, 1.2] (default) | [r0, r90]
%                  Determines the positions of texts indicating angles.
%                  r0 is for 0 and 180 degrees, whereas r90 is for 90 and 270.
%
% 'RadiusForScales'
%                  [0.65,1.2] (default) | [inner, outer] 
%                  Determines the positions of texts indicating scales
%
% 'RadianForScales'
%                  pi*3/8 (default) | scalar
%                  Phase of the positions of texts indicating scales in radian
%
%
% OUTPUT ARGUMENTS
%
% h                A structure of handles for graphic objects.
%
%
% See Also 
% K_PhaseHist
% K_plotLinearPhaseHist 
% K_plotLinearPhaseHist_S  (to directly use output of K_PhaseHist as an input argument)
% K_PhaseHist_histlabel    (add summary text to the plots made by K_PhaseHist)
% K_plotCircPhaseHist_one, K_plotCircPhaseHist_group (for circular plots)
% K_plotColorPhaseHist     (heatmap representation of phase coupling)
% K_ECDFforRayleigh        (ECDF-based correction for Rayleigh's uniformity test)
% K_PhaseHist_test         (UnitTest)
% pvt_K_plotCircPhaseHist_parseInputs, 
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 05-May-2017 09:31:51


%% parse input arguments


[axh, radians, zeropos, plotdir, ColorSpec, groupmean, rayleighECDF,...
    radiusForHistScale, radiusForAngles, radiusForScales, radianForScales] = ...
    local_parser(varargin{:});

%% Job
if isempty(axh) 
    h.fig = figure('Color',[1 1 1]); hold on;

    h.axh = gca;
    
    h.axh.Position = [0.1300    0.16    0.7    0.7];

else
    axes(axh);

    h.fig = gcf;
    set(gcf, 'Color', [1 1 1]);
    h.axh = axh;
end  

axis tight
axis equal;


if isrow(radians)
    radians = radians';
end

N = numel(radians);

cmean = cellfun(@(x) circ_mean(x),radians);
veclen = cellfun(@(x) circ_r(x),radians);

h = K_plotCircPhaseHist_one(h.axh,cmean,...
    'Color',ColorSpec,'ZeroPos',zeropos,'Direction',plotdir,...
    'RadiusForHistScale',radiusForHistScale, ...
    'RadiusForAngles',radiusForAngles, 'RadiusForScales',radiusForScales,...
    'RadianForScales',radianForScales);

delete(findobj(h.axh,'Tag','Rose Histogram',...
    '-or','Tag','Histogram Scale Full',...
    '-or','Tag','Histogram Scale Half',...
    '-or','Tag','Annotation Text'))

set(findobj(h.axh,'Tag','Vector'),'Tag','Vector per Group');

if strcmp(groupmean,'off')
    set(findobj(h.axh,'Tag','Vector per Group'),'Visible','off');
    set(findobj(h.axh,'Tag','Mark on Perimeter per Group'),'Visible','off');
    
end

axes(h.axh);
hold on

rad2cmp = @(x) exp(1i * x);

for i = 1:length(radians)

    z1 = rad2cmp(cmean(i));
    
    h.vector = plot(h.axh, [0, real(z1)*veclen(i)], [0, imag(z1).*veclen(i)],...
        'Color', ColorSpec , 'LineWidth', 1,'Tag','Vector per Sample');

end

txth = local_placetext(N,radians,rayleighECDF,h.axh);

end

%--------------------------------------------------------------------------

function [axh, radians, zeropos, plotdir, ColorSpec, groupmean, rayleighECDF,...
    radiusForHistScale, radiusForAngles, radiusForScales, radianForScales] ...
    = local_parser(varargin)

vfrad = @(x) iscell(x) && isvector(x) && ...
    all(cellfun(@(y) isvector(y) && isreal(y), x));

% initialize
axh = [];
ColorSpec  = 'b';
zeropos = 'top';
plotdir = 'clockwise';
groupmean = 'off';
rayleighECDF = [];
radiusForHistScale = [0.60, 1.10];
radiusForAngles = [1.2,1.2];
radiusForScales = [0.65,1.2];
radianForScales = pi*3/8;

% vfrad = @(x) isnumeric(x) &&...
%     isvector(x);

if nargin == 1
    % h = K_plotCircPhaseHist_one(radians)

    p = inputParser;
    
    addRequired(p, 'radians', vfrad);
    parse(p, varargin{:});
    
    radians = varargin{1};
    
elseif nargin >= 2
    % h = K_plotCircPhaseHist_one(radians)
    % h = K_plotCircPhaseHist_one(axh, ______)
    % h = K_plotCircPhaseHist_one(_____, 'Param', Value, ...)
    
    if ishandle(varargin{1})
        % h = K_plotCircPhaseHist_one(axh,radians,Param,Value)

        axh = varargin{1};
        radians = varargin{2};

        PNVStart = 3;
        
    else
        % h = K_plotCircPhaseHist_one(radians,Param,Value)

        radians = varargin{1};
        
        PNVStart = 2;
        
    end
    
    PNV = varargin(PNVStart:end);
    
    p = inputParser;
    
    p.addRequired('radians', vfrad);
    
    p.addParameter('Color',ColorSpec,@iscolorspec);
        
    p.addParameter('ZeroPos',zeropos,@(x) ~isempty(x) && ischar(x) ...
        && isrow(x) && ismember(x,{'top','left','right','bottom'}));
    
    p.addParameter('Direction',plotdir,@(x) ~isempty(x) && ischar(x) && isrow(x) ...
        && ismember(x,{'clockwise','anti'}));
    
    p.addParameter('GroupMean',groupmean,@(x) ~isempty(x) && ischar(x) && isrow(x) ...
        && ismember(x,{'on','off'}));
    
    p.addParameter('rayleighECDF',rayleighECDF,@(x) isvector(x) && isreal(x));
    
    p.addParameter('RadiusForHistScale',radiusForHistScale, @(x) isrow(x) && numel(x) == 2 ...
        && isnumeric(x) && all(x >=0) && x(1) < x(2))
    
    p.addParameter('RadiusForAngles',  radiusForAngles, @(x) isrow(x) && numel(x) == 2 ...
        && isnumeric(x) && all(x >=0))
    
    p.addParameter('RadiusForScales', radiusForScales, @(x) isrow(x) && numel(x) == 2 ...
        && isnumeric(x) && all(x >=0) && x(1) < x(2))
    
    p.addParameter('RadianForScales', radianForScales, @(x) isscalar(x) && isreal(x))

    %NOTE see also plotCircleGrids

    

    p.parse(radians, PNV{:});
    
    ColorSpec = p.Results.Color;
    zeropos = lower(p.Results.ZeroPos);
    plotdir = lower(p.Results.Direction);
    groupmean = lower(p.Results.GroupMean);
    rayleighECDF = p.Results.rayleighECDF;

    radiusForHistScale = p.Results.RadiusForHistScale;
    radiusForAngles = p.Results.RadiusForAngles;
    radiusForScales = p.Results.RadiusForScales;
    radianForScales = p.Results.RadianForScales;

end


end

%--------------------------------------------------------------------------

function txth = local_placetext(N,radians,rayleighECDF,axh)

sampleradmean= cellfun(@(x) circ_mean(x),radians);
groupradmean = circ_mean(sampleradmean);
groupradstd = circ_std(sampleradmean);

groupveclen = circ_r(sampleradmean);

sampleveclen= cellfun(@(x) circ_r(x),radians);
sampleveclenmean = mean(sampleveclen);
sampleveclenstd = std(sampleveclen); 

if isempty(rayleighECDF)
    raylstr = '';
    
else
    sigN = nnz(rayleighECDF < 0.05);
    
    raylstr = sprintf('Rayleigh'' test (p < 0.05): %d of %d\n', ...
        sigN,N);
end

thestr = sprintf(['n = %d\n',...
    '%s',...
    'Group cicrular mean %s std: %.3f %s %.3f%s\n', ...
    'Group vector length: %0.3f\n',...
    'Sample vector length mean %s std: %.3f %s %.3f\n'], ...
    N,...
    raylstr,...
    char(177),rad2deg(groupradmean),char(177),rad2deg(groupradstd),char(176),...
    groupveclen,...
    char(177),sampleveclenmean,char(177),sampleveclenstd);


axes(axh);  

txth = text(1.3, -0.15, thestr,...
    'HorizontalAlignment', 'right', 'VerticalAlignment','bottom',...
    'Units', 'normalized','Tag','Annotation Text',...
    'FontSize',9);

end

%--------------------------------------------------------------------------

function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K:
%
%
% input argument
% str (Optional) string in char type (row vector)
%
% output argument
% eid an error id composed of 'K:(functionname):str'

narginchk(0, 1);
p = inputParser;
p.addOptional('str', '', @(x) isempty(x) || ischar(x) && isrow(x));
p.parse(varargin{:});
str = p.Results.str;

if isempty(str)
str = '';
else
str = [':', str];
end

[~,m,~] = fileparts(mfilename('fullpath'));

eid = ['K:', m, str];


end
            
    
 



 


