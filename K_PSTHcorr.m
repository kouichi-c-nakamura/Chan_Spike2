function [out,h] = K_PSTHcorr(varargin)
% K_PSTHcorr draws PSTH, spike density function (SDF), crosscorrelogram or
% autocorrelogram against trigger event with an optinal raster plot.
%
%   [out,h] = K_PSTHcorr(target,trigger,Is,width,binsize,offset)
%   [out,h] = K_PSTHcorr(_______, ParamName,ParamValue)
%   [out,h] = K_PSTHcorr(ax,_____)
%
%
% INPUT ARGUMENTS
%
% target                a logical or binary (0 or 1) column vector for binned spikes
%
%                       %TODO NaN is now supported, but not tested yet.
%
% trigger               a column vector of logical | binary (0 or 1) numbers
%                       | a column vector of time stamps in seconds
%
%                       Use a column vector of 0s and 1s for binned trigger
%                       events (the same length as target).
%
%                       You can also use a column vector of time stamps (in
%                       seconds) as trigger. You can specify the starting
%                       time of the target vector by the 'Start' parameter
%                       (see below).
%
% Is                    the sampling interval (s) for both target and
%                       trigger
%
% width                 in sec
%                       Defines the width of the X axis in second
%
% binsize               in sec
%                       Defines the bin size for histogram in second. In case
%                       you use SDF, which is not dependent on bins, binsize is
%                       used to define the resolution in X axis. It is
%                       recommended to use small enoiugh binsize for a better
%                       represtation of data.
%
% offset                in sec
%                       Defines the offset from the left side of the X axis to
%                       time 0 in second.
%
% ax                    an axes object | axes object vector of two elements
%                       If you specify 'Raster' = 'dot' or 'line', then you
%                       need to pass a vector of two axes objects as ax.
%                       ax(1) is for PSTH/correlogram, and ax(2) is for
%                       raster. If you only need raster, you still need to
%                       pass dummy axes object for ax(1).
%                       Otherwise, ax must be a scalar axes object.
%
%
% OPTIONAL PARAMETER/VAlUE PAIRS
%
% 'Mode'               'psth' (default) | 'crosscorr' | 'autocorr'
%
%                       A trigger event that falls within a sweep is
%                       ignored for 'psth', while it is included for 'crosscorr'
%                       or 'autocorr'. Whereas 'crosscorr' includes events at
%                       time 0, they were ignored for 'autocorr'.
%
% 'TargetTitle'         row vector of characters
%
% 'TtriggerTitle'       row vector of characters
%
% 'Histogram'           'on' (default) | 'off'
%                       Wheather to plot the main histogram/SDF. If you set
%                       both 'Histogram' and 'Raster' to 'off', then no
%                       figure will be created.
%
% 'PlotType'            'line' (default) | 'hist'
%
%                       'line'   line drawing for PSTH/correlogram
%                       'hist'   histogram for PSTH/correlogram
%
%                        Options for the time of the histogram plot.
%
% 'HistY'               'count' (default) | 'rate'
%                       'count'  counts as histgram Y axis
%                       'rate'   firing rate as histgram Y axis
%
%                       Options for the Y axis of the histogram.
%
% 'Unit'                's' (default) | 'ms'
%
%                       's'      x axis in second
%                       'ms'     x axis in millisecond
%
%                       Options for the time unit of X axis.
%
% 'ErrorBar'            'off' (default) | 'std' | 'sem'
%
%                       'std' plots a shaded error bar as STD (ignored if Yaxis is 'count')
%                       'sem' plots a shaded error bar as SEM (ignored if Yaxis is 'count')
%
%                       Options for shaded error bar.
%
% 'Raster'              'off' (default) | 'on'
%                       Turn on and off raster plot.
%
% 'RasterType'          'dot' (default) | 'line' | 'lines'
%                       Raster plot with dots or vertical lines. 'dot' will
%                       create a line object per sweep and use Marker = '.'
%                       and MarkerSize = 5.
%
%                       'line' looks nicer, creating just one line object
%                       for eintire raster data points.
%
%                       'lines' is the same as 'line', except that 'lines'
%                       will create many line objects while 'line' does
%                       only one. Although 'line' is 5x faster than
%                       'lines', 'lines' allows detailed control of line
%                       objects.
%
% 'RasterY'             'sweeps' (default) | 'time'
%                        Y axis of the raster as sweeps or time of
%                        trigger events
%
%                       Options for the unit of Y axis of the raster plot.
%
% 'SDF'                 'off' (default) | 'on' 
%                       'off' plots a histogram rather than spike density
%                       function (SDF).
%
%                       'on' will plot SDF using the sigma defined by SDFsigma 
%                       instead of histogram (see below)
%
% 'SDFsigma'            'default' (default) | positive scalar
%
%                       'default' uses default values for sigma (0.015 sec) and
%                       binsize (1 msec) for SDF plot instead of histogram.
%
%                       If you provide a positive real number, it sets
%                       'sigma' i.e. standard deviation (SD) in seconds
%                       that determines the shape of Gaussian kernel to
%                       plot the curve as an SDF instead of histogram. The
%                       Gaussian kernal has the width of 3 x sigma for one
%                       side (6 x sigma for both sides).
%
%                       Options for spike density functions (SDF). With
%                       SDF, you can represent event data as an overlay of
%                       bell shape curves without depending on bin size
%                       (however not that it does depends on sigme value,
%                       which determines the width of the bell shape). In this
%                       implementation, you still need to provide binsize for SDF
%                       as well.
%
%                       The integral of the bell shape curve for each spike
%                       is 1 [mV*s].
%
%                       Szucs A (1998) Applications of the spike density
%                       function in analysis of neuronal firing patterns. J
%                       Neurosci Methods 81:159-167,
%                       https://www.ncbi.nlm.nih.gov/pubmed/9696321
%
% 'Start'               0 (default) | a real number
%                       Start time of the target vector in seconds. Only
%                       needed if you want to use time stamps for trigger,
%                       and the target vector starts at a time other than 0. 
%
% OUTPUT ARGUMENTS
%
% out                    structure
%                        Containing the following fields:
%
%         binCounts       Histgram counts for bins
%         sweepXT         X axis time vector for plot in sec
%         sweepXTedges    X axis time vector for bin edges (sweepXT is the midpoints of each bin)
%         psthRate_mean   PSTH Y data
%         psthRate_std    PSTH Y error data as STD
%         psthRate_sem    PSTH Y error data as SEM
%         SDF_mean        SDF Y data
%         SDF_std         SDF Y error data as STD
%         SDF_sem         SDF Y error data as SEM
%         sweeps_Tok      cell row vector, each element of which corresponds to
%                         Kth sweep and holding relative time stamps in
%                         raster plot. rasterxmat and rasterymat are
%                         prepared from this.
%         rasterxmat      A row vector of X values (time) for line plot for raster
%         rasterymat      A row vector of Y values for line plot for raster
%                         The Y values depend on 'RasterY' option ('sweeps' | 'time'). 
%                          
%                           line(rasterxmat,rasterymat,____) 
%                         
%                         with appropriate options will reproduce the
%                         raster plot.
%         triggerT_ok     A row vector of trigger times that are included in
%                         the plot
%         sweepn          The number of sweeps in raster
%         sdfSigma        The sigma for normal distirbution in SDF
%         binsize         in sec
%         width           in sec
%         offset          in sec
%         unit            's' | 'ms' 
%                         The value of 'Unit' parameter
%
% h                    Graphic objects as follows:
%         fig1            Figure
%         ax1             Axes for PSTH, auto-, or cross-correlogram
%         l1              Line
%         er1             Error range/bar
%         ax2             Axes for Raster plot
%         rasterh         Raster
%
% NOTE: Computaiton is carried out with 'int8' class to save memory and
% achieve speed. The limitation of this stragety is that you cannot use
% NaNs in int8. Thus you cannot analyze data containing NaNs.
% %TODO NaN has been supported but not tested yet.
%
% %TODO implementation of multiple colors and markers for raster plot. You'll
% need to specify something similar to marker code in Spike2. So, a possible
% syntac can be by a vector of integers for grouping, and color (face,
% edge), size, and marker settings for each groups. Implementation can be done
% by using multiple line objects per sweep.
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 17-Nov-2016 17:51:40
%
% See also
% K_PSTHcorr_test, K_PhaseHist_test


