function [spike, ISI, onset, offset] = K_LTSburst_readLTSchan(unite, LTS, sr)

%% import LTS channel .. for testing

% path = 'Z:\Work\Spike2 folder\Kouichi for conversion\thalamus\for Cereb Cortex 2012\control BG SWA\';
% filename = 'kjx006a01@200-300.smr';
% fid = fopen([path filename],'r') ;
% chanlist = SONChanList(fid);
% tf = strcmpi('unite', {chanlist.title});
% unitechan= [chanlist(tf).number];
% clear tf
% 
% sr = 17000;
% wfchan =2;
% [unite.values, unite.header, unite.time]= K_SONAlignAndBin(sr, fid, unitechan, wfchan);
%
% tf = strcmpi('LTS', {chanlist.title});
% LTSchan= [chanlist(tf).number];
% clear tf
% [LTS.values, LTS.header, LTS.time]= K_SONAlignAndBin(sr, fid, LTSchan, wfchan);
%

%% parse input arguments


narginchk(3, 3);


if ~isstruct(unite)
    error(eid('unite:invalid'),'unite must be a structure');
else
    if ~isfield(unite, 'values') || ~ isvector(unite.values) || ...
            min(unite.values) ~= 0 || max(unite.values) ~= 1
        error(eid('unitevalues:invalid'),...
            'unite.values must be a vector of binary data.');      
    end
     if ~isfield(unite, 'start') || ~ isscalar(unite.start) 
        error(eid('unitestart:invalid'),...
            'unite.start must be a scalar (usually ~0).');      
    end   
end

if ~isstruct(LTS)
    error(eid('unite:invalid'),'unite must be a structure');
else
    if ~isfield(unite, 'values') || ~ isvector(unite.values) || ...
            min(unite.values) ~= 0 || max(unite.values) ~= 1
        error(eid('unitevalues:invalid'),...
            'unite.values must be a vector of binary data.');      
    end  
end

if ~isscalar(sr) || ~isnumeric(sr) || sr <= 0
    error(eid('sr:invalid'),...
        'sr must be a positive scalar')
end




%% 
sInterval = 1/sr; % in second
xtime = 1:length(unite.values);
xtime = xtime*sInterval;
maxtime = xtime(end);

spikeind = find(unite.values);
c = cell([length(spikeind) 1]);
zero = num2cell(zeros(size(c)));

spike = struct('point', c,...
'time', c,...
'ISIbef', c,...
'ISIaft', c,...
'onset', zero,...
'offset',zero,...
'burstsize',zero,...
'intraburstordinal',zero);
clear c zero;

for i = 1:length(spikeind)
    spike(i).point = spikeind(i);
    spike(i).time = unite.header.start+(spike(i).point-1)*1/sr;
    spike(i).id = i;
end
clear i

spiketime = [spike(:).time]';

ISI = [spiketime(1);...
    diff(spiketime);...
    maxtime-spiketime(end)]; % TODO get the length of the file
% Note ISI(1) and ISI(end) are shorter than real ISIs.
% ISI(i) and ISI(i+1) are before and after spike(i)

for i = 1:length(spikeind)
    spike(i).ISIbef = ISI(i);
    spike(i).ISIaft = ISI(i+1);
end


LTSind = find(LTS.values);
onset_pt = LTSind(1:2:end-1);
offset_pt = LTSind(2:2:end);


onset = zeros(size(onset_pt));
offset = zeros(size(offset_pt));


for i = 1:length(onset)
    onset(i) = spike([spike.point]' == onset_pt(i)).id;
    spike(onset(i)).onset = 1;
    
    offset(i) = spike([spike.point]' == offset_pt(i)).id;
    spike(offset(i)).offset = 1;
end

for i = 1:length(onset)    
    n = offset(i)-onset(i)+1; % spikes in burst
    for j = 1:n
        spike(onset(i)+j-1).intraburstordinal = j;
        spike(onset(i)+j-1).burstsize = n;
    end
end
clear i j n


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