function [h, N, outdata] = K_plotLinearPhaseHist( varargin )
% K_plotLinearPhaseHist create a linear histogram out of phase values in
% radians. It works on single sample and group data as well.
%
% [h, N, outdata] = K_plotLinearPhaseHist(radians)
% [h, N, outdata] = K_plotLinearPhaseHist(radians, nbin)
% [h, N, outdata] = K_plotLinearPhaseHist(axh, _____)
% [h, N, outdata] = K_plotLinearPhaseHist(_____, 'Param', Value, ...)
%
% INPUT ARGUMENTS
% radians        instantaneous phase values in radian
%                A numeric vector or a vector of cell array. If radians is
%                a cell vector, each cell contains a numeric vector of
%                phase values from one sample.
%
% nbin           the number of histogram bins, 20 or 36 is recommended
%
% axh            [] | an Axes object | two Axes objects
%                Axes handle. This can be empty, scalar or two-element
%                array. For scalar axh, this function will delete axh and
%                draw the main and sub axes in place of axh, so that The
%                outmost rectangle of the main and sub axes tallies with
%                Position of axh. If axh has two elements, then axh(1) will
%                be the main axes and axh(2) will be the sub axes.
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'Color'        ColorSpec
%
% 'XGrid'         'on' (default) | 'off' (1 or 0)
%
% 'PlotType'     'line' | 'bar' (default) | 'none'
%
% 'Errorbar'     'none' (default) | 'std' | 'sem'
%                Effective only when radians is a cell array vector but not
%                a scalar (i.e. group data input)
%
% 'Title'        string for title
%
% 'radiansallpoints'
%                Vectors whose length is interger multiple of nbin, or cell
%                array vector containg such vector. The value is histogram
%                counts for all the data points in one recording if numeric
%                array, or multiple recordings if cell array. This option
%                is used when you want to take biased data points
%                distrubution in phase into account. With this option, the
%                histogram coutns will be corrected based on the density of
%                datapoints at each histogram bin.
%
% 'rayleighECDF' Test results (P value) of Rayleigh's test (cirt_rtest) in
%                vector. The length must be the same as that of the sample
%                number of radians (1 if radians is numeric vector,
%                numel(radians) if cell vector).
%
% OUTPUT ARGUMENTS
%
% h              structure of handles
%                h.main       main axes
%                h.sub        sub axes for sign curve
%                h.titlepane  axes for title
%
% N              Sample number
%
% outdata        Structure with fields
%                x      for x data (frequency)
%                y      for y data (%)
%                yerr   for y data error range depending on Errorbar option
%
% Supporting group data and shaded error bars, 21/06/2013
%
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
% 05-May-2017 09:22:34



%% parse input arguments

[radians,nbin,axh,ColorSpec,xgrid,plottype,errorBar,titlestr,radiansallpoints,...
    rayleighECDF] = local_parser(varargin{:});

%% histcounts

% rad2deg   = @(X) X/pi*180;
% ang2rad   = @(X) X * pi /180;
% twocycles = @(X) circshift(repmat(X, 2, 1), round(size(X, 1)/2)); % two cycles
% plusalpha = @(X) [X(end);X;X(1)];


binrad = (2*pi)/nbin;
edges = (-pi:binrad:pi)';

axrad = edges(1:end-1) + binrad/2; % + binrad/2 to point the center of each bin


if isnumeric(radians) ||( iscell(radians) && numel(radians) <= 1) % One
    analysismode = 'one';
    
    N = 1;
    if ~isempty(rayleighECDF)
        assert(length(rayleighECDF)==1);
    end
    
    if iscell(radians)
        radians = cell2mat(radians);
    end
    
    if isrow(radians) % make it column vector
        radians = radians';
    end
    
    if isempty(radians)
        warning(eid('radians:empty'),'radians is empty. No plot is made by K_plotLinearPhaseHist.');
        h = [];
        x = axrad;
        y = zeros(size(axrad));
        yerr = [];
        ylabelstr = '';
        
        [~,outdata] = plotLinearPhase(axh,x,y,yerr,analysismode,ColorSpec,xgrid,plottype,...
            titlestr,ylabelstr,errorBar);
        return;
    end
    
    unitradN = histcounts(radians, edges); % edges(k) ? X(i) < edges(k+1). 
    % The last bin also includes the right bin edge, so that it contains X(i) if edges(end-1) ? X(i) ? edges(end)
    
    if isrow(unitradN)
        unitradN = unitradN';
    end
    
    histnorm =unitradN./sum(unitradN);
    if ~isempty(radiansallpoints) %TODO
        
        histnorm = local_normalizeWithAllDatapoints(histnorm, radiansallpoints);
        
    end