%TODO when using line, the left and right end of the line becomes awkward
% ... omit datapoints when plotting


%% parse mandatory input arguments

narginchk(6, inf);

[ax,binsize, errorbarmode, timeunit, Mode, offset, plottype, ...
    raster, rasterType, rasterY, histY, sdf, sdfSigma, Is, target, target_title, ...
    trigger, trigger_title, width, doplotHist] = local_parse(varargin{:});


%% job starts here

if any(isnan(target)) || any(isnan(trigger))
    target         = single(full(target)); % to save memory, use single
    trigger        = single(full(trigger));
    isNaN_included = true;
else
    target         = int8(full(target)); % to save memory, use int8
    trigger        = int8(full(trigger));
    isNaN_included = false;
end


triggerP    = find(trigger);
len         = length(target); % end of data
lenT        = (len - 1)*Is;
binsizeP    = binsize/Is; %NOTE this should not be rounded: when Is is low the rounding error here becomes huge
widthP      = round(width/Is); % The data points width contains
widthP_real = width/Is; % The data points width contains

offsetP  = round(offset/Is);

sweeps_included = false(1, length(triggerP));

sweeps_P = cell(1, length(triggerP));
sweepXTedges  = -offset:binsize:width-offset;
sweepXT = sweepXTedges + binsize/2;  % this must match the length of binCounts later
sweepXT(end) = []; %NOTE to match the size of histcounts output
if strcmp(timeunit,'ms')
    sweepXTedges = sweepXTedges*1000;
    sweepXT = sweepXT*1000;
end

if binsizeP == 0
   error('bin size is 0 after rounding. Check the Is input again')
end


%% Extended sweeps for SDF
% _(underscore) ... Extended sweeps for SDF. Each end is extended by
% 3*sdfSigma. Both ends of convolution cannot be used as valid data,
% so the  use of 'valid' option for conv shortens the length of resultant
% convolution. You need the extened sweeps as a workaround of this issue in
% order to get the convolution of the desired length and duration.

