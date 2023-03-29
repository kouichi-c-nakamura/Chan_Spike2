function [LTSstats, h, ISIordinal] = K_LTSburst_plot(spike, ISI, onset, offset, starttime, maxtime, varargin)
% [LTSstats, h, ISIordinal] = K_LTSburst_plot(spike, ISI, onset, offset, starttime, maxtime, ____)
% [LTSstats, h, ISIordinal] = K_LTSburst_plot(spike, ISI, onset, offset, starttime, maxtime, 'name', 'filename')
% [LTSstats, h, ISIordinal] = K_LTSburst_plot(spike, ISI, onset, offset, starttime, maxtime, 'errorbarmode', 'sem')
% [LTSstats, h, ISIordinal] = K_LTSburst_plot(spike, ISI, onset, offset, starttime, maxtime, 'errorwidth', 0.08)
% [LTSstats, h, ISIordinal] = K_LTSburst_plot(spike, ISI, onset, offset, starttime, maxtime, 'nudge', 0.03)
% 
% INPUT ARGUMENTS
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
% ISI                vector of ISIs
% Note: ISI(1) and ISI(end) are shorter than actual ISIs!!!!!
%
% onset              onset of LTS bursts in spike ID
% offset             offset of LTS bursts in spike ID
% starttime          start of the record in second
% maxtime            end of the record in second
%
% OPTIONAL Parameter/Value pairs
% 'name'             name of the neuron or file
%
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
% 'color'           Colorspec
%
%
% OUTPUT ARGUMENTS
% LTSstats          Stats of LTS bursts
%   LTSrate                 mean rate of LTS burst occurence [bursts/sec]      
%   duration                duration of LTS bursts [sec]
%   durationmean            mean duration of LTS bursts [sec]
%   intraburstISImean       mean intraburst ISI per burst [sec]
%   intraburstISImeanmean   mean of mean intraburst ISI [sec]
%   n_bursts                number of burst incidents
%   spikesperburst          number of spikes in each burst  
%   spikesperburstmean      mean number of spikes in each burst
%
% h.fig1 .. fig4       figure handles
%
% See Also K_LTSburst_detect, K_LTSburst_readLTSchan

%% TODO parse inputs

narginchk(6, 16);

assert(starttime < maxtime, eid('startmax'),...
    'starttime must be smaller than maxtime');

%%%%%%%%%%%% Default Values
errorbarmode = 'std';
errorwidth = [];
nudgeright = 0.05;
name = '';
color = 'b';
%%%%%%%%%%%%%%%%%%%%%%%%%%%

[name, errorbarmode, errorwidth, nudgeright, color] = ...
    local_parse_paramvalpair(name, errorbarmode, errorwidth, nudgeright, color, varargin{:});


%% bursts classified by spike number

