clear;close all;clc;


%%
% path = 'Z:\Work\Spike2 folder\Kouichi for conversion\thalamus\for Cereb Cortex 2012\control BG SWA\';
% filename = 'kjx006a01@200-300.smr';
% fid = fopen([path filename],'r') ;
% 
% 
% chanlist = SONChanList(fid);
% 
% list =[{'number', 'title', 'kind'}; ...
%     {chanlist(:).number}', {chanlist(:).title}',{chanlist(:).kind}'];
% openvar('list');
% 
% 
% tf = strcmpi('unite', {chanlist.title});
% unitechan= [chanlist(tf).number];
% clear tf
% 
% tf = strcmpi('IpsiEEG', {chanlist.title});
% eegwchan= [chanlist(tf).number];
% clear tf
% 
% tf = strcmpi('ME1 Unit', {chanlist.title});
% unitwchan= [chanlist(tf).number];
% clear tf
% 
% tf = strcmpi('onset', {chanlist.title});
% onsetechan= [chanlist(tf).number];
% clear tf
% 
% 
% sr = 17000;
% 
% [unite, timev]= K_SONAlignAndBin_3(sr, fid, unitechan);
% 
% % timev  13600000 bytes = 
% 
% [eegw]= K_SONAlignAndBin_3(sr, fid, eegwchan);
% 
% [unitw]= K_SONAlignAndBin_3(sr, fid, unitwchan);
% 
% [onset]= K_SONAlignAndBin_3(sr, fid, onsetechan);

keyboard


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% S potential containinig data
load('Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus\S potentials\HF pauser\PC\SWA\kjx021i01_i02_spliced.mat');
sr = 1/unite.interval;



unite_chan = EventChan(double(unite.values), 0, sr, 'unite'); % 98958496 --> 29570 bytes


onset_chan = EventChan(double(onset.values), 0, sr, 'onset'); % 2530 bytes
smalle_chan = EventChan(double(smalle.values), 0, sr, 'smalle'); % 2530 bytes

unitw_chan = WaveformChan(ME1_Unit.values, 0, sr, 'unitw'); % 2530 bytes
unitw_chan.DataUnit = 'mV';
LFPw_chan =  WaveformChan(ME1_LFP.values, 0, sr, 'LFPw'); % 2530 bytes
unitw_chan.DataUnit = 'mV';
eegw_chan = WaveformChan(IpsiEEG.values, 0, sr, 'eegw'); % 2530 bytes
eegw_chan.DataUnit = 'mV';

ds = struct2dataset(whos, 'ReadObsNames','name');
fprintf('unite is compressed by %.1f-fold into an EventChan object\n', ds.bytes('unite')/ds.bytes('unite_chan'));
fprintf('smalle is compressed by %.1f-fold into an EventChan object\n', ds.bytes('smalle')/ds.bytes('smalle_chan'));
fprintf('IpsiEEG is compressed by %.1f-fold into an WaveformChan object\n', ds.bytes('IpsiEEG')/ds.bytes('eegw_chan'));

rec = Record({unite_chan, onset_chan, unitw_chan, eegw_chan});
rec = addchan(rec, smalle_chan);

profile on
h1 = rec.plot; %TODO
profile viewer

profile on
h2 = rec.plot('eegw','unitw','unite','onset','smalle');
profile viewer

profile on
rec.Chans{2}.Length
profile viewer %2 msec


profile on
rec.Chans{2}.MaxTime
profile viewer % 2 msec


rec2 = removechan(rec, 'smalle');
rec2.plot

h2.axh
