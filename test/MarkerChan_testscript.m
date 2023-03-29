%% simple examples
clear;clc;close all;


sr2 = 1000;
e1 = double(logical(poissrnd(30/sr2, 1000, 1)));

ind1 = find(e1);

length(find(e1 ~= 0))

codes  = logical(poissrnd(3/10, length(ind1), 1)) ...
     + logical(poissrnd(2/10, length(ind1), 1)) .*2 ...
          + logical(poissrnd(1/10, length(ind1), 1)) .*3 ;

M = MarkerChan(e1, 0, sr2, codes, 'test1'); % 370 byte

profile on
h = M.plot;
profile viewer



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear;clc;close all;
% 
%  name = 'demo.smr';
% path = 'D:\PERSONAL\Dropbox\Private_Dropbox\Spike sorting\';
% fid = fopen([path, name], 'r');
% 
% list = SONChanList(fid);
% 
% list2 =[{'number', 'title', 'kind'}; ...
%     {list(:).number}', {list(:).title}',{list(:).kind}'];
% openvar('list2');


%% to find a channel by ChanTitle

% ChanTitle = 'probeA11m';
% for i = 1:length(list)
%    TF = strcmpi(ChanTitle, {list.title}); 
% end
% chan = list(TF).number;

% 
% sRateNew = 17000;
% 
% profile on
% [outdata2, timev] = K_SONAlignAndBin_3(sRateNew, fid, 18);
% profile viewer
% 
% 
% mchan = MarkerChan(outdata2.values, 0, sRateNew, outdata2.markers, 'Marker chan1');


%% Spike2 data examples
clear;close all;clc;

cd(fileparts(which('MarkerChan.m')));

S_mark = load('BinFreq0MarkAs1.mat'); % S1.demo_LTSmk
S_binned = load('BinFreq17000MarkAs0.mat'); % S2.demo_LTSmk
S_textmark = load('BinFreq0TMarkAs2.mat'); % S3.demo_textmk

% you need to get start and sRateNew from another binned channel

data = S_binned.demo_LTSmk.values;
start = S_binned.demo_LTSmk.start;
srate = 1/S_binned.demo_LTSmk.interval;
name = S_binned.demo_LTSmk.title;
codes = S_mark.demo_LTSmk.codes;


%% constructor 1
clear mchan
mchan_manual = MarkerChan(data, start, srate, codes, name);
mchan_manual.testProperties;
% OK, 18/02/2014, 15:49

%% constructor 2
clear mchan
mchan = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);
mchan.testProperties;
% OK, 18/02/2014, 15:49

%% constructor 3
clear mchan
mchan_txt = MarkerChan(S_textmark.demo_textmk, S_binned.demo_LTSmk);
mchan_txt.testProperties;
% OK, 18/02/2014, 15:49


%% test methods

profile on
mchan.NSpikes
profile viewer  % 0.032 sec


mchan.MarkerCodes

mchan.MarkerCodes(2,:) = [100, 100, 100, 100]; 
% OK


profile on
spkInfo = mchan.getSpikeInfo
profile viewer  % 2.25 sec --> 0.8 sec --> 0.112 sec


profile on
openvar('spkInfo');
profile viewer % 2 msec, but actually takes 10 sec

%% resample

mchan0 = mchan.resample(1000); %OK 10:39 28/02/2014

figure;
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
mchan.plot(ax1);
mchan0.plot(ax2);
linkaxes([ax1 ax2], 'x');
%OK 8/6/2013, 19:58


%% set.Data, set.MarkerCodes, set.TextMark etc

clc;clear mchan
mchan = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);

mchan.Data(1) = 1; %OK, 11:54, 19/02/2014
mchan.Data(1:3) = [1;1;1]; %OK, 12:08, 19/02/2014

mchan.MarkerCodes(1) = 1; %OK, 11:57, 19/02/2014
mchan.MarkerCodes(1:2) = [10,10]'; %OK, 11:57, 19/02/2014

mchan.TextMark(1) = {'What the fuck are you doing?'}; %OK, 11:57, 19/02/2014
mchan.TextMark(1:2) = {'What the fuck are you doing?';'Breathing.'}; %OK, 11:57, 19/02/2014