burstmax = max([spike(:).burstsize]);
LTS_i_spikes = cell(burstmax,1);
onsetLTS_i_spikes = cell(burstmax,1);
for i = 2:burstmax
    try
        LTS_i_spikes{i} = spike([spike(:).burstsize] == i);
        onsetLTS_i_spikes{i} = find([spike(:).burstsize]' == i & ...
            [spike(:).onset]' == 1);
    catch ME
        getReport(ME, 'extended');
        keyboard;
    end
end

%% intrabust ISI changes

% [LTS_i_spikes{2}.intraburstordinal]' == 1

% ind2 = find([spike.burstsize]' == 2 & [spike.onset]' == 1)
% ISI(ind2+1)
% ISI(ind2+2)

ind = cell(burstmax, 1);
ISIordinal = cell(burstmax, burstmax-1);
for i = 2:burstmax
    ind{i} = find([spike.burstsize]' == i & [spike.onset]' == 1);
    for j = 1:i-1
        ISIordinal{i,j} = ISI(ind{i}+j);
    end
end

%% ISI ordinal plot
h.fig1 = figure;
hold on
h.fig1_line = zeros(burstmax, 1);

TF = false(max(burstmax), 1);
markerseries = {'o','^','s','p','v','x','d'}; % seven markers
markercolor = {'none', color};
legendstr = cell(1, max(burstmax));
nudgeleft = nudgeright*(burstmax - 2)/2;


for i = 2:burstmax
    if ~isempty(ISIordinal{i,1})
        TF(i) = true;
        
        switch lower(errorbarmode)
            case 'std'
                h.fig1_line(i) = errorbar((1:i-1) - nudgeleft + nudgeright*(i-2), mean([ISIordinal{i,:}], 1)*1000, ...
                    std([ISIordinal{i,:}], 0, 1)*1000);
            case 'sem'
                h.fig1_line(i) = errorbar((1:i-1) - nudgeleft + nudgeright*(i-2), mean([ISIordinal{i,:}], 1)*1000, ...
                    std([ISIordinal{i,:}], 0, 1)*1000/sqrt(size([ISIordinal{i,:}],1)));
            otherwise
                h.fig1_line(i) = line((1:i-1) - nudgeleft + nudgeright*(i-2), mean([ISIordinal{i,:}], 1)*1000); 
        end
        
        set(h.fig1_line(i),...
            'Color', color, ...
            'Marker', markerseries{rem((i-2),7) + 1},... %Cycle through markers
            'MarkerFaceColor', markercolor{rem(floor((i-2)/7),2) +1}); % alternate face color
        
        if ~isempty(errorwidth)
            child1 = get(h.fig1_line(i), 'Children');
            local_seterrorwidth(child1(2), errorwidth);
        end
        
        legendstr{i} = sprintf('%d', i);
    end
end

xlim([0, burstmax]);
K_XTickLabel(gca, 1:(burstmax-1), 0);
K_YTickLabel(gca, 0:10, 0);
ylim([0 max(ylim(gca))]);
xlabel('ISI ordinal');
ylabel('Intraburst ISI [ms]')
title(name);

% legend
h.fig1_leg = legend(h.fig1_line(TF), legendstr{TF}, 'Location','southeast');
legend('boxoff');
legpos = get( h.fig1_leg, 'Position');
h.fig1_t = text(0, 0, 'Spikes/burst');
set(h.fig1_t, 'Units', 'normalized');
set(h.fig1_t, 'Position', [ legpos(1)*1.05, (legpos(2) + legpos(4))*1.05, 0]); %TODO



%% plot of first ISI in burst
h.fig2 = figure;
hold on 

switch lower(errorbarmode)
    case 'std'
        h.fig2_line = errorbar(2:burstmax, cellfun(@(X) mean(X,1)*1000, ISIordinal(2:burstmax,1)'),...
            cellfun(@(X) std(X,0,1)*1000, ISIordinal(2:burstmax,1)'));
    case 'sem'
        h.fig2_line = errorbar(2:burstmax, cellfun(@(X) mean(X,1)*1000, ISIordinal(2:burstmax,1)'),...
            cellfun(@(X) std(X,0,1)*1000/sqrt(length(X)), ISIordinal(2:burstmax,1)'));
    otherwise
        h.fig2_line = line(2:burstmax, cellfun(@(X) mean(X,1)*1000, ISIordinal(2:burstmax,1)'));  
end

set(h.fig2_line,...
    'Color', color, ...
    'Marker','o');

if ~isempty(errorwidth)
    child2 = get(h.fig2_line, 'Children');
    local_seterrorwidth(child2(2), errorwidth);
end

K_XTickLabel(gca, 2:burstmax, 0);
K_YTickLabel(gca, 0:0.5:10, 1);
ylim('auto');
ylim([0 max(ylim(gca))]);
xlim([1, burstmax+1]);
xlabel('The number of spikes in bursts');
ylabel('The first ISI in bursts [ms]')
title(name);



%% burst stats

% mean intraburst ISI [sec]

LTSstats.intraburstISImean = zeros(size(onset));
for i = 1:length(onset)
    LTSstats.intraburstISImean(i) = mean(ISI(onset(i)+1:offset(i)));
end
LTSstats.intraburstISImeanmean = mean(LTSstats.intraburstISImean);

% mean number of spikes per burst

LTSstats.spikesperburst = [spike([spike.onset] == 1).burstsize]';
LTSstats.spikesperburstmean = mean(LTSstats.spikesperburst);

% number of bursts

LTSstats.n_bursts = length(onset);

% mean duration of LTS bursts [sec]

LTSstats.duration = [spike([spike.offset] == 1).time]' - [spike([spike.onset] == 1).time]';
LTSstats.durationmean = mean(LTSstats.duration);

% mean rate of LTS burst occurence [bursts/sec]
LTSstats.LTSrate = LTSstats.n_bursts/maxtime;

% mean interburst interval
% TODO how to define? onset-offset? or inverse of LTSrate?

LTSstats.name = name;

LTSstats = orderfields(LTSstats);





%% plot time view
h.fig3 = figure;
a1 = axes;
set(a1, 'TickDir', 'out');
zoom xon
pan xon
xlabel('Time [sec]');
set(a1, 'YTick',0.5:2:20.5);
yticklabel = cell(1, 10);
title(name);


% unite
h.fig3_h1 = zeros(length(spike), 1);
for i = 1:length(spike)
    h.fig3_h1(i)=line([spike(i).time, spike(i).time], [0, 1], 'Color',color);
end
h.fig3_h1(i+1) = line([starttime maxtime], [0.5 0.5], 'Color',color);
yticklabel{1} = 'spike';

% LTS
hold on
h.fig3_h2 = zeros(length(onset), 1);
for i=1:length(onset)
    h.fig3_h2(i) = fill([spike(onset(i)).time, spike(offset(i)).time,...
        spike(offset(i)).time, spike(onset(i)).time],...
        [2 2 3 3], color, 'EdgeColor', color); %TODO
end
hold off
zoom xon
pan xon
yticklabel{2} = 'LTS';


% onset
h.fig3_h3 = zeros(length(onset), 1);
for i=1:length(onset)
    h.fig3_h3(i)=line([spike(onset(i)).time, spike(onset(i)).time], [4, 5], 'Color',color);
end
h.fig3_h3(i+1) = line([starttime maxtime], [4.5 4.5], 'Color', color);
yticklabel{3} = 'onset';


% onset of bursts with n spikes

h.fig3_h4 = cell(burstmax+1, 1);
for i = 2:burstmax
    for j = 1:length(onsetLTS_i_spikes{i})
        h.fig3_h4{i} = line([spike(onsetLTS_i_spikes{i}(j)).time,...
            spike(onsetLTS_i_spikes{i}(j)).time],...
            [2+2*i, 3+2*i], 'Color',color);
    end
    h.fig3_h4{burstmax +1, 1} = line([starttime maxtime], [(2.5 +2*i), (2.5 +2*i)], 'Color',color);
    yticklabel{2+i} = ['onset ', num2str(i), ' spikes'];
end

set(a1, 'YTickLabel', yticklabel);
xlim([starttime maxtime]);

%% plot for ISI before spike (X) vs ISI after spike (Y)

h.fig4 = figure;
loglog([spike.ISIbef].*1000, [spike.ISIaft].*1000, 'LineStyle', 'none', 'Marker', 'o', 'Color', color);
xlabel('ISI before spike [ms]');
ylabel('ISI after spike [ms]');
set(gca, 'Box', 'off', 'TickDir', 'out');
title(name);



end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [name, errorbarmode, errorwidth, nudgeright, color] = ...
    local_parse_paramvalpair(name, errorbarmode, errorwidth, nudgeright, color, varargin)

ni = length(varargin); % ni >= 1
DataInputs = 0;
PNVStart = 0; % index of the first parameter in varargin
while DataInputs<ni && PNVStart==0
    nextarg = varargin{DataInputs+1};
    if ischar(nextarg) && isvector(nextarg)
        PNVStart = DataInputs+1;
    else
        DataInputs = DataInputs+1;
    end
end



%%
if PNVStart > 0
    
    for i=PNVStart:2:ni
        % Set each Property Name/Value pair in turn.
        Property = varargin{i};
        if i+1>ni
            error(eid('pvsetInvalid'), 'message')
        else
            Value = varargin{i+1};
        end
        % Perform assignment
        switch lower(Property)
            case 'name'
                %% Assign the value
                if isempty(Value)
                    % Name has been specified
                    name = '';
                elseif ischar(Value) && isrow(Value)
                    name = Value;
                else
                    error(eid('pvsetInvalid:name'), ...
                        'Value for name must be char.')
                end
            
            case 'errorbarmode'
                %% Assign the value
                if ~isempty(Value) && ischar(Value) && isrow(Value) && ...
                        ismember(Value, {'','std', 'sem'})
                    % Name has been specified
                    errorbarmode = Value;
                else
                    error(eid('pvsetInvalid:errorbar'), ...
                        'Value for errorbarmode must be either '''', ''std'', or ''sem''')
                end
            case 'errorwidth'
                %% Assign the value
                if isnumeric(Value)  && isempty(Value) || ...
                        isreal(Value) && Value >= 0 
                    % Name has been specified
                    errorwidth = Value;
                else
                    error(eid('pvsetInvalid:errorwidth'), ...
                        'Value for errorwidth must be empty or 0 or positive real number')
                end    
                
            case 'nudge'
                %% Assign the value
                if ~isempty(Value) && isnumeric(Value) && isscalar(Value) && ...
                        isreal(Value) && Value <= 0.5 && Value >= 0
                    % Name has been specified
                    nudgeright = Value;
                else
                    error(eid('pvsetInvalid:nudge'), ...
                        'Value is not valid for nudge')
                end
            case 'color'
                %% Assign the value
                if ~isempty(Value) && isnumeric(Value) && isscalar(Value) && isreal(Value) && abs(Value) < 0.5
                    % Name has been specified
                    color = Value;
                    
                elseif ~isempty(Value) && ischar(Value) && isrow(Value) && ...
                        ismember(lower(Value), {'y','m','c','r','g','b','w','k'}) ||...
                        ismember(lower(Value), {'yellow','magenta','cyan','red','green','blue','white','black'})
                    color = lower(Value);
                else
                    error(eid('pvsetInvalid:color'), ...
                        'Value is not valid for color')
                end
            otherwise
                error(eid('pvsetInvalid:Param'), 'Param is invalid')
        end % switch
    end % for
    
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


