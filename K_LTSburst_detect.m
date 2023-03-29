function [spikeInfo,ISI,onset,offset,starttime,maxtime,LTSdef,tooshort] ...
    = K_LTSburst_detect(events, Fs, varargin)
% [spikeInfo,ISI,onset,offset,starttime,maxtime,LTSdef,tooshort] = ...
%       K_LTSburst_detect(events, Fs)
% [_____] = K_LTSburst_detect(____, 'start_sec', 30)
% [_____] = K_LTSburst_detect(____, 'preburstsilence_ms', 50)
% [_____] = K_LTSburst_detect(____, 'firstISImax_ms', 8)
% [_____] = K_LTSburst_detect(____, 'lastISImax_ms', 15)
%
%
% LTS burst detection
%
% INPUT ARGUMENTS
% unite is a structure including fields:
%   events                binary (0 or 1) vector for spike events
%
%   Fs                    sampling frequency of values
%
% OPTIONAL Parameter/Value pairs
%   'start_sec'           (optional) start time in sec
%
%   'preburstsilence_ms'  (optional) default is 100 ms
%                         Pre-burst ISI must be longer than this.
%
%   'firstISImax_ms'      (optional) default is 5 ms
%                         The first intrabust ISI must be shorter than this.
%
%   'lastISImax_ms'       (optional) default is 10 ms
%                         Intraburst ISIs cannot be longer than this.
%
%
% OUTPUT ARGUMENTS
% spikeInfo              structure contains data for each spike events
%   spikeInfo.point      data point counts
%   spikeInfo.time       time in seconds
%   spikeInfo.ISIbef     ISI before the spike
%   spikeInfo.ISIaft     ISI after the spike
%   spikeInfo.onset      whether the spike is onset of a LTS burst [0 or 1]
%   spikeInfo.offset     whether the spike is offset of a LTS burst [0 or 1]
%   spikeInfo.burstsize  the number of spikes contained in the LTS bursts [0 or integer]
%   spikeInfo.intraburstordinal  the ordial of the spike in the LTS burst
%   spikeInfo.id         Unique serial integer number for each spike
%
% ISI                vector of ISIs
%                    Note: ISI(1) and ISI(end) are shorter than actual ISIs!!!!!
%
%
% onset              onset of LTS bursts in spikeInfo ID
% offset             offset of LTS bursts in spikeInfo ID
% starttime          start of the record in second (identical to 'start_sec' input)
% maxtime            end of the record in second
% LTSdef             LTS defination used for detection
% tooshort           Cell array containing indices of too short (< 1 msec)
%                      ISIs
%
% See Also 
% K_LTSburst_plot, K_LTSburst_readLTSchan, K_LTSburst_groupplot, LTSburst


%% initialize with default values
%%%%%%%%%%%%%%%%%%%%%%%%% initialize with default values
start_sec_default = 0; % in [sec]
preburstsilence_ms_default = 100; % [ms]
firstISImax_ms_default = 5;
lastISImax_ms_default = 10;

%%%%%%%%%%%%%%%%%%%%%%%%


%% parse input arguments

narginchk(2, 10);

p = inputParser;

%vf_events = @(x) isvector(x) && islogical(x) || isnumeric(x) && all(x == 0 | x == 1); % slow
vf_events = @(x) isvector(x) && all(x == 0 | x == 1); % slow

p.addRequired('events', vf_events);

vf_Fs = @(x) isscalar(x) && isnumeric(x) && x > 0;
p.addRequired('Fs', vf_Fs);


p.addParameter('start_sec', start_sec_default, @(x) isscalar(x) && isreal(x));

vfnum = @(x) isscalar(x) && isreal(x) && x >= 0;

p.addParameter('preburstsilence_ms', preburstsilence_ms_default, vfnum);
p.addParameter('firstISImax_ms', firstISImax_ms_default, vfnum);
p.addParameter('lastISImax_ms', lastISImax_ms_default, vfnum);

p.parse(events, Fs, varargin{:});
start_sec = p.Results.start_sec;
preburstsilence_ms = p.Results.preburstsilence_ms;
firstISImax_ms = p.Results.firstISImax_ms;
lastISImax_ms = p.Results.lastISImax_ms;


if isrow(events)
    events = events';
end

%events = full(events);


%% definitions
% ISI before a burst must be longer than 100 ms
% Initial ISI in a burst must be shorter than 5 ms
% ISI longer than 10 ms is not included in a burst and thereby defines end

sInterval = 1/Fs; % in second
maxtime = start_sec + (length(events) - 1) * sInterval;
starttime = start_sec;

