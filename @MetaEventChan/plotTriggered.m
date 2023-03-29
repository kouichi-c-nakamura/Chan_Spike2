function res = plotTriggered(obj,varargin)
%
%   res = plotTriggered(obj,trigger,width_sec,offset_sec,histbin_sec)
%   res = plotTriggered(axh,obj,trigger,width_sec,offset_sec,histbin_sec)
%   res = plotTriggered(_____,ParamName,ParamValue)
%
% INPUT ARGUMETNS
%
% obj             A MetaEventChan object
% 
% trigger         A MetaEventChan object with the matching Start, Srate and
%                 Length with obj, or a column vector of 0 and 1 for
%                 trigger events, or a column vector of event time stamps
% 
% width_sec      Window in seconds. Must be 0 or positive.
% 
% offset_sec      Offset in seconds. Must be 0 or postive.
%
% OPTION
%
% histbin_sec     Histgram bin in seconds. Default is 0.001 sec (1 msec)
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'Average'       'PSTH' (default) | 'SDF' | 'off'  
%                 for event channel this is equivalent to create PSTH, but
%                 you need to set histbin
%
% 'AverageColor'  Colorsepc for average waveform
%
% % 'AverageDrawMode'  
% %                 'line' (default) | 'color'
% %                 'color' option uses surf() for color plots instead of
% %                 lines. Raster and ErrorBar is ingonored
%
% 'Raster'        'off' | 'on'  (default)
%
% 'RasterType'    'line' (default) | 'dot' | 'lines'
%                 'lines' is legacy and draws many line objects, while
%                 'line' will draw only one line object.
%
%
% 'RasterColor'   coloSpec for overdrawn waveforms
%
% 'SDFsigma'      sigma for spike density function
%                 Default is 0.015 sec (15 msec)
%
% 'Legend'       'on' (default) | 'off' %TODO
%
%
% OUTPUT ARGUMENTS
% res             structure
%
% S          structure
%            With fields holding graphic handle objects:
%                 axh           axes
%                 line_mean     mean
%                 line_err      error
%                 line_overdr   overdraw
%                 leg      	    legend
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 10-Jun-2020 21:29:25
%
% See also
% eventTriggeredAverage, linealpha, K_PSTHcorr, WaveformChan.plotTriggered

narginchk(4,inf);
p = inputParser;
p.addRequired('obj',@(x) isa(x,'MetaEventChan'));

if ishandle(varargin{1}) && strcmp(get(varargin{1},'Type'),'axes')
    axh = varargin{1};    
    args = varargin(2:end);
    
else
    axh = [];
    args = varargin(1:end);
end


vf0or1 = @(x) iscolumn(x) && all(x == 0 | x == 1);
vftimestamps = @(x) iscolumn(x) && isreal(x) && all(diff(x) > 0);
p.addRequired('trigger',@(x) (isa(x,'MetaEventChan') && isscalar(x))...
    || vf0or1(x) || vftimestamps(x));

p.addRequired('width_sec',@(x) isscalar(x) && isreal(x) && x > 0);
p.addRequired('offset_sec',@(x) isscalar(x) && isreal(x) && x > 0);
p.addOptional('histbin_sec',0.001,@(x) isscalar(x) && isreal(x) && x > 0);

p.addParameter('Average','psth',@(x) ismember(x,{'psth','sdf','off'}));
p.addParameter('AverageColor','r',@iscolorspec);
% p.addParameter('AverageDrawMode','line',@(x) ismember(x,{'line','color'}));


p.addParameter('Raster','on',@(x) ismember(x,{'on','off'}));
p.addParameter('RasterType','line',@(x) ismember(x,{'line','dot','lines'}));

p.addParameter('RasterColor','k',@iscolorspec);

p.addParameter('SDFsigma',0.015,@(x) isreal(x) && isscalar(x) && x >=0);

p.parse(obj,args{:});

trigger     = p.Results.trigger;
width_sec   = p.Results.width_sec;
offset_sec  = p.Results.offset_sec;
histbin_sec = p.Results.histbin_sec;

average      = lower(p.Results.Average);
averagecolor = p.Results.AverageColor;
if ischar(averagecolor)
    averagecolor = lower(averagecolor);
end
% averagedrawmode = p.Results.AverageDrawMode;
% if ischar(averagedrawmode)
%     averagedrawmode = lower(averagedrawmode);
% end

raster = lower(p.Results.Raster);
rasterType = lower(p.Results.RasterType);
rastercolor = p.Results.RasterColor;
if ischar(rastercolor)
    rastercolor = lower(rastercolor);
end

sdfsigma = p.Results.SDFsigma;

%% Job

if isa(trigger,'MetaEventChan')
    triggerevent = trigger.Data;
elseif vf0or1(trigger)
    assert(length(trigger) == obj.Length);
    triggerevent = trigger;
    
elseif vftimestamps(trigger)
    assert(max(trigger) <= obj.MaxTime);
    assert(min(trigger) >= obj.Start);

    triggerevent = timestamps2binned(trigger,obj.Start,obj.MaxTime,obj.SRate);
    
end


if strcmp(average,'psth')
    sdfsigma = 'off';
end


res = K_PSTHcorr(obj.Data,triggerevent,obj.SInterval,...
    width_sec,histbin_sec,offset_sec,'ErrorBar','off','RasterType',rasterType,...
    'SDF',sdfsigma,'Mode','crosscorr',...
    'Histogram','off','Raster','off'); % no figure

t = res.sweepXT;

if width_sec < 1
    T = t*1000;
else
    T = t;
end

%% Plot

if strcmpi(raster,'on') || strcmpi(average,'on')
    if ~isempty(axh)
        axes(axh);
        
        fig = ancestor(axh,'Figure');
        
    else
        fig = figure;
    end
    
    if isa(trigger,'MetaEventChan')
        triggername = trigger.ChanTitle;
    else
        triggername = 'event';
    end
    
    if width_sec < 1
        xunit = 'ms';
    else
        xunit = 's';
    end
    
    xlabel(sprintf('Time relative to %s (%s)', triggername,xunit));
    ylabel(sprintf('Firing rate (spikes/s)', obj.DataUnit));
    set(gca,'TickDir','out');
end

h_err = [];
switch average
    case 'psth'
            
        line(res.sweepXT,res.psthRate_mean);

    case 'sdf'
        
        line(res.sweepXT,res.SDF_mean);

end


if strcmpi(raster,'on')
    
    yyaxis right
    
    switch rasterType
        case 'line'
            
            xmat_ = zeros(size(res.rasterxmat,2)*3,1,'single');
            ymat_ = xmat_;
            
            for i = 1:size(res.rasterxmat,2)
                
                xmat_(i*3-2:i*3) = [res.rasterxmat(1,i); res.rasterxmat(2,i); NaN];
                ymat_(i*3-2:i*3) = [res.rasterymat(1,i); res.rasterymat(2,i); NaN];
                
            end
            
            h_raster = line(xmat_, ymat_, 'Marker','none','Color', rastercolor,...
                'Tag','Raster Line');% Faster
            
        case 'dot'
            
            h_raster = line(res.rasterxmat,res.rasterymat, 'Marker','none',...
                'Color', 'k','Tag','Raster Lines');
        case 'lines'
            
            h_raster = line(res.rasterxmat,res.rasterymat, 'Marker','none',...
                'Color', rastercolor,'Tag','Raster Lines');
    end
    
    ylim([min(res.rasterymat(:)), max(res.rasterymat(:))]);
    
    ylabel('Sweeps')
else
    h_raster = [];
end


end