clear;close all;clc;

cd(fileparts(which('EventChan_demo_script.m')));
path = '..\@WaveformChan\';
cd(path);
load('kjx127a01@0-20_double.mat');
evch = EventChan(onset.values, 0, 1/onset.interval, 'onset'); %double
evch.plot;%this should show Spike2 like view of spike events.
openvar('evch'); % Is it blank (= error)?
evch

% evch = 
% 
%   EventChan with properties:
% 
%            Data: [340000x1 double]
%             ISI: [8x1 double]
%     InstantRate: [6x1 double]
%      TimeStamps: [7x1 double]
%      firingRate: 0.3500
%         NSpikes: 7
%           Stats: [1x1 struct]
%            Name: 'onset'
%        DataUnit: ''
%           start: 0
%           SRate: 17000
%          Header: []
%            Time: [340000x1 double]
%          Length: 340000
%       sInterval: 5.8824e-05
%         maxtime: 19.9999
%        TimeUnit: 'second'


cd(fileparts(which('WaveformChan.m')));
load('kjx127a01@0-20_double.mat');
wfeeg = WaveformChan(EEG.values, 0, 1/EEG.interval, 'EEG'); %double
wfeeg.plot;%this should show Spike2 like view of waveform data.
openvar('wfeeg'); % Is it blank (= error)?
wfeeg

% wfeeg = 
% 
%   WaveformChan with properties:
% 
%             Data: [340000x1 double]
%     DataInt16max: 0.3903
%     DataInt16min: -0.3975
%            scale: 1.2021e-05
%           offset: -0.0036
%             Name: 'EEG'
%         DataUnit: 'mV'
%            start: 0
%            SRate: 17000
%           Header: []
%             Time: [340000x1 double]
%           Length: 340000
%        sInterval: 5.8824e-05
%          maxtime: 19.9999
%         TimeUnit: 'second'