elseif iscell(radians) && numel(radians) > 1 % Group
    analysismode = 'group';
    
    N = numel(radians);
    
    ind = ~cellfun(@isempty, radians);
    radians = radians(ind); % delete the empty cell %TODO
    
    if ~isempty(rayleighECDF)
        rayleighECDF = rayleighECDF(ind);
        assert(length(radians) == length(rayleighECDF));
    end
    clear ind
    
    radians = local_makeCellContensColumn(radians);
    
    if iscolumn(radians) % make the cell vector a row
        radians = radians';
    end
    
    na_C = cellfun(@(x) histc(x, edges), radians, 'Uniformoutput', false); %TODO histcounts
    
    na_C = local_makeCellContensColumn(na_C);
    
    unitradN_C = cellfun(@(x) [x(1:end-2); x(end-1) + x(end)], na_C, 'Uniformoutput', false);
    clear na_C
    
    
    histnorm_C = cellfun(@(x) x./sum(x), unitradN_C, 'Uniformoutput', false);
    if ~isempty(radiansallpoints) %TODO
        
        if iscolumn(histnorm_C)
            if isrow(radiansallpoints)
                radiansallpoints = radiansallpoints';
            end
        else
            if iscolumn(radiansallpoints)
                radiansallpoints = radiansallpoints';
            end
        end
        
        histnorm_C = cellfun(@(x, y) local_normalizeWithAllDatapoints(x, y), ...
            histnorm_C, radiansallpoints, 'UniformOutput', false); %TODO need to be further examined 2015/03/21
        
    end
    
    histnorm_M = cell2mat(histnorm_C);
    
    histnorm = mean(histnorm_M, 2);
    histnorm_STD = std(histnorm_M, 0, 2);
    histnorm_SEM = histnorm_STD/sqrt(N);
    
end

if strcmpi(analysismode,'group') %TODO
    switch errorBar
        case 'std'
            yerr = histnorm_STD *100; % vector for STD % percentage
        case 'sem'
            yerr = histnorm_SEM *100; % vector for SEM % percentage
        case 'none'
            yerr = [];
    end
else
    yerr = [];
end



x = axrad;
y = histnorm*100; % percentage
ylabelstr = sprintf(['Firing Probability per %.1f', char(176), ' (%%)'], 360/nbin);

switch plottype
    case {'line','bar'}
        if isempty(axh)
            figure;
            axh = axes;
        end
        
        
        [h,outdata] = plotLinearPhase(axh,x,y,yerr,analysismode,ColorSpec,xgrid,plottype,...
            titlestr,ylabelstr,errorBar);
        ylimval = ylim(h.main.axh);
        ylim(h.main.axh,[0,max(ylimval)]);
        
        h.txt = local_placetext(N,radians,rayleighECDF,h.main.axh); %TODO

    case 'none'
        h = [];
        [~,outdata] = plotLinearPhase(axh,x,y,yerr,analysismode,ColorSpec,xgrid,plottype,...
            titlestr,ylabelstr,errorBar);
end


end

%--------------------------------------------------------------------------

function [radians,nbin,axh,ColorSpec,xgrid,plottype,errorBar,titlestr, ...
    radiansallpoints,rayleighECDF] = local_parser(varargin)


% initialization

axh = [];
nbin =[];


vfradians = @(x) isvector(x) && isnumeric(x) || ...
    iscell(x) && ...
    all(cellfun(@(y) isnumeric(y) && iscolumn(y) || isempty(y), x)) ||...
    all(cellfun(@(y) isnumeric(y) && isrow(y) || isempty(y) , x));
% cell contents must be all columns or all rows

if nargin == 1 %TODO
    % [h, N] = K_plotLinearPhaseHist(radians)
    
    radians = varargin{1};
    PNV = {};
    
