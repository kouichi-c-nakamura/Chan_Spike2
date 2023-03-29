function [LTSstats, h, ISIordinal, ISIordinalmeta] = K_LTSburst_groupplot(groupdata, varargin)
% Use LTSburst class instead. K_LTSburst_groupplot plots data obtained from
% K_LTSburst_detect.
%
% [LTSstats, h, ISIordinal, ISIordinalmeta] = K_LTSburst_groupplot(groupdata, ____)
% [LTSstats, h, ISIordinal, ISIordinalmeta] = K_LTSburst_groupplot(____, 'errorbarmode', 'sem')
% [LTSstats, h, ISIordinal, ISIordinalmeta] = K_LTSburst_groupplot(____, 'errorwidth', 0.08)
% [LTSstats, h, ISIordinal, ISIordinalmeta] = K_LTSburst_groupplot(____, 'nudge', 0.03)
% [LTSstats, h, ISIordinal, ISIordinalmeta] = K_LTSburst_groupplot(____, 'ordinalPer', 'record')
% [LTSstats, h, ISIordinal, ISIordinalmeta] = K_LTSburst_groupplot(____, 'doplot', false)
% [LTSstats, h, ISIordinal, ISIordinalmeta] = K_LTSburst_groupplot(_____)
% 
%
% INPUT ARGUMENTS
%
% groupdata          n x 6 cell array, where n is the number of samples       
%                    Each row of groupdata contains data from a single
%                    sample, i.e. {spike, ISI, onset, offset, starttime, maxtime}.
%                    They can be obtained with K_LTSburst_detect() as
%                    follows:
% for i = 1:length(events)
%    [spike, ISI, onset, offset, starttime, maxtime] = K_LTSburst_detect(events{i}, Fs);
%    groupdata(i, :) = {spike, ISI, onset, offset, starttime, maxtime};
% end
%
%
% Column 1 of groupdata
% spike              structure contains data for each spike events
%   spike.point      data point counts
%   spike.time       time in seconds
%   spike.ISIbef     ISI before the spike
%   spike.ISIaft     ISI after the spike
%   spike.onset      whether the spike is onset of a LTS burst [0 or 1]
%   spike.offset     whether the spike is offset of a LTS burst [0 or 1]
%   spike.burstsize  the number of spikes contained in the LTS bursts [0 or integer]
%   spike.intraburstordinal  the ordial of the spike in the LTS burst
%
% Column 2 of groupdata
% ISI                vector of ISIs
% Note: ISI(1) and ISI(end) are shorter than actual ISIs!!!!!
%
% Column 3 of groupdata
% onset              onset of LTS bursts in spike ID
%
% Column 4 of groupdata
% offset             offset of LTS bursts in spike ID
%
% Column 5 of groupdata
% starttime          start of the record in second
%
% Column 6 of groupdata
% maxtime            end of the record in second
%
% Column 7 of groupdata
% name               (OPTIONAL) name of the neuron or file
%
%
% OPTIONAL Parameter/Value pairs
% 'errorbarmode'     ''     no error bar
%                    'std'  (default) error bar as standard deviation
%                    'sem'  error bar as standard error of mean
%
% 'errorwidth'       width of error bars. 0 or postie real number
%                    (Default) empty  ... for default width 
%
% 'nudge'            Nudge x axis of ISI ordinal and first ISI plot a little bit
%                    to improve visibility by a specfied amount.
%                    0 ~ 0.5
%                   (Default) = 0.05
%
% 'color'            Colorspec
%
% 'ordinalPer'       'isi' (default) or 'record'
%                    Determines how each data point in ISI ordinal plot is
%                    calculated, whether per ISI (each data point
%                    represents the mean of all the ISIs in all the data
%                    across animals) or per animal (each data point
%                    represents the mean of the means of a record/animal).
%
% 'doplot'           logical
%                    true (default) or false (supress plotting)
%
%
%
% OUTPUT ARGUMENTS
% LTSstats          Stats of LTS bursts
%
%   LTSrate                 mean rate of LTS burst occurence [bursts/sec]      
%   burstduration           duration of LTS bursts [sec]
%   burstdurationmean            mean duration of LTS bursts [sec]
%   intraburstISImean       mean intraburst ISI per burst [sec]
%   intraburstISImeanmean   mean of mean intraburst ISI [sec]
%   n_bursts                number of burst incidents
%   spikesperburst          number of spikes in each burst  
%   spikesperburstmean      mean number of spikes in each burst
%   spikes_all              number of all spikes
%   spikes_in_burst         number of all spike included in LTS bursts
%   spikes_in_burst_percent percentage of all spikes included in LTD bursts
%
% h.fig1 .. fig4    Sturucture contains figure handles
%
% ISIordinal        Intraburst ISI graduated by ordinal
%
% ISIordinalmeta    Group meta data of ISIordinal
%
%
% See Also 
% K_LTSburst_detect, K_LTSburst_readLTSchan, LTSburst