tailP = fix((3*sdfSigma)/Is);
% sweep_values_ = zeros(widthP + 2*tailP, 1, 'int8');
sweeps_P_ = cell(1, length(triggerP));
sweepXT_  = -offset - 3*sdfSigma : binsize : width -offset + 3*sdfSigma; %TODO should binsize/2 be added here??? probably yes. sweepXT_  = (-offset - 3*sdfSigma : binsize : width -offset + 3*sdfSigma) + binsize/2; 
%NOTE length(SweepXT_) ==  fix((width  + 6*sdfSigma)/binsize) +1;

sweepXT_(end) = []; %NOTE to match the size of histcounts output

if strcmp(timeunit,'ms')
    sweepXT_ = sweepXT_*1000;
end

%% Remove sweeps which overlap with the previous sweep

% Each trigger event that does not lie within the previous sweep generates
% a new sweep. Trigger events that fall in the previous sweep are ignored.


switch Mode
    case 'psth'
        for i = 1:length(triggerP)

            if isNaN_included
                sweep_values = zeros(widthP, 1, 'single');
                sweep_values_ = zeros(widthP + 2*tailP, 1, 'single'); %extended for SDF
            else
                sweep_values = zeros(widthP, 1, 'int8');
                sweep_values_ = zeros(widthP + 2*tailP, 1, 'int8'); %extended for SDF
            end

            startP = triggerP(i) - offsetP;
            endP = triggerP(i) - offsetP + widthP - 1;

            startP_ =  startP - tailP;
            endP_ = endP + tailP;

            if i == 1
                prevEndP = 0;
            else
                prevEndP = triggerP(i-1) - offsetP + widthP - 1; % i-1
            end

            sweep_values = prepSweepsPSTH(target, sweep_values, startP, endP,...
                prevEndP, len, triggerP, i);
            sweep_values_ = prepSweepsPSTH(target, sweep_values_, startP_, endP_,...
                prevEndP, len, triggerP, i); %extended for SDF

            sweeps_P{i} = find(sweep_values);
            sweeps_P_{i} = find(sweep_values_); %extended for SDF

            % exclude sweep_values that are filled with -1
            if all(sweep_values == -1)
                sweeps_included(i) = false; % to be ignored
            elseif all(sweep_values > -1)
                sweeps_included(i) = true;
            else
                error(eid('sweeps_included:invalid'),...
                    'sweep_values has unexpected values.');
            end

        end
        clear i startP endP prevEndP tailP sweep_values sweep_values_

    case {'crosscorr','autocorr'}
        for i = 1:length(triggerP)
            if isNaN_included
                sweep_values = zeros(widthP, 1, 'single');
                sweep_values_ = zeros(widthP + 2*tailP, 1, 'single'); %extended for SDF
            else
                sweep_values = zeros(widthP, 1, 'int8');
                sweep_values_ = zeros(widthP + 2*tailP, 1, 'int8'); %extended for SDF
            end

            startP = triggerP(i) - offsetP;
            endP = triggerP(i) - offsetP + widthP - 1;

            startP_ =  startP - tailP;
            endP_ = endP + tailP;

            sweep_values = prepSweepsCorr(Mode, target, sweep_values, startP,...
                endP, offsetP, len);
            sweep_values_ = prepSweepsCorr(Mode, target, sweep_values_, startP_,...
                endP_, offsetP, len); %extended for SDF

            sweeps_P{i} = find(sweep_values);
            sweeps_P_{i} = find(sweep_values_); %extended for SDF

            % exclude sweep_values that are filled with -1
            if all(sweep_values == -1)
                sweeps_included(i) = false; % to be ignored
            elseif all(sweep_values > -1)
                sweeps_included(i) = true;
            else
                error(eid('sweeps_included:invalid'),...
                    'sweep_values has unexpected values.');
            end


        end
        clear i startP endP tailP sweep_values sweep_values_
end

sweepn = length(find(sweeps_included));
% fprintf('%s, target %s, trigger %s\n', Mode, target_title, trigger_title);
% fprintf('The number of sweeps %d\n', sweepn);

sweeps_Pok  = sweeps_P(sweeps_included);
trigger_Tok = triggerP(sweeps_included)*Is;

sweeps_Pok_ = sweeps_P_(sweeps_included);

clear sweep_values sweep_values_


edgesP = 0:binsizeP:widthP_real; %NOTE avoid rounding error
histCount = zeros(length(edgesP)-1,length(sweeps_Pok));
for i = 1: length(sweeps_Pok)
    % histCount(:,i) = histc((sweeps_Pok{i}), edgesP);
    histCount(:,i) = histcounts((sweeps_Pok{i}), edgesP)'; %NOTE length = length(edgesP) - 1   
end
clear i edgesP

binCounts     = sum(histCount, 2);
psthRate_mean = mean(histCount, 2,'omitnan')/binsize;
psthRate_std  = std(histCount, 1, 2,'omitnan')/binsize;
psthRate_sem  = psthRate_std/sqrt(size(histCount, 2));
clear histCount

%% Plot a PSTH or correlogram

h.l1 = [];
h.er1 = [];
h.ax2 = [];
h.rasterh =[];
sweeps_Tok = [];

