%% *MarkerChan demo*
% 

Fs = 1000;
rng('default');
events = double(logical(poissrnd(30/Fs, 1000, 1)));

ind1 = find(events);
codes  = logical(poissrnd(3/10, length(ind1), 1)) ...
    + logical(poissrnd(2/10, length(ind1), 1)) .*2 ...
    + logical(poissrnd(1/10, length(ind1), 1)) .*3 

M = MarkerChan(events, 0, Fs, codes, 'test1'); % 370 byte
h = M.plot;
M.testProperties;
methods(M)
%% 
% save() and load()

testCase = MarkerChan_test;
f = matlab.unittest.fixtures.WorkingFolderFixture;
testCase.applyFixture(f);

save M M
S = load('M')

S.M.testProperties;
clear testCase
%% 
% *Spike2 data*

path = (fileparts(which('MarkerChan.m')));

S_mark = load(fullfile(path, 'BinFreq0MarkAs1.mat')); % S1.demo_LTSmk
S_binned = load(fullfile(path, 'BinFreq17000MarkAs0.mat')); % S2.demo_LTSmk
S_textmark = load(fullfile(path, 'BinFreq0TMarkAs2.mat')); % S3.demo_textmk

%% you need to get start and sRateNew from another binned channel

data = S_binned.demo_LTSmk.values;
start = S_binned.demo_LTSmk.start;
srate = 1/S_binned.demo_LTSmk.interval;
name = S_binned.demo_LTSmk.title;
codes = S_mark.demo_LTSmk.codes;

M1 = MarkerChan(data, start, srate, codes, name);
M1.testProperties;
M1.plot

% Marker channel
M2 = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);
M2.testProperties;
M2.plot
copyobj(gca,figure)
xlim([42.5 43])

% TextMark channel
M3 = MarkerChan(S_textmark.demo_textmk, S_binned.demo_LTSmk);
M3.testProperties;
M3.plot
%% 
% *Methods*

path = (fileparts(which('MarkerChan.m')));

S_mark = load(fullfile(path, 'BinFreq0MarkAs1.mat')); % S1.demo_LTSmk
S_binned = load(fullfile(path, 'BinFreq17000MarkAs0.mat')); % S2.demo_LTSmk

%% you need to get start and sRateNew from another binned channel

% Marker channel
M = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);

%% MarkerCodes subsasgn
M.MarkerCodes(2,:) = [100, 100, 100, 100];

%% getSpikeInfo
spikeinfo = M.getSpikeInfo;
openvar('spikeinfo');
% keyboard

%% resample

M0 = M.resample(1000); %OK 10:39 28/02/2014
figh = figure;
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
M.plot(ax1);
M0.plot(ax2);
linkaxes([ax1 ax2], 'x');

copyobj(figh.Children,figure)
figh2 = gcf;
linkaxes(findobj(figh2,'Type','axes'), 'x');
xlim([0 4])

path = (fileparts(which('MarkerChan.m')));

S_mark = load(fullfile(path, 'BinFreq0MarkAs1.mat')); % S1.demo_LTSmk
S_binned = load(fullfile(path, 'BinFreq17000MarkAs0.mat')); % S2.demo_LTSmk
%%


%% you need to get start and sRateNew from another binned channel

% Marker channel
M = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);

M.Data(1) = 1;
M.Data(1)

M.Data(1:3) % should be [1;0;0]
M.Data(1:3) = [1;1;1];
M.Data(1:3) % should be [1;1;1]

M.MarkerCodes(1:3,1) % should be uint8([0;0;0])
% Addition of spikes pads 0 MarkerCodes accordingly
M.MarkerCodes(1) = 5;
M.MarkerCodes(1,1) % should be uint8(5);

M.MarkerCodes(1:2,1) % should be uint8([5,0])
M.MarkerCodes(1:2,1) = [10,10]';
M.MarkerCodes(1:2,1) % should be uint8([10,10])

M.TextMark{1} % should be ''
M.TextMark(1) = {'What the fuck are you doing?'};
M.TextMark{1} % should be 'What the fuck are you doing?'

M.TextMark{2} % should be ''
M.TextMark(1:2) = {'What the fuck are you doing!?';'Breathing.'};
M.TextMark{1} % should be 'What the fuck are you doing!?'
M.TextMark{2} % should be 'Breathing.'
M.plot

length(M.Data) % should be 1700000
M.Data = zeros(20,1);
length(M.Data) % should be 20
M.Data % should be zeros(20,1)

% MarkerFilter

Fs = 1000;
rng('default');
events = double(logical(poissrnd(30/Fs, 1000, 1)));

ind1 = find(events);
codes  = logical(poissrnd(3/10, length(ind1), 1)) ...
    + logical(poissrnd(2/10, length(ind1), 1)) .*2 ...
    + logical(poissrnd(1/10, length(ind1), 1)) .*3 

M = MarkerChan(events, 0, Fs, codes, 'test1'); % 370 byte


M.NSpikes
M.getSpikeInfo
M.plot


M.MarkerFilter(2,1)= false;
M.MarkerFilter{'value3',1} = false;

head(M.MarkerFilter)

M.getSpikeInfo
M.plot

M.getSpikeInfoAll


M.MarkerFilter= [];
M.NSpikes
M.getSpikeInfo
M.plot