%% parse inputs

narginchk(1, 11);

p = inputParser;
vfg = @(x) iscell(x) && size(x,2) >= 6;
p.addRequired('groupdata',vfg);

vfebm = @(x) ~isempty(x) && ischar(x) && isrow(x) && ...
    ismember(x, {'','std', 'sem'});
                    
p.addParameter('errorbarmode', 'std', vfebm);

vfew = @(x) isnumeric(x)  && isempty(x) || ...
    isreal(x) && x >= 0 ;

p.addParameter('errorwidth', [], vfew);

vfnud = @(x) ~isempty(x) && isnumeric(x) && isscalar(x) && ...                     
    isreal(x) && x <= 0.5 && x >= 0;
                    
p.addParameter('nudge', 0.05, vfnud);

p.addParameter('color', 'b', @iscolorspec);

vfisiord = @(x) ~isempty(x) && ischar(x) && isrow(x) && ...
    ismember(lower(x), {'isi','record'});
                    
p.addParameter('isiordinalmode', 'isi', vfisiord);

vfdoplot = @(x) ~isempty(x) && isscalar(x) && islogical(x) ||...
    x == 1 || x == 0;

p.addParameter('doplot', true, vfdoplot);


p.parse(groupdata, varargin{:});

errorbarmode = p.Results.errorbarmode;
errorwidth = p.Results.errorwidth;
nudgeright = p.Results.nudge;
color = p.Results.color;
isiordinalmode = p.Results.isiordinalmode;
doplot = p.Results.doplot;


assert(all(cellfun(@(startt, maxt) all(maxt - startt > 0), groupdata(:,3), groupdata(:, 4))), ...
    eid('startmax'),...
    'starttime must be smaller than maxtime');

% if ~verLessThan('matlab','8.4.0')
%      % execute code for R2014b or later
%      
%      error(eid('version'), ...
%          'Sorry, this function is not compatible with MATLAB R2014b or later.');
%      % the organization of errorbar object is different in newer versions
%      
% end


% [errorbarmode, errorwidth, nudgeright, color, isiordinalmode, doplot] = ...
%     local_parse_paramvalpair(errorbarmode, errorwidth, nudgeright, color, ...
%     isiordinalmode, doplot, varargin{:});


n = size(groupdata, 1);

spike = groupdata(:,1);
ISI = groupdata(:,2);
onset = groupdata(:,3);
offset = groupdata(:,4);
% starttime = groupdata(:,5); 
maxtime = groupdata(:,6);
name = groupdata(:,7);


%% bursts classified by spike number

burstmax = nan(n, 1);
LTS_i_spikes = cell(n, 1);
onsetLTS_i_spikes = cell(n, 1);