switch raster
    case 'on'
        
        if doplotHist
            
            if isempty(ax)
                h.fig1 = figure;
                h.fig1.Renderer  = 'Painters'; %TODO
                h.ax2 = subplot(2,1,1);
                h.ax1 = subplot(2,1,2);
            else
                h.fig1 = ancestor(ax(1),'figure');
                h.fig1.Renderer  = 'Painters'; %TODO
                h.ax1 = ax(1);
                h.ax2 = ax(2);
            end
            
            h.ax2.Tag = 'Raster';
            
        else % only raster
            
            if isempty(ax)
                h.fig1 = figure;
                h.fig1.Renderer  = 'Painters'; %TODO
                h.ax2 = axes(h.fig1);
                h.ax1 = [];
            else
                h.fig1 = ancestor(ax(1),'figure');
                h.fig1.Renderer  = 'Painters'; %TODO
                h.ax1 = ax(1);
                h.ax2 = ax(2);
            end
            
            h.ax2.Tag = 'Raster';
                    
        end
    case 'off'
        
        if doplotHist
            if isempty(ax)
                h.fig1 = figure;
                h.fig1.Renderer  = 'Painters'; %TODO
                h.ax1 = axes;
            else
                h.fig1 = ancestor(ax,'figure');
                h.fig1.Renderer  = 'Painters'; %TODO
                h.ax1 = ax;
            end
            
        else
            
            h = [];
            
        end

end
    
switch sdf
    case 'off'    
        if doplotHist
            
            [h] = plot_PSTH_correlogram(binCounts, psthRate_mean, psthRate_std,...
                psthRate_sem, sweepXT, histY, plottype, errorbarmode, timeunit, Mode, ...
                target_title, trigger_title, h);
            
            h.ax1.Tag = 'Histogram';
            
        end
        
        [h,SDF_mean,SDF_std,SDF_sem] = plotSDF(Mode, width, offset, binsize, Is, ...
            sweeps_Pok_, sweepXT_, sdfSigma, errorbarmode, timeunit, ...
            target_title, trigger_title, h, false);
        
    case 'on'
        
        [h,SDF_mean,SDF_std,SDF_sem] = plotSDF(Mode, width, offset, binsize, Is, ...
            sweeps_Pok_, sweepXT_, sdfSigma, errorbarmode, timeunit, ...
            target_title, trigger_title, h, true );
        
        h.ax1.Tag = 'SDF';

        
    otherwise
        error(eid('sdfSigma:invalid'),...
            'sdfSigma must be >= 0');
end


%% raster plot

switch raster
    case 'on'
        [h, sweeps_Tok,rasterxmat,rasterymat] = plot_raster(width,offset, ...
            Is,sweeps_Pok,trigger_Tok,lenT,timeunit,rasterType,rasterY,h, true);
    case 'off'
        [h, sweeps_Tok,rasterxmat,rasterymat] = plot_raster(width,offset, ...
            Is,sweeps_Pok,trigger_Tok,lenT,timeunit,rasterType,rasterY,h, false);       
end


%% format output structure

% zoom(h.fig1, 'xon'); pan(h.fig1, 'xon');

out.binCounts = binCounts;
out.sweepXT = sweepXT;
out.sweepXTedges = sweepXTedges;
out.psthRate_mean = psthRate_mean;
out.psthRate_std = psthRate_std;
out.psthRate_sem = psthRate_sem;
out.SDF_mean = SDF_mean;
out.SDF_std = SDF_std;
out.SDF_sem = SDF_sem;
out.sweeps_Tok = sweeps_Tok;
out.rasterxmat = rasterxmat;
out.rasterymat = rasterymat;
out.trigger_Tok = trigger_Tok';
out.sweepn = sweepn;
out.SDF_sigma = sdfSigma;
out.binsize = binsize;
out.width = width;
out.offset = offset;
out.unit = timeunit;


end

%--------------------------------------------------------------------------

function [ax, binsize, errorbarmode, timeunit, Mode, offset, plottype, ...
    raster, rasterType, rasterY, histY, sdf, sdfSigma, Is, target, target_title, ...
    trigger, trigger_title, width, doplotHist] = local_parse(varargin)

if numel(varargin{1}) <= 2 && all(isgraphics(varargin{1},'axes'))
    ax = varargin{1};
    varargin = varargin(2:end);
else
    ax = [];
end

p = inputParser;

vf_target = @(x) iscolumn(x) &&...
    all(x(x ~= 0 & ~isnan(x)) == 1); % support NaN
addRequired(p, 'target', vf_target);

vf_trigger = @(x) iscolumn(x) &&...
    (...
    all(x(x ~= 0 & ~isnan(x)) == 1) ...
    || all( diff(x) > 0)...
    );% support NaN
addRequired(p, 'trigger', vf_trigger);

vf_sInterval = @(x) isscalar(x) &&...
    isreal(x) && ...
    x > 0;
addRequired(p, 'Is', vf_sInterval);

vf_width = @(x) isreal(x) &&...
    isscalar(x) && ...
    x > 0;
addRequired(p, 'width', vf_width);

vf_binsize = @(x) isreal(x) &&...
    isscalar(x) && ...
    x > 0;
addRequired(p, 'binsize', vf_binsize);

vf_offset = @(x) isreal(x) &&...
    isscalar(x);
addRequired(p, 'offset', vf_offset);


validstr1 =  {'psth', 'crosscorr', 'autocorr'};
vf_mode = @(x) ischar(x) && ...
    any(validatestring(x, validstr1));
p.addParameter('Mode','psth',vf_mode);

