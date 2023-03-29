%% testing extractime

clear;close all;clc;

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


%%


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


rec1 =Record({unite_chan,eegw_chan, LTS_chan}, 'Name', 'recname');
rec1.plot

profile on
LTS_chan.Stats
profile viewer

%% extractTime

unite_chan2 = unite_chan.extractTime(0, 10);
unite_chan2.plot %OK

unite_chan3 = unite_chan.extractTime(10, 30);
unite_chan3.plot %OK

unite_chan3.Start
find(unite_chan3.Data)


eegw_chan2 = eegw_chan.extractTime(0, 10);
eegw_chan2.plot %OK

eegw_chan3 = eegw_chan.extractTime(10, 30);
eegw_chan3.plot %OK


LTS_chan2 = LTS_chan.extractTime(0, 10);
LTS_chan2.plot %OK  8/5/2013 21:56

LTS_chan3 = LTS_chan.extractTime(10, 30);
LTS_chan3.plot %OK  8/5/2013 21:56


rec2 = rec1.extractTime(0 , 10);
rec2.plot %OK

rec3 = rec1.extractTime(10 , 30);
rec3.plot %OK 9/5/2013

%% extractTime padding with NaN

unite_ex1 = unite_chan.extractTime(-10, 10, 'extend');
unite_ex1.plot %OK

unite_ex2 = unite_chan.extractTime(80, 120, 'extend');
unite_ex2.plot %OK

eegw_ex1 = eegw_chan.extractTime(-10, 10, 'extend');
eegw_ex1.plot %OK

eegw_ex2 = eegw_chan.extractTime(80, 120, 'extend');
eegw_ex2.plot %OK





%% vertcat

unite_chan4 = [unite_chan2; unite_chan3];
unite_chan4.plot

eegw_chan4 = [eegw_chan2; eegw_chan3];
eegw_chan4.plot

LTS_chan4 = [LTS_chan2; LTS_chan3];
LTS_chan4.plot

rec4 = [rec2; rec3];
rec4.plot %OK 9/5/2013 15:48