for s = 1:n
    
    if ~isempty(max([spike{s}(:).burstsize]))
        burstmax(s) = max([spike{s}(:).burstsize]);
        LTS_i_spikes{s} = cell(burstmax(s),1); 
        onsetLTS_i_spikes{s} = cell(burstmax(s),1); 
        
        for i = 2:burstmax(s)
            try
                LTS_i_spikes{s}{i} = spike{s}([spike{s}(:).burstsize] == i);
                onsetLTS_i_spikes{s}{i} = find([spike{s}(:).burstsize]' == i & ...
                    [spike{s}(:).onset]' == 1); 
            catch ME
                getReport(ME, 'extended');
                keyboard;
            end
        end
    
    else    
        
    end
    
    
end

%% intrabust ISI changes

% [LTS_i_spikes{2}.intraburstordinal]' == 1

% ind2 = find([spike{s}.burstsize]' == 2 & [spike{s}.onset]' == 1)
% ISI(ind2+1)
% ISI(ind2+2)

ISIordinal = cell(n ,1);
for s = 1:n
    if ~isnan(burstmax(s))
        
        ind = cell(burstmax(s), 1);
        ISIordinal{s} = cell(burstmax(s), burstmax(s)-1);
        for i = 2:burstmax(s)
            ind{i} = find([spike{s}.burstsize]' == i & [spike{s}.onset]' == 1);
            for j = 1:i-1
                ISIordinal{s}{i,j} = ISI{s}(ind{i}+j);
            end
        end
    else
        ISIordinal{s} = cell(0,0);
    end
end

clear ind

%% ISI ordinal plot

M = nanmax(burstmax);
if isnan(M)
	M = [];
end

ISIordinalmeta = cell(M, M - 1); %TODO cannot handle the case where there is no spike

switch lower(isiordinalmode)
    case 'record' % each data point represent the mean of the mean of a record
        for i = 2:M % the size of burst
            buffer = nan(n, i-1);
            for s = 1:n
                if i <= burstmax(s)
                    buffer(s, 1:i-1) = mean([ISIordinal{s}{i,:}], 1);
                else
                    buffer(s, 1:i-1) = NaN;
                end
                
            end
            
            for j = 1:i-1 % column
                ISIordinalmeta{i, j} = buffer(:,j);
            end
        end
    case 'isi' % each data point represent the mean of all the ISIs in the all data pool
        for i = 2:M % the size of burst
            for j = 1:i-1 % column
                for s = 1:n
                    if i <= burstmax(s)
                        ISIordinalmeta{i, j} = [ISIordinalmeta{i, j}; ISIordinal{s}{i,j}];
                    else
                    end
                end
            end
        end
    otherwise
        error(eid('ISIordinalmode:invalid'),...
        'ISIordinalmode is invalid');
end

if doplot
    
    h.fig1 = figure;
    hold on
    h.fig1_e1 = zeros(M, 1);
    h.fig1_line = zeros(M, 1);
    h.fig1_axh = gca;
    
    TF = false(M, 1);
    markerseries = {'o','^','s','p','v','x','d'}; % seven markers
    markercolor = {'none', color};
    legendstr = cell(1, M);
    nudgeleft = nudgeright*(M - 2)/2;
    
    
    for i = 2:M
        if ~isempty(ISIordinalmeta{i,1})
            TF(i) = true;
            
            switch lower(errorbarmode)
                case 'std'
                    h.fig1_line(i) = errorbar((1:i-1) - nudgeleft + nudgeright*(i-2), nanmean([ISIordinalmeta{i,:}], 1)*1000, ...
                        nanstd([ISIordinalmeta{i,:}], 0, 1)*1000);
                case 'sem'
                    n_samples = nnz(~isnan([ISIordinalmeta{i,:}]));
                    
                    h.fig1_line(i) = errorbar((1:i-1) - nudgeleft + nudgeright*(i-2), nanmean([ISIordinalmeta{i,:}], 1)*1000, ...
                        nanstd([ISIordinalmeta{i,:}], 0, 1)*1000/sqrt(n_samples));
                    clear n_samples
                otherwise
                    h.fig1_line(i) = line((1:i-1) - nudgeleft + nudgeright*(i-2), nanmean([ISIordinalmeta{i,:}], 1)*1000);
            end
            
            set(h.fig1_line(i),...
                'Color', color, ...
                'Marker', markerseries{rem((i-2),7) + 1},... %Cycle through markers
                'MarkerFaceColor', markercolor{rem(floor((i-2)/7),2) +1}); % alternate face color
            
            if ~isempty(errorwidth)
                child1 = get(h.fig1_line(i), 'Children');
                local_seterrorwidth(child1(2), errorwidth);
            end
            
            legendstr{i} = sprintf('%d (n = %d)', i, length(ISIordinalmeta{i,1}));
            
        end
        
    end
    
    if M > 0
        xlim([0, M+1]);
        format_XTickLabel(gca, 1:(M - 1), 0);
    end
    format_YTickLabel(gca, 0:10, 0);
    ylim([0 max(ylim(gca))]);
    xlabel('ISI ordinal');
    ylabel('Intraburst ISI [ms]');
    
    % legend
    h.fig1_leg = legend(h.fig1_line(TF), legendstr(TF), 'Location','southeast', 'FontSize', 8);
    legend('boxoff');
    legpos = get( h.fig1_leg, 'Position');
    h.fig1_t = text(0, 0, 'Spikes/burst', 'FontSize', 8);
    set(h.fig1_t, 'Units', 'normalized');
    if ~isempty(legpos)
        set(h.fig1_t, 'Position', [ legpos(1)*1.05, (legpos(2) + legpos(4))*1.05, 0]); %TODO adjustment
    end

else
    h.fig1 = [];
    h.fig1_e1 = [];
    h.fig1_line = [];
    h.fig1_leg = [];
    h.fig1_t = [];
    h.fig1_axh = [];

end

ISIordinal = cellfun(@(x) local_convert2table(x),ISIordinal,'UniformOutput',false);
ISIordinalmeta = local_convert2table(ISIordinalmeta);


%% plot of first ISI in burst

if doplot
    h.fig2 = figure;
    hold on
    
    if M > 0
        switch lower(errorbarmode)
            case 'std'
                h.fig2_line = errorbar(2:M, ...
                    cellfun(@(X) nanmean(X,1)*1000, ISIordinalmeta(2:M,1)'),...
                    cellfun(@(X) nanstd(X,1)*1000, ISIordinalmeta(2:M,1)'));
            case 'sem'
                h.fig2_line = errorbar(2:M, ...
                    cellfun(@(X) nanmean(X,1)*1000, ISIordinalmeta(2:M,1)'),...
                    cellfun(@(X) nanstd(X,1)*1000/sqrt(nnz(~isnan(X))), ISIordinalmeta(2:M,1)'));
            otherwise
                h.fig2_line = line(2:M, cellfun(@(X) nanmean(X,1)*1000, ISIordinalmeta(2:M,1)'));
        end
        
        set(h.fig2_line, 'Color', color);
        
        for i=2:M
            h.fig2_mark = line(i, cellfun(@(X) nanmean(X,1)*1000, ISIordinalmeta(i,1)'),...
                'LineStyle', 'none', ...
                'MarkerEdgeColor', color, ...
                'Marker', markerseries{rem((i-2),7) + 1},... %Cycle through markers (see above)
                'MarkerFaceColor', markercolor{rem(floor((i-2)/7),2) +1}); % alternate face color (see above)
        end
        
        if ~isempty(errorwidth)
            child2 = get(h.fig2_line, 'Children');
            local_seterrorwidth(child2(2), errorwidth);
        end
    end
    
    format_XTickLabel(gca, 2:(M-1), 0);
    format_YTickLabel(gca, 0:0.5:10, 1);
    ylim('auto');
    ylim([0 max(ylim(gca))]);
    if M > 0
        xlim([1, M+1]);
    end
    xlabel('The number of spikes in bursts');
    ylabel('The first ISI in bursts [ms]');
    h.fig2_axh = gca;
    
else
    h.fig2 = [];
    h.fig2_line = [];
    h.fig2_mark = [];
    h.fig2_axh = [];
end



%% burst stats 

c = cell([n, 1]);
LTSstats = struct('intraburstISImean', c,...
    'intraburstISImeanmean', c,...
    'spikesperburst', c,...
    'spikesperburstmean', c,...
    'n_bursts', c,...
    'burstduration', c,...
    'burstdurationmean', c,...
    'LTSrate', c,...
    'spikes_all', c,...
    'spikes_in_burst', c,...
    'spikes_in_burst_percent', c );

LTSstats = orderfields(LTSstats);
clear c

for s =1:n
    % mean intraburst ISI [sec]
    
    LTSstats(s).intraburstISImean = zeros(size(onset{s}));
    for i = 1:length(onset{s})
        LTSstats(s).intraburstISImean(i) = mean(ISI{s}(onset{s}(i)+1:offset{s}(i)));%TODO
    end
    LTSstats(s).intraburstISImeanmean = mean(LTSstats(s).intraburstISImean);
    
    % mean number of spikes per burst
    
    LTSstats(s).spikesperburst = [spike{s}([spike{s}.onset] == 1).burstsize]';
    LTSstats(s).spikesperburstmean = mean(LTSstats(s).spikesperburst);
    
    % number of bursts
    
    LTSstats(s).n_bursts = length(onset{s});
    
    % mean burstduration of LTS bursts [sec]
    
    LTSstats(s).burstduration = [spike{s}([spike{s}.offset] == 1).time]' - [spike{s}([spike{s}.onset] == 1).time]';
    LTSstats(s).burstdurationmean = mean(LTSstats(s).burstduration);
    
    % mean rate of LTS burst occurence [bursts/sec]
    LTSstats(s).LTSrate = LTSstats(s).n_bursts/maxtime{s};
    
    % mean interburst interval
    % TODO how to define? onset-offset? or inverse of LTSrate?
    
    LTSstats(s).name = name{s};
    
    LTSstats(s).spikes_all = length(spike{s});
    LTSstats(s).spikes_in_burst = sum(LTSstats(s).spikesperburst);
    
    LTSstats(s).spikes_in_burst_percent = LTSstats(s).spikes_in_burst/LTSstats(s).spikes_all * 100;
    
end

LTSstats = orderfields(LTSstats);



%TODO plot time views for all neurons (in one panel with a slider or tabs to select a neuron)

%% plot time view
% h.fig3 = figure;
% a1 = axes;
% set(a1, 'TickDir', 'out');
% zoom xon
% pan xon
% xlabel('Time [sec]');
% set(a1, 'YTick',0.5:2:20.5);
% yticklabel = cell(1, 10);
% 
% 
% % unite
% h1 = zeros(length(spike), 1);
% for i = 1:length(spike)
%     h1(i)=line([spike(i).time, spike(i).time], [0, 1], 'Color','k');
% end
% h1(i+1) = line([starttime maxtime], [0.5 0.5], 'Color','k');
% yticklabel{1} = 'spike';
% 
% % LTS
% hold on
% h2 = zeros(length(onset), 1);
% for i=1:length(onset)
%     h2(i)=fill([spike(onset(i)).time, spike(offset(i)).time,...
%         spike(offset(i)).time, spike(onset(i)).time],...
%         [2 2 3 3],'k');
% end
% hold off
% zoom xon
% pan xon
% yticklabel{2} = 'LTS';
% 
% 
% % onset
% h3 = zeros(length(onset), 1);
% for i=1:length(onset)
%     h3(i)=line([spike(onset(i)).time, spike(onset(i)).time], [4, 5], 'Color','k');
% end
% h2(i+1) = line([starttime maxtime], [4.5 4.5], 'Color','k');
% yticklabel{3} = 'onset';
% 
% 
% % onset of bursts with n spikes
% 
% h4 = cell(burstmax+1, 1);
% for i = 2:burstmax
%     for j = 1:length(onsetLTS_i_spikes{i})
%         h4{i} = line([spike(onsetLTS_i_spikes{i}(j)).time,...
%             spike(onsetLTS_i_spikes{i}(j)).time],...
%             [2+2*i, 3+2*i], 'Color','k');
%     end
%     h4{burstmax +1, 1} = line([starttime maxtime], [(2.5 +2*i), (2.5 +2*i)], 'Color','k');
%     yticklabel{2+i} = ['onset ', num2str(i), ' spikes'];
% end
% 
% set(a1, 'YTickLabel', yticklabel);
% xlim([starttime maxtime]);

%% plot for ISI before spike (X) vs ISI after spike (Y)


if doplot
    h.fig4 = figure;
    
    h.fig4_line = zeros(n,1);
    
    for s = 1:n
        if ~isempty(spike{s})
            h.fig4_line(s) = loglog([spike{s}.ISIbef].*1000, [spike{s}.ISIaft].*1000, ...
                'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 2,  'Color', color);
            hold on
        end
    end
    xlabel('ISI before spike [ms]');
    ylabel('ISI after spike [ms]');
    set(gca, 'Box', 'off', 'TickDir', 'out');
    h.fig4_axh = gca;


else
    
    h.fig4 = [];
    h.fig4_line = [];
    h.fig4_axh = [];

end


end

%--------------------------------------------------------------------------

function local_seterrorwidth(handle, errorwidth)
%
%     [XData]   [YData]
%     1.0600    2.2000 vertical
%     1.0600    1.9000 vertical
%        NaN       NaN
%     1.0400    2.2000 top error
%     1.0800    2.2000 top error
%        NaN       NaN
%     1.0400    1.9000 bottom error
%     1.0800    1.9000 bottom error
%        NaN       NaN
%     ...   

%% parse
narginchk(2,2);

p =inputParser;
vfh = @ishandle;

vfe = @(x) isscalar(x) && isnumeric(x) && x >= 0;

p.addRequired('handle', vfh);
p.addRequired('errorwidth', vfe);

p.parse(handle, errorwidth);

%% job

X = get(handle, 'XData');

points = length(X)/9;
assert(fix(points) == points, ...
    eid('local_seterrorwidth:points'),...
    'points is expected to be integer');

width = errorwidth/2;
for i = 1:points
    midpoint = X(1 + (i-1)*9);
    left = midpoint - width;
    right = midpoint + width;
    
    X([4, 7] + (i-1)*9) = left;
    X([5, 8] + (i-1)*9) = right;
        
end

set(handle, 'XData', X);

end

%--------------------------------------------------------------------------

function format_XTickLabel( axh, xtick, decimalp )
%format_XTickLabel ( axh, xtick, decimalp ) set XTick andXYTickLabel with a vector
% 
%   axh .... axes handle
%   xtick .... a horizontal vector, monotonically increasing
%   decimalp .... an integer which specifies the number of decimal places
%
% example
% format_XTickLabel(gca, 0:0.2:2, 1)
%
% See Also format_YTickLabel

%% parse inputs


narginchk(3, 3);

p = inputParser;
% p.addOptional('str', '', @(x) isempty(x) || ischar(x) && isrow(x));
% p.parse(varargin{:});
% str = p.Results.str;

vf1 = @(x) ~isempty(x) &&...
    isscalar(x) && ...
    ishandle(x);
addRequired(p, 'axh', vf1);

vf2 = @(x) isnumeric(x) &&...
    issorted(x) &&...
    (isrow(x) || isempty(x));
addRequired(p, 'XTick', vf2);

vf3 = @(x) ~isempty(x) &&...
    isnumeric(x) &&...
    isscalar(x) &&...
    fix(x) == x &&...
    x >= 0;
addRequired(p, 'decimalp', vf3);

parse(p, axh, xtick, decimalp);

%% job
xtickc = cell(1, length(xtick));
for i = 1:length(xtick)
    if xtick(i) == 0
        xtickc{i} = '0';
    else
        xtickc{i} = num2str(xtick(i), ['%.', num2str(round(decimalp)),'f']);
    end
end
set(axh, 'XTick', xtick, 'XTickLabel', xtickc, 'TickDir', 'out', 'Box', 'off');

[~,m,~] = fileparts(mfilename('fullpath'));

end

%--------------------------------------------------------------------------

function format_YTickLabel( axh, ytick, decimalp )
%format_YTickLabel( axh, ytick, decimalp ) set YTick and YTickLabel with a vector
%   axh        axes handle
%   ytick      a horizontal vector, monotonically increasing
%   decimalp   an integer which specifies the number of decimal places

% example
% format_YTickLabel(gca, 0:0.2:2, 1)
%
% See Also format_XTickLabel

%% parse inputs

narginchk(3, 3);

p = inputParser;

vf1 = @(x) ~isempty(x) &&...
    isscalar(x) && ...
    ishandle(x);
addRequired(p, 'axh', vf1);

vf2 = @(x) isnumeric(x) &&...
    issorted(x) &&...
    (isrow(x) || isempty(x));
addRequired(p, 'ytick', vf2);

vf3 = @(x) ~isempty(x) &&...
    isnumeric(x) &&...
    isscalar(x) &&...
    fix(x) == x &&...
    x >= 0;
addRequired(p, 'decimalp', vf3);

parse(p, axh, ytick, decimalp);

%% job

ytickc = cell(1, length(ytick));
for i = 1:length(ytick)
    if ytick(i) == 0
        ytickc{i} = '0';
    else
        ytickc{i} = num2str(ytick(i), ['%.', num2str(round(decimalp)),'f']);
    end
end
set(axh, 'YTick', ytick, 'YTickLabel', ytickc, 'TickDir', 'out', 'Box', 'off');


end

%--------------------------------------------------------------------------

function ISIordinal2 = local_convert2table(ISIordinal)
%
% Convert cell array ISIordinal to a table for readability.
% Note that asignment and reference is not the same for cell array.

sz = size(ISIordinal);

rN = cell(1,sz(1));
for i = 1:sz(1)
    rN{i} = sprintf('burstwith%dspikes',i);
end

vN = cell(1,sz(2));
for i = 1:sz(2)
    vN{i} = sprintf('ISI%d',i);
end

ISIordinal2 = cell2table(ISIordinal,'VariableNames',vN,'RowNames',rN);

end