p.addParameter('TargetTitle',[],@(x) ~isempty(x) && ischar(x) && isrow(x));

p.addParameter('TriggerTitle',[],@(x) ~isempty(x) && ischar(x) && isrow(x));

p.addParameter('Histogram', 'on', @(x) ~isempty(x) &&  ischar(x) && isrow(x) ...
    && ismember(lower(x), {'on', 'off'}));%TODO

p.addParameter('PlotType','line',@(x) ~isempty(x) && ischar(x) && isrow(x) ...
    && ismember(lower(x),{'line','hist'}));

p.addParameter('HistY','count',@(x)~isempty(x) && ischar(x) && isrow(x)...
    && ismember(lower(x),{'count','rate'}));

p.addParameter('Unit','s',@(x)~isempty(x) && ischar(x) && isrow(x)...
    && ismember(lower(x),{'s','ms'}));

p.addParameter('ErrorBar','off',@(x)~isempty(x) && ischar(x) && isrow(x)...
    && ismember(lower(x),{'off','std','sem'}));

p.addParameter('Raster','off',@(x)~isempty(x) && ischar(x) && isrow(x)...
    && ismember(lower(x),{'off','on'}));

p.addParameter('RasterType','dot',@(x)~isempty(x) && ischar(x) && isrow(x)...
    && ismember(lower(x),{'dot','line','lines'}));

p.addParameter('RasterY','sweeps',@(x)~isempty(x) && ischar(x) && isrow(x)...
    && ismember(lower(x),{'sweeps','time'}));

p.addParameter('SDF','off',@(x)~isempty(x) && ischar(x) && isrow(x) ...
    && ismember(lower(x),{'off','on'}));

p.addParameter('SDFsigma','default',@(x)~isempty(x) && ...
    (ischar(x) && isrow(x) && ismember(lower(x),{'default'}))...
    ||( isreal(x) && isscalar(x) && x > 0 ));

p.addParameter('Start',0,@(x) isscalar(x) && isreal(x));

p.parse(varargin{:});

target    = p.Results.target;
trigger   = p.Results.trigger;
Is        = p.Results.Is;
width     = p.Results.width;
binsize   = p.Results.binsize;
offset    = p.Results.offset;

Mode          = lower(p.Results.Mode);

target_title  = p.Results.TargetTitle;
trigger_title = p.Results.TriggerTitle;
doplotHist    = lower(p.Results.Histogram);
plottype      = lower(p.Results.PlotType);
histY         = lower(p.Results.HistY);
timeunit      = lower(p.Results.Unit);

errorbarmode  = lower(p.Results.ErrorBar);

raster        = lower(p.Results.Raster);
rasterType    = lower(p.Results.RasterType);
rasterY       = lower(p.Results.RasterY);

sdf           = lower(p.Results.SDF);
sdfSigma      = p.Results.SDFsigma;
start_sec     = p.Results.Start;


if Is > 100 % sampling interval more than 100 s?
    
    warning('The sampling interval Is = %.1f s appears to awefully long. Have you mistakenly passed the sampling rate to K_PSTHcorr?')
    
end


if isempty(trigger)
    
    trigger = progression(0,0,length(target))';

else
    if all(trigger(trigger ~= 0 & ~isnan(trigger)) == 1)
        
        assert(length(trigger) == length(target));
        
    elseif all( diff(trigger) > 0)
        
        trigger = timestamps2binned(trigger,start_sec,start_sec+(length(target)-1)*Is,1/Is);
        
    else
        error('unexpected format for trigger')
    end
end

assert(offset <= width);


if ischar(sdfSigma)
    switch lower(sdfSigma)
        case 'default'
            sdfSigma = 0.015; % default, sigma = 0.015 sec
    end
end

switch doplotHist
    case 'on'
        doplotHist = true;
    case 'off'
        doplotHist = false;
end
%% for autocorrelogram
if strcmp(Mode, 'autocorr') && ~all(target == trigger)
    error(eid('autocorr:mismatch'),...
        'for ''autocorr'' Mode, target and trigger must be identical.');
end

if strcmp(histY,'count') % error bar will be ignored if 'HistY' is 'count'
    errorbarmode = 'off';
end


switch raster
    case {'on'}
        assert(numel(ax) == 2 || isempty(ax))
    otherwise
        assert(isscalar(ax) || isempty(ax))
end

end

%--------------------------------------------------------------------------
function [h] = plot_PSTH_correlogram(binCounts, psthRate_mean, psthRate_std, ...
    psthRate_sem, sweepXT, histY, plottype, errorbarmode, timeunit, Mode, ...
    target_title, trigger_title, h)

