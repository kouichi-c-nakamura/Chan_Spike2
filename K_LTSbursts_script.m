clc;clear all;


%% load data
% [filename, path] = uigetfile('*.smr','Select the MATLAB code file',...
%     'D:\PERSONAL\Dropbox\Private_Dropbox\MATLAB\Sorting Merged spikes\kjx021i01_demo.smr');
% 
% path = 'D:\PERSONAL\Dropbox\Private_Dropbox\MATLAB\Sorting Merged spikes\';
% filename = 'kjx021i01_demo.smr';

% path = 'Z:\Work\Spike2 folder\Kouichi for conversion\thalamus\for Cereb Cortex 2012\longer data for phase advancement\VA+VM\';
% filename = 'kjx029b01@180-716.smr';

path = 'Z:\Work\Spike2 folder\Kouichi for conversion\thalamus\for Cereb Cortex 2012\control BG SWA\';
filename = 'kjx006a01@200-300.smr';
fid = fopen([path filename],'r') ;

% [unite17857.time, unite17857.header] = SONGetChannel(fid, 41);
% [LTS.time, LTS.header] = SONGetChannel(fid, 43);
% [onset.time, onset.header] = SONGetChannel(fid, 44);
% 
% % [smalle.time, smalle.header] = SONGetChannel(fid, 25);
% % [ECoG.time, ECoG.header] = SONGetChannel(fid, 2, 'scale');
% % [unit.time, unit.header] = SONGetChannel(fid, 3, 'scale');

chanlist = SONChanList(fid);
tf = strcmpi('unite', {chanlist.title});
unitechan= [chanlist(tf).number];
clear tf

Fs = 17000;
%binsize = 1/sr;

wfchan =2;

% [unite]= K_SONAlignAndBin_2(sr, fid, unitechan, wfchan);
[unite]= K_SONAlignAndBin_3(Fs, fid, unitechan);


sInterval = unite.header.newsampleinterval*1e-6; % in second
% sInterval = 1/sr;

xtime = 1:length(unite.values);
xtime = xtime*sInterval;
maxtime = xtime(end);

maxtime = unite.header.stop;


%% burst detection from spikes
[spike, ISI, onset, offset, starttime, maxtime] = K_LTSburst_detect(unite.values, Fs);






%% use exisiting LTS channel

% import LTS channel
tf = strcmpi('LTS', {chanlist.title});
LTSchan= [chanlist(tf).number];
clear tf
% [LTS]= K_SONAlignAndBin_2(sr, fid, LTSchan, wfchan);

[LTS]= K_SONAlignAndBin_3(Fs, fid, LTSchan);


[spike2, ISI2, onset2, offset2] = K_LTSburst_readLTSchan(unite, LTS, Fs);


%% plot

K_LTSburst_plot(spike, ISI, onset, offset, starttime, maxtime);

K_LTSburst_plot(spike2, ISI2, onset2, offset2, 0, maxtime);

%% start_sec option

[spike3, ISI3, onset3, offset3, starttime3, maxtime3] = K_LTSburst_detect(unite.values, Fs, 'start_sec', 30);
[LTSstats, h] = K_LTSburst_plot(spike3, ISI3, onset3, offset3, starttime3, maxtime3)

%% preburstsilence_ms option

[spike3, ISI3, onset3, offset3, starttime3, maxtime3] = K_LTSburst_detect(unite.values, Fs, 'preburstsilence_ms', 1000);
[LTSstats, h] = K_LTSburst_plot(spike3, ISI3, onset3, offset3, starttime3, maxtime3)

    
%% firstisimax_ms option

[spike3, ISI3, onset3, offset3, starttime3, maxtime3] = K_LTSburst_detect(unite.values, Fs, 'firstisimax_ms', 3);
% ERROR OF OVERLAP

[spike3, ISI3, onset3, offset3, starttime3, maxtime3] = K_LTSburst_detect(unite.values, Fs, 'firstisimax_ms', 7);
[LTSstats, h] = K_LTSburst_plot(spike3, ISI3, onset3, offset3, starttime3, maxtime3)

%% lastISImax_ms option

[spike3, ISI3, onset3, offset3, starttime3, maxtime3] = K_LTSburst_detect(unite.values, Fs, 'lastISImax_ms', 4);
[LTSstats, h] = K_LTSburst_plot(spike3, ISI3, onset3, offset3, starttime3, maxtime3)
% ERROR OF OVERLAP


[spike3, ISI3, onset3, offset3, starttime3, maxtime3] = K_LTSburst_detect(unite.values, Fs, 'lastISImax_ms', 20);
[LTSstats, h] = K_LTSburst_plot(spike3, ISI3, onset3, offset3, starttime3, maxtime3)


