% waveform_stroeInInt16_script

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

% [unite, timev]= K_SONAlignAndBin_3(sr, fid, unitechan);

[eegw, timev]= K_SONAlignAndBin_3(sr, fid, eegwchan);

[unitw]= K_SONAlignAndBin_3(sr, fid, unitechan);

[onset]= K_SONAlignAndBin_3(sr, fid, onsetechan);


ts_eegw = timeseries(eegw.values, timev, 'Name', 'IpsiEEG');


%% job

offset = mean([max(ts_eegw.Data), min(ts_eegw.Data)]);
Mi = double(intmax('int16'));
Mx = max(ts_eegw.Data - offset);

W2int16 = @(x) int16((x-offset)./Mx.*Mi);
int16toW = @(x) double(x)./Mi.*Mx + offset;

tic
eegw_int16 = W2int16(ts_eegw.Data);
toc % 13 msec

tic
eeg_re = int16toW(eegw_int16);
toc % 17 msec

plot(ts_eegw.Data)
hold on
plot(eeg_re, 'r')
hold off
zoom xon; pan xon;

% working well, 30 April 2013