switch histY
    case 'count'

        axes(h.ax1);
        switch plottype
            case 'line'
                h.l1 = plot(h.ax1, sweepXT(1:end-1) + diff(sweepXT(1:2))/2, binCounts(1:end-1));
                %NOTE for line plot, the data points should be placed at
                % the middle of bin width
                switch Mode
                    case 'psth'
                        set(h.l1,'Tag','PSTH Line')
                    case 'crosscorr'
                        set(h.l1,'Tag','Cross-correlogram Line')
                    case 'autocorr'
                        set(h.l1,'Tag','Auto-correlogram Line')
                end
            case 'hist'
                h.l1 = bar(h.ax1, sweepXT(1:end-1) + diff(sweepXT(1:2))/2, binCounts(1:end-1), 'BarWidth', 1);
                %NOTE for bar plot, the data points should be placed at
                % the middle of bin width
                xlim([sweepXT(1),  sweepXT(end)]);
                switch Mode
                    case 'psth'
                        set(h.l1,'Tag','PSTH Bar')
                    case 'crosscorr'
                        set(h.l1,'Tag','Cross-correlogram Bar')
                    case 'autocorr'
                        set(h.l1,'Tag','Auto-correlogram Bar')
                end
        end
        set(h.ax1, 'Box', 'off', 'TickDir', 'out');
        ylabel(h.ax1, 'Counts');

    case 'rate'

        colorspec1 = defaultPlotColors(1);
        colorspec2 = [0.5 0.5 1];

        ymean = psthRate_mean;


        axes(h.ax1);
        if strcmp(errorbarmode,'off')
            h.er1 = [];
        else
            switch errorbarmode
                case 'std' % mean +/- std
                    yerror = psthRate_std;
                case 'sem' % mean +/- sem
                    yerror = psthRate_sem;
            end
            %TODO if plotAsHist use of errorbar() might be preferred
            h.er1 = shadederrorbar(sweepXT + diff(sweepXT(1:2))/2,ymean,yerror,colorspec2);
            hold on;
        end

        switch plottype
            case 'line'
                h.l1 = line(sweepXT(1:end-1) + diff(sweepXT(1:2))/2, ymean(1:end-1), 'Color', colorspec1);
                %NOTE for line plot, the data points should be placed at
                % the middle of bin width
                switch Mode
                    case 'psth'
                        set(h.l1,'Tag','PSTH Line')
                    case {'crosscorr', 'autocorr'}
                        set(h.l1,'Tag','Correlogram Line')
                end
            case 'hist'
                h.l1 = bar(h.ax1, sweepXT(1:end-1) + diff(sweepXT(1:2))/2, ymean(1:end-1), 'BarWidth', 1);
                %NOTE for bar plot, the data points should be placed at
                % the middle of bin width
                xlim([sweepXT(1),  sweepXT(end)]);
                switch Mode
                    case 'psth'
                        set(h.l1,'Tag','PSTH Bar')
                    case {'crosscorr', 'autocorr'}
                        set(h.l1,'Tag','Correlogram Bar ')
                end
        end
        hold off;
        ylabel(h.ax1,'Firing rate (spikes/s)');
end

ylim(h.ax1, [0 max(ylim(gca))]);

switch timeunit
    case 's'
        xlabel(h.ax1, 'Time relative to the trigger (s)');
    case 'ms'
        xlabel(h.ax1, 'Time relative to the trigger (ms)');
end

set(h.ax1, 'Box', 'off', 'TickDir', 'out');

switch Mode
    case 'psth'
        title(h.ax1, sprintf('PSTH, target: %s, tirgger: %s', target_title, ...
            trigger_title));
    case 'crosscorr'
        title(h.ax1, sprintf('cross-correlogram, target: %s, tirgger: %s', ...
            target_title, trigger_title));
    case 'autocorr'
        title(h.ax1, sprintf('auto-correlogram, target: %s, tirgger: %s', ...
            target_title, trigger_title));
end


end

%--------------------------------------------------------------------------
function [h,sweeps_Tok,xmat,ymat] = plot_raster(width, offset, Is, ...
    sweeps_Pok, trigger_Tok, lenT, timeunit, rasterType, rasterY, h, doplot)

sweeps_Tok = cellfun(@(x) x*Is - offset, sweeps_Pok, ...
    'UniformOutput', false);
if strcmp(timeunit,'ms')
    sweeps_Tok = cellfun(@(x) x*1000, sweeps_Tok, ...
        'UniformOutput', false);
end

if doplot
    linkaxes([h.ax1, h.ax2], 'x');%NOTE this must be before actually plotting. If done after plotting, it takes long time to update axes.
    
    axes(h.ax2);
end