LTSdef.preburstsilence_ms = preburstsilence_ms;
LTSdef.firstISImax_ms= firstISImax_ms;
LTSdef.lastISImax_ms = lastISImax_ms;

preburstsilence = preburstsilence_ms/1000;
firstISImax = firstISImax_ms/1000;
lastISImax = lastISImax_ms/1000;

spikeind = find(events);
c = cell([length(spikeind) 1]);
zero = num2cell(zeros(size(c)));

spikeInfo = struct('point', c,...
    'time', c,...
    'ISIbef', c,...
    'ISIaft', c,...
    'onset', zero,...
    'offset',zero,...
    'burstsize',zero,...
    'intraburstordinal',zero,...
    'id',zero);
clear c zero;

for i = 1:length(spikeind)
    spikeInfo(i).point = spikeind(i);
    spikeInfo(i).time = start_sec+(spikeInfo(i).point-1)*1/Fs;
    spikeInfo(i).id = i;
end
clear i

spiketime = [spikeInfo(:).time]';
tooshort = zeros(0,2);


if isempty(spikeInfo)
   
    ISI = []; onset = []; offset = [];
    return
    
end

ISI = [spiketime(1);...
    diff(spiketime);...
    maxtime-spiketime(end)]; % TODO get the length of the file

% disp('Note ISI(1) and ISI(end) are shorter than actual ISIs!!!');
% ISI(i) and ISI(i+1) are before and after spikeInfo(i)

% check the quality of spike sorting with ISI
if any(ISI < 0.001)
    ind = find(ISI < 0.001);
    n_tooshort = length(ind);
    msg = repmat({'The %dth ISI is %f msec < 1 msec\n'}, 1, n_tooshort);
    tooshort = zeros(n_tooshort, 2);
    for i = 1:n_tooshort
        tooshort(i,1) = ind(i); % N th
        tooshort(i,2) = ISI(ind(i))*1000; % X msec
    end
    
    tooshortC = cell(1,numel(tooshort));
    for i = 1:n_tooshort
        tooshortC{i*2-1} = tooshort(i,1);
        tooshortC{i*2} =   tooshort(i,2);
    end
    
    warning off backtrace
    warning(eid('ISItooshort'),...
        [msg{:}], tooshortC{:});
    warning on backtrace
end



for i = 1:length(spikeind)
    spikeInfo(i).ISIbef = ISI(i);
    spikeInfo(i).ISIaft = ISI(i+1);
end

%% preburstISI = find(ISI > preburstsilence);

%TODO exclude overlapping bursts???

onsetind = find(ISI(1:end-1) > preburstsilence & ISI(2:end) < firstISImax);
offsetind=zeros(size(onsetind));

for i = 1:length(onsetind)
    j =1;
    while ISI(onsetind(i)+j) <= lastISImax
        j = j+1;
        if onsetind(i)+j > length(spikeInfo)
            break;
        end
    end
    offsetind(i) = onsetind(i)+j-1;
    if offsetind(i) == onsetind(i)
        onsetind(i) = NaN;
        offsetind(i) = NaN;
    end
end
clear i j

%% remove NaN
onset = reshape(onsetind, numel(onsetind), 1);
onset = onsetind(~isnan(onset));
offset = reshape(offsetind, numel(offsetind), 1);
offset = offsetind(~isnan(offset));

%TODO the last element of offset can be the end of the record
if any(offset > length(spikeInfo))
    
    offset(end) = offset(end) -1; % exclude the MaxTime
    
    if onset(end) == offset(end)
       onset(end) = [];
       offset(end) = [];
    end
    
end


%% warning for overlapping bursts

if length(onset) > 1 && length(offset) > 1
    assert(all(offset(1:end-1) - onset(2:end) < 0),...
        eid('overlappingbursts'),...
        'Of %d bursts detected, %d are overlapping each other.', ...
        length(onset), nnz(offset(1:end-1) - onset(2:end) > 0));
end


% [[spikeInfo(onset).time]',[spikeInfo(offset).time]'];

%% ISI ordinal

for i=1:length(onset)
    spikeInfo(onset(i)).onset = 1;
    spikeInfo(offset(i)).offset = 1; 
    
    n = offset(i)-onset(i)+1; % spikes in burst
    for j = 1:n
        spikeInfo(onset(i)+j-1).intraburstordinal = j;
        spikeInfo(onset(i)+j-1).burstsize = n;
    end
end
clear i j n


% onset = find([spikeInfo.onset]');
% offset = find([spikeInfo.offset]');


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