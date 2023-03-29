%% simple examples
clear;close all;clc;

sr = 1000;
e = double(logical(poissrnd(10/sr, 1000, 1)));
E = EventChan(e, 0, sr, 'test Event'); % 370 byte

e2 = double(logical(poissrnd(50/sr, 1000, 1)));
E2 = EventChan(e2, 0, sr, 'Event2');


w = randn(1000, 1);
W = WaveformChan(w, 0, sr, 'testWF');
W.DataUnit = 'mV';

tsE = E.chan2ts;
tsW = W.chan2ts;

% tsc = tscollection({tsE, tsW});
rec = Record({E, W});
rec.testProperties;
rec.RecordInfo_

rec.summaryDataset;

rec2 = rec.addchan(E2);
rec2.plot;


rec3 = rec2.removechan('Event2');
rec3.plot;

rec4 = rec.removechan({'test Event', 'testWF'});
%OK 2014/06/07 16:51


% you can create empty Record
rec0 = Record

% then add a Chan obj
rec0.addchan(E)

% you can create empty Record with Name
rec00 = Record('Name', 'test')



m= ?Record;
plist = m.PropertyList;
{plist(:).RecordTitle}'


%% subsref for properties

rec.plot
rec.SRate %OK 14/02/2014 16:45
rec.MaxTime %OK 14/02/2014 16:45
rec.MaxTime(1) %OK 14/02/2014 16:45
rec(1) %OK 14/02/2014 16:47  equal to rec.Chans(1)
rec(:) %OK 14/02/2014 17:42  equal to rec.Chans(:)
rec(1).ChanTitle %ERROR 14/02/2014 17:42  equal to rec.Chans(1).ChanTitle

rec{2} %OK 14/02/2014 16:47
rec.('testWF') %OK 14/02/2014 16:48
rec.testWF %OK ... this may have conflicts with prop names 14/02/2014 16:48

rec.testWF.ChanTitle %OK   14/02/2014 16:56
rec.('testWF').ChanTitle(1) %OK!!! 14/02/2014 17:02
rec.testWF.ChanTitle(1) %OK 14/02/2014 17:02 

rec{1}.SRate  %OK!!! 14/02/2014 17:08 
rec{1}.SRate(1)  %OK!!! 14/02/2014 17:08
rec{1}.ChanTitle(1)  %OK!!! 14/02/2014 17:08

rec{1}.Data(1:5) %OK 14/02/2014 18:00

rec.Chans  %OK 14/02/2014 17:49

rec.Chans{1} % TODO 29/05/2014 used to be OK
rec.Chans{1:2}  %TODO              14/02/2014 17:49
rec.Chans{:}  %TODO                14/02/2014 17:49
% http://www.mathworks.com/matlabcentral/answers/57562-subsref-overload-has-fewer-outputs-than-expected-on-cell-attribute



%% subsref for methods

rec.testWF.plot %OK 14/02/2014 17:06
rec.('test Event').resample(100) %OK!!! 14/02/2014 17:16
rec.testWF.extractTime(0, 0.5) %OK 14/02/2014 17:06
rec{2}.plot %OK 14/02/2014 17:06
rec{2}.extractTime(0, 0.5) %OK 14/02/2014 17:06





%% subsasgn test
%TODO

tsc = tscollection({tsE, tsW}); % OK
tsc.testWF.Data(1:100) = ones(100, 1) % OK

clear rec
rec = Record({E, W});
rec.testWF.Data(1:100) = ones(100, 1) % OK 14/02/2014 21:35

clear rec
rec = Record({E, W});
rec.testWF.ChanTitle = 'hoge' % OK 14/02/2014 22:13

clear rec
rec = Record({E, W});
rec.ChanTitles = [] % expected ERROR 14/02/2014 22:13

clear rec
rec = Record({E, W});
rec.Start = 20 %OK 14/02/2014 22:43

clear rec
rec = Record({E, W}, 'Name','hogehogehoge');
rec.RecordTitle(1) = 'H' %OK 14/02/2014 22:49

clear rec
rec = Record({E, W}, 'Name','hogehogehoge');
rec.RecordTitle(1:4) = 'HOGE' %OK 14/02/2014 22:43



rec.('testWF').ChanTitle = 'hello' %TODO NOT YET IMPLEMENTED


 
keyboard;

%% examples of Spike2 derived data
clear;close all;clc;

home = fileparts(which('Record_test.m'));
path = 'Z:\Work\Spike2 folder\Kouichi for conversion\thalamus\for Cereb Cortex 2012\control BG SWA\';
filename = 'kjx006a01@200-300.smr';
fid = fopen([path filename],'r') ;


chanlist = SONChanList(fid);

list =[{'number', 'title', 'kind'}; ...
    {chanlist(:).number}', {chanlist(:).title}',{chanlist(:).kind}'];
openvar('list');


tf = strcmpi('unite', {chanlist.title});
unitechan= [chanlist(tf).number];
clear tf

tf = strcmpi('IpsiEEG', {chanlist.title});
eegwchan= [chanlist(tf).number];
clear tf

tf = strcmpi('ME1 Unit', {chanlist.title});
unitwchan= [chanlist(tf).number];
clear tf

tf = strcmpi('onset', {chanlist.title});
onsetechan= [chanlist(tf).number];
clear tf


sr = 17000;

[unite, timev]= K_SONAlignAndBin_3(sr, fid, unitechan);

% timev  13600000 bytes = 

[eegw]= K_SONAlignAndBin_3(sr, fid, eegwchan);

[unitw]= K_SONAlignAndBin_3(sr, fid, unitwchan);

[onset]= K_SONAlignAndBin_3(sr, fid, onsetechan);

[LTS]= K_SONAlignAndBin_3(sr, fid, 8);

% compress data
unite.values = sparse(unite.values);
onset.values = sparse(onset.values);
LTS.values = sparse(LTS.values);
save(fullfile(home, '@Record','kjx006a01@200-300.mat'), 'eegw', 'unite','unitw','onset','LTS');

%%
clear;close all;clc;

home = fileparts(which('Record_test.m'));
load(fullfile(home, '@Record','kjx006a01@200-300.mat'));

%%
sr = 17000;

unite_chan = EventChan(double(unite.values), 0, sr, 'unite'); % 2530 bytes
onset_chan = EventChan(double(onset.values), 0, sr, 'onset'); % 2530 bytes
unitw_chan = WaveformChan(unitw.values, 0, sr, 'unitw'); % 2530 bytes
unitw_chan.DataUnit = 'mV';
eegw_chan = WaveformChan(eegw.values, 0, sr, 'eegw'); % 2530 bytes
eegw_chan.DataUnit = 'mV';

LTS_chan = MarkerChan(LTS.values, 0, sr, 0, 'LTSm');
ts = LTS_chan.TimeStamps; 
codes = repmat([1; 0], length(ts)/2, 1);
LTS_chan.MarkerCodes = codes;
LTS_chan = setMarkerName(LTS_chan, 0,1, 'onset');
LTS_chan = setMarkerName(LTS_chan, 1,1, 'offset');
LTS_chan.plot


rec = Record({unite_chan, onset_chan, unitw_chan, eegw_chan});
rec.plot;

%% .addchan
rec2 = addchan(rec, LTS_chan);
rec2.plot

%% .vertcat
rec4 = rec2.extractTime(0,70);
rec5 = rec2.extractTime(0,50);

rec6 = vertcat(rec4, rec5);
rec6.plot