switch rasterType
    case 'dot'

        maxEventsINsweep = max(cellfun(@length, sweeps_Tok));
        xmat = NaN(maxEventsINsweep, length(sweeps_Tok));
        for i = 1:length(sweeps_Tok)
            xmat(1:length(sweeps_Tok{i}),i) = sweeps_Tok{i};
        end
        clear i

        switch rasterY
            case 'sweeps'
                ymat = 1:length(sweeps_Tok);
            case 'time'
                ymat = trigger_Tok';
        end

        if isempty(maxEventsINsweep)
            ymat = [];
        else
            ymat = repmat(ymat, maxEventsINsweep, 1);
        end
        
        if doplot
            
            h.rasterh = line(xmat, ymat, ... % line(xmat(:), ymat(:)) results in just one line object, but did not accelerate the plotting
                'Marker','.',...
                'MarkerSize', 5,...
                'MarkerEdgeColor', 'k',...
                'MarkerFaceColor', 'k',...
                'LineStyle', 'none',...
                'Tag','Raster Dots');
        else
            
           h.rasterh = [];
           
        end

    case {'line','lines'}
        xmat = vertcat(sweeps_Tok{:})';
        xmat = repmat(xmat, 2, 1);
        ycell = cell(size(sweeps_Tok));

        switch rasterY
            case 'sweeps'
                %%% y = [i-1 i];
                for i = 1:length(sweeps_Tok)
                    ycell{i} =ones(size(sweeps_Tok{i}))*i;
                end
                clear i

                ymat = vertcat(ycell{:})';
                ymat = [ymat; ymat - 1];

            case 'time'
                %%% y = [trigger_Tok(i)-lenT/length(sweeps_Tok),trigger_Tok(i)];

                for i = 1:length(sweeps_Tok)
                    ycell{i} =ones(size(sweeps_Tok{i}))*trigger_Tok(i);
                end
                clear i

                ymat = vertcat(ycell{:})';
                ymat = [ymat; ymat - (lenT/length(sweeps_Tok))];
        end

        if doplot
            
            switch rasterType
                case 'line'
            
                    %NOTE for accelration, X and Y for multiple lines are
                    % oraganized into just one vector for each, delimitted by a NaN
                    % https://blogs.mathworks.com/graphics/2015/06/09/object-creation-performance/
                    %
                    % This technique result in just one line object and drawing is
                    % much faster (~5 times), although we lose the fine control of
                    % each line through handles. That kind of operatinos should be
                    % done with xmat and ymat and then plotted anew.
                    
                    xmat_ = zeros(size(xmat,2)*3,1,'single');
                    ymat_ = xmat_;
                    
                    for i = 1:size(xmat,2)
                        
                        xmat_(i*3-2:i*3) = [xmat(1,i); xmat(2,i); NaN];
                        ymat_(i*3-2:i*3) = [ymat(1,i); ymat(2,i); NaN];
                        
                    end
                    
                    %TODO could this be simpler?
                    % cf
                    % X = [ts, ts, NaN(size(ts))]';
                    % X = X(:);
                    
                    h.rasterh = line(xmat_, ymat_, 'Marker','none','Color', 'k',...
                        'Tag','Raster Line');% Faster
     
                case 'lines'
                    
                    h.rasterh = line(xmat, ymat, 'Marker','none','Color', 'k',...
                        'Tag','Raster Line'); %NOTE Very Slow
                    
                otherwise
                    error('unexpected')
            end
        else
            
            h.rasterh = [];
            
        end

end

if doplot
    switch rasterY
        case 'sweeps'
            if isempty(sweeps_Tok)
                ylim(h.ax2, [0 1]);
            else
                ylim(h.ax2, [0 max(length(sweeps_Tok))]);
            end
            
            ylabel(h.ax2, 'Sweeps');
            
        case 'time'
            ylim(h.ax2, [0 lenT]);
            ylabel(h.ax2, 'Trigger events (s)');
    end
    
    if isempty(h.ax1)
        switch timeunit
            case 'ms'
                xlim(h.ax2, [-offset*1000, (width-offset)*1000]);
            case 's'
                xlim(h.ax2, [-offset, width - offset]);
        end
        
        switch timeunit
            case 's'
                xlabel(h.ax2, 'Time relative to the trigger (s)');
            case 'ms'
                xlabel(h.ax2, 'Time relative to the trigger (ms)');
        end
    else
        switch timeunit
            case 'ms'
                xlim(h.ax1, [-offset*1000, (width-offset)*1000]);
            case 's'
                xlim(h.ax1, [-offset, width - offset]);
        end    
    end
    
    set(h.ax2, 'Box', 'off', 'TickDir', 'out');
    title(h.ax2, 'Raster plot');

end
end

%--------------------------------------------------------------------------
function [h,SDF_mean,SDF_std,SDF_sem] = plotSDF(Mode, width, offset, binsize, Is, ...
    sweeps_Pok_, sweepXT_, sdfSigma, errorbarmode, timeunit, ...
    target_title, trigger_title, h, doplot)

%% spike density function

tailP = fix((3*sdfSigma)/Is);

sweeps_Tok_ = cellfun(@(x) (x - tailP)*Is - offset, sweeps_Pok_, ...
    'UniformOutput', false);
% contains timestamps (s) relative to the trigger
% need to consider the shift by 3*sdfSigma  (s) or tailP [points]

if strcmp(timeunit,'ms')
    sweeps_Tok_ = cellfun(@(x) x*1000, sweeps_Tok_, ...
        'UniformOutput', false);
end

binnedSweeps_ = zeros(length(sweepXT_), size(sweeps_Tok_, 2));

% binnedSweeps_ = zeros( fix((width+6*sdfSigma)/binsize) +1, size(sweeps_Tok_, 2));
% must be: size(sweepXT_, 2) == size(binnedSweeps_, 1)

for i = 1:length(sweeps_Tok_)
    binnedSweeps_(:, i) = histc(sweeps_Tok_{i}, sweepXT_); %TODO histc
end
clear i

kernel = prepGaussianKernel(sdfSigma, binsize);

ymatsdf = NaN(size(binnedSweeps_));
clear len

gap = fix((length(kernel) - 1)/2); % points for one side where convolution is not valid
% if length(kernel) is odd, gap is equal for both sides
% if length(kernel) is even, gap of the lest is shorter by 1 than that of the right

convlen = size(binnedSweeps_, 1) - length(kernel) + 1; % see help for 'conv' with 'valid' option

for i = 1:size(binnedSweeps_, 2)
    ymatsdf(gap+1 :gap + convlen, i) = conv(binnedSweeps_(:,i), kernel, 'valid');