elseif nargin >= 2
    
    if numel(varargin{1}) <=2 && ~isempty(isgraphics(varargin{1},'axes')) ...
            && all(isgraphics(varargin{1},'axes')) 
        %NOTE all([]) == true
        
        % [h,N] = K_plotLinearPhaseHist(axh, _____)
        
        axh = varargin{1};
        radians = varargin{2};
        
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
        
        radians = varargin{1};
        
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

p.addRequired('radians', vfradians);

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

p.addParameter('Title','',@(x) ischar(x) && isrow(x) || isempty(x));

vfradallpoints = @(x) ~isempty(x) && isvector(x) && isreal(x) && ...
    fix(length(x)/nbin) == length(x)/nbin;

p.addParameter('RadiansAllPoints',[],...
    @(x) (~iscell(x) ...
    && vfradallpoints(x)) || iscell(x) && ...
    all(cellfun(vfradallpoints, x)));

p.addParameter('rayleighECDF',[],@(x) isvector(x) && isreal(x));

p.parse(radians, nbin, PNV{:});

if isempty(nbin) || nbin == 0
    nbin = 36; % default value
end

ColorSpec = p.Results.Color;

xgrid = lower(p.Results.XGrid);
plottype = lower(p.Results.PlotType);
errorBar = lower(p.Results.ErrorBar);
titlestr = p.Results.Title;
radiansallpoints = p.Results.RadiansAllPoints;
rayleighECDF = p.Results.rayleighECDF;

end

%--------------------------------------------------------------------------

function txth = local_placetext(N,radians,rayleighECDF,mainaxh)


if N == 1
    if isempty(rayleighECDF)
        raylstr = '';
        
    else
        raylstr = sprintf('Rayleigh'' test: p = %.3e\n', ...
            rayleighECDF);
    end
    
    thestr = sprintf(['%s',...
        'Cicrular mean %s std: %.3f %s %.3f%s\n',...
        'Vector length: %.3f\n'], ...
        raylstr,...
        char(177),rad2deg(circ_mean(radians)),char(177),rad2deg(circ_std(radians)),char(176),...
        circ_r(radians));
    
elseif N > 1
    
    sampleradmean= cellfun(@(x) circ_mean(x),radians)';
    groupradmean = circ_mean(sampleradmean);
    groupradstd = circ_std(sampleradmean);
    
    groupveclen = circ_r(sampleradmean);
    
    sampleveclen= cellfun(@(x) circ_r(x),radians)';
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
end

axes(mainaxh);

txth = text(0.95, 0.95, thestr,...
    'HorizontalAlignment', 'right', 'VerticalAlignment','top',...
    'Units', 'normalized','Tag','Annotation Text');

end

%--------------------------------------------------------------------------

function histnorm = local_normalizeWithAllDatapoints(histnorm, radiansallpoints)
% histnorm = local_normalizeWithAllDatapoints(histnorm, radiansallpoints)
%
% histnorm     Normalized histogram counts, i.e. histogram counts devided
%              by the total number of counts in a column vector
%
% radiansallpoints
%              Histogram counts of entire data points. The bin number of
%              radiansallpoints must be integer multiple of that of
%              histnorm (length of histnorm).
%
%
% When UP state spends more time than DOWn state, instantaneous phase
% values for UP state can be more likely obtained for any event. Thus,
% phase histograms based on simple instantaneous phase histograms will be
% biased and show artificial peaks during UP state. In order to compensate
% for this bias, it is important to get instantaneous phase values for all
% the data point in a recording.

nbin = length(histnorm);
ratio = length(radiansallpoints)/nbin;
ref = zeros(nbin, 1);
reftotal = sum(radiansallpoints);
for i = 1:nbin
    I = (i - 1)*ratio + 1;
    
    ref(i) = sum(radiansallpoints(I:I+ratio-1)) / (reftotal/nbin);
    % this is the ratio of actual number of data points per bin to
    % the ideal number of data points per bin. If evenly
    % distributed the all the values should be 1.0
end
clear i I ratio

histnorm = histnorm./ref; % should be the same length

end
%--------------------------------------------------------------------------

function Cout = local_makeCellContensColumn(C)

TFrow = cellfun(@(x) ~iscolumn(x) && ~isempty(x), C);
if any(TFrow) % make them all column vector
    C(TFrow) = cellfun(@transpose, C(TFrow), 'UniformOutput', false);
end

Cout = C;

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