mchan.Data = zeros(20,1); %OK, 12:08, 19/02/2014
% discard all MarkerCodes and TextMark

%% set.MarkerFilter, subsasgn

% subsref works fine by default
mchan.MarkerFilter(1:5,:) %OK
mchan.MarkerFilter('value1',:) %OK
mchan.MarkerFilter(1:10,'mask2') %OK


% subsasgn
mchan.MarkerFilter %OK
mchan.MarkerFilter{'value1', 'mask0'} = false %OK, 19:42 28/02/2014

mchan.MarkerFilter{2, 1} = false %OK, 19:42 28/02/2014

mchan.MarkerFilter = [];      %OK, 19:55 28/02/2014
mchan.MarkerFilter = 'show'   %OK, 17:54 3/3/2014
mchan.MarkerFilter(1:5,1) = 'show' %OK, 17:59 3/3/2014

mchan.MarkerFilter = 'hide'   %OK, 17:54 3/3/2014
mchan.MarkerFilter = false(256,4); %OK
mchan.MarkerFilter(2:5,1) = false(4,1);
mchan.MarkerFilter(2:5,1) = [] %OK, 19:58 28/02/2014

mchan.MarkerFilter(2:5,1) = 'hide' % hide subset

mchan.MarkerFilter{1:2, 1} = [true; false] % not allowed

mchan.MarkerFilter(3:5, 1)= [0;0;0]; % OK, 20:10, 28/02/2014 

mchan.MarkerFilter(3:5, 1)= [true;false;true]; % OK, 20:10, 28/02/2014 

% <NOT ALLOWED>
mchan.MarkerFilter{1:2, 1} = [true; false] % not allowed (expected ERROR) 20:06 28/02/2014

mchan.MarkerFilter = [false; false] % not allowed (expected ERROR) 20:06 28/02/2014

mchan.MarkerFilter = dataset(false, 'VarNames', 'mask0', 'ObsNames', 'value1') % not allowed (expected ERROR) 20:06 28/02/2014

mchan.MarkerFilter = false % not allowed (expected ERROR) 20:08 28/02/2014



%% subsasgn

mchan.Data(1) = 0; % OK, 17:31, 3/3/2014
mchan.Data = []; % OK,  17:31, 3/3/2014
mchan.Data = [1; 0; 0]; % OK,  17:31, 3/3/2014


%% vertcat, extractTime

clc;clear mchan
mchan = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);

mchan1 = mchan.extractTime(0,30);
mchan1.plot
%OK 19:53 27/02/2014

mchan.MarkerFilter{'value0', 1} = false;
mchan.plot

mchan.MarkerFilter{'value0', 1} = true;
mchan.MarkerFilter{'value1', 1} = false;
mchan.plot
%OK 28/02/2014

mchan.MarkerFilter = true(256,4);
mchan1 = mchan.extractTime(0,30);
mchan1.plot
% OK

mchan.MarkerFilter{'value1',1} = false;
mchan1f = mchan.extractTime(0,30);
mchan1f.plot
% OK, 11:23, 28/02/2014

mchan2 = mchan.extractTime(30, mchan.MaxTime);
mchan2.plot
% OK 13:37, 28/02/2014

mchan3 = mchan.extractTime(-10, 30); % Not allowed


mchan3 = mchan.extractTime(-10, 30, 'extend');
mchan3.plot
%OK 14:00 28/02/2014

mchan4 = mchan.extractTime(30, mchan.MaxTime + 20, 'extend');
mchan4.plot
%OK 14:00 28/02/2014

% vertcat
mchan5 = [mchan1; mchan2];
mchan5.ChanTitle = 'spliced back';
mchan5.plot
%OK 14:44 28/02/2014



figure;
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
mchan.plot(ax1);
mchan5.plot(ax2);
linkaxes([ax1, ax2], 'x')
% OK 28/02/2014

h1 = mchan.plot;
h2 = mchan5.plot;
copyobj(ax1, h1.l1); %TODO
copyobj(ax1, [h1.l2{1}]); %TODO

copyobj(ax1, get(h1.axh, 'Children'));
copyobj(ax2, get(h2.axh, 'Children'));