end
clear i gap convlen

SDF_mean = mean(ymatsdf, 2,'omitnan');
SDF_std = std(ymatsdf, 1, 2,'omitnan');
SDF_sem = SDF_std/sqrt(size(ymatsdf, 2));
notNaN = ~isnan(SDF_std);

sweepXTn = sweepXT_(notNaN); % recovered
SDF_mean = SDF_mean(notNaN);
SDF_std = SDF_std(notNaN);
SDF_sem = SDF_sem(notNaN);

%% plot SDF

if doplot
    colorspec1 = defaultPlotColors(1);
    colorspec2 = [0.5 0.5 1];
    
    ymean = SDF_mean;
    
    axes(h.ax1);
    if strcmp(errorbarmode,'off')
        h.er1 = [];
    else
        switch errorbarmode
            case 'std' % mean +/- std
                yerror = SDF_std;
            case 'sem' % mean +/- sem
                yerror = SDF_sem;
            otherwise
                error(eid('errorbar:invalid'),...
                    'errorbar must be either 0, 1 or 2')
        end
        %     h.er1 = fill([sweepXT_(notNaN), fliplr(sweepXT_(notNaN))], ...
        %         [(ymean(notNaN)+yerror(notNaN))', fliplr((ymean(notNaN)-yerror(notNaN))')], ...
        %         colorspec2, 'linestyle', 'none');
        
        h.er1 = shadederrorbar(sweepXTn,ymean,yerror,colorspec2);
        %NOTE fill doesn't support NaN containg data
        hold on;
        
    end
    
    h.l1 = line(sweepXTn, ymean, 'Color', colorspec1);
    switch Mode
        case 'psth'
            set(h.l1,'Tag','PSTH SDF')
        case 'crosscorr'
            set(h.l1,'Tag','Cross-correlogram SDF')
        case 'autocorr'
            set(h.l1,'Tag','Auto-correlogram SDF')
    end
    
    
    ylim(h.ax1, [0, max(ylim(h.ax1))]);
    
    switch timeunit
        case 'ms'
            xlim(h.ax1, [-offset*1000, (width-offset)*1000]);
        case 's'
            xlim(h.ax1, [-offset, width - offset]);
    end
    
    hold off;
    ylabel(h.ax1,'SDF (1/s)');
    
    switch timeunit
        case 's'
            xlabel(h.ax1, 'Time relative to the trigger (s)');
        case 'ms'
            xlabel(h.ax1, 'Time relative to the trigger (ms)');
    end
    
    set(h.ax1, 'Box', 'off', 'TickDir', 'out');
    
    switch Mode
        case 'psth'
            title(h.ax1, sprintf('PSTH, target: %s, tirgger: %s', target_title, ...
                trigger_title));
        case 'crosscorr'
            title(h.ax1, sprintf('cross-correlogram, target: %s, tirgger: %s', ...
                target_title, trigger_title));
        case 'autocorr'
            title(h.ax1, sprintf('auto-correlogram, target: %s, tirgger: %s', ...
                target_title, trigger_title));
            
    end

end

end

%--------------------------------------------------------------------------
function sweep_values = prepSweepsPSTH(target, sweep_values, startP, endP, ...
    prevEndP, len, triggerP, i)
%
% output argument
% sweep_values        values for a single sweep for PSTH.
%                     1 for event, 0 for no event occurence.
%                     A disqualified sweep is filled with -1.
%                     For PSTH, when a sweep overlap prevopis one is
%                     disqualified (this diffes from correlogram).

if startP < 1   &&...
        endP <= len
    sweep_values(-startP+2:end) = target(1:endP);
%     sweep_values_(-startP_+2:end) = target(1:endP_) ;

elseif startP >= 1   &&...
        endP <= len   &&...
        prevEndP < triggerP(i) % difference from 'crosscorr','autocorr'
    sweep_values = target(startP:endP);
%     sweep_values_ = target(startP_:endP_); %TODO index out of range

elseif startP >= 1   &&...
        endP > len   &&...
        prevEndP < triggerP(i) % difference from 'crosscorr','autocorr'
    sweep_values(1:end -(endP- len)) = target(startP:len);
%     sweep_values_(1:end -(endP_- len)) = target(startP_:len);

else % disqualified
    sweep_values(:) = -1; % to be ignored
%     sweep_values_(:)= -1; % to be ignored
end

end

%--------------------------------------------------------------------------
function sweep_values = prepSweepsCorr(Mode, target, sweep_values, startP, ...
    endP, offsetP, len)
%
% output argument
% sweep_values        values for a single sweep for correlogram.
%                     1 for event, 0 for no event occurence.
%                     A disqualified sweep is filled with -1.

if startP < 1   &&...
        endP <= len
    sweep_values(-startP+2:end) = target(1:endP);

elseif startP >= 1   &&...
        endP <= len  % difference from 'PSTH'
    sweep_values = target(startP:endP); % slow

elseif startP >= 1   &&...
        endP > len  % difference from 'PSTH'
    sweep_values(1:end -(endP- len)) = target(startP:len);

else % disqualified
    sweep_values(:)= -1; % to be ignored
end

if strcmp(Mode, 'autocorr') % difference from 'crosscorr'
    sweep_values(offsetP + 1) = 0;
end

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
