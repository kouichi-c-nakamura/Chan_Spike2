%% load example data

clc;close all;clear all;

load('Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus\S potentials\HF pauser\PC\SWA\kjx021i01_i02_spliced.mat')
% {'IpsiEEG';'LTS';'ME1_LFP';'ME1_Unit';'ans';'onset';'unite';}


target = smalle.values;
trigger = onset.values;
sInterval = smalle.interval;
width = 4;% sec
binsize = 0.010;
offset = 2; %sec


%% OPTIONAL PARAMETER/VAlUE paiers (varargin)
% 'TargetTitle'         any string
% 'TtriggerTitle'       any string
% 'Yaxis'               'count'  counts as Y axis
%                       'rate'   firing rate as Y axis
% 'Unit'                's'      x axis in second (default)
%                       'ms'     x axis in msec
% 'ErrorBar'            'none'   (default)
%                       'std'    error bar as STD
%                       'sem'    error bar as SEM
% 'Raster'              'none'   (default)
%                       'dot'    raster plot with dots
%                       'line'   raster plot with vertical lines
% 'RasterY'             'sweeps' sweeps as Y of raster (default)
%                       'time'   time as Y axis of raster


% 29 April 2013, Harrogate
% compared double, sparse double and int8 computation for psth/correl
% int8 was by far the fastest of all.
% sparse double may still be useful when memory usage is critical
% sparse double was by far the slowest.

mode = 'psth';
binsize = 0.010;

tic
[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate');
toc %0.505 sec


% tic
% [out1] = K_PSTHcorrel_double(mode, target, trigger, sInterval,...
%     width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
%     'Yaxis', 'rate');
% toc
% tic
% [out2] = K_PSTHcorrel_int8(mode, target, trigger, sInterval,...
%     width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
%     'Yaxis', 'rate');
% toc
% [out3] = K_PSTHcorrel_sparse(mode, target, trigger, sInterval,...
%     width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
%     'Yaxis', 'rate');
% toc

%%

mode = 'psth';
binsize = 0.010;


[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'Yaxis', 'count');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Unit', 's', 'Raster', 'dot');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Unit', 'ms', 'Raster', 'line');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Unit', 'ms', 'Raster', 'line','RasterY', 'time');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'std');

%%
mode = 'crosscorr';

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'Yaxis', 'count');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Unit', 's', 'Raster', 'dot');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Unit', 'ms', 'Raster', 'line');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Unit', 'ms', 'Raster', 'line','RasterY', 'time');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'std');

%%
mode = 'crosscorr';
tic
[out1] = K_PSTHcorr(mode, trigger, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Raster', 'dot');
toc

mode = 'autocorr';
tic
[out1] = K_PSTHcorr(mode, trigger, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Raster', 'dot');
toc



tic
[out1] = K_PSTHcorr(mode, target, target, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate');
toc


% 24 sec

%% SDF
mode = 'psth';
binsize = 0.001;

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'SDF', 'auto');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'SDF', 0.01);

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'SDF', 'auto', 'Unit', 'ms');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate', 'Unit', 's', 'SDF', 'auto');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'std', 'SDF', 'auto');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'sem', 'SDF', 'auto');

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'std', 'SDF', 'auto', 'Raster', 'dot', 'Unit', 'ms'); 

[out1] = K_PSTHcorr(mode, target, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'std', 'SDF', 0.011, 'Raster', 'dot', 'Unit', 'ms');

%% SDF for autocorr

mode = 'autocorr';
binsize = 0.001;
[out1] = K_PSTHcorr(mode, trigger, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'std', 'Raster', 'dot', 'Unit', 'ms');

mode = 'autocorr';
binsize = 0.001;
[out1] = K_PSTHcorr(mode, trigger, trigger, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'std', 'SDF', 0.001, 'Raster', 'dot', 'Unit', 'ms');

%% tset SDF fir single sweep
mode = 'psth';

trigger_  = zeros(size(trigger));
trigger_( find(trigger, 1, 'first')) = 1;
binsize = 0.0001;

K_PSTHcorr(mode, target, trigger_, sInterval,...
    width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
    'Yaxis', 'rate',  'ErrorBar', 'sem', 'SDF', 0.001, 'Raster', 'dot', 'Unit', 'ms');

%% test if an error happens
mode = 'psth';

binsize = 0.001;
clc;profile on
% sigma = linspace( 0.0001, 0.05, 100);
sigma = rand(100,1) * 0.05;

dbstop if error

for i = 1:100
    
    K_PSTHcorr(mode, target, trigger, sInterval,...
        width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
        'Yaxis', 'rate',  'ErrorBar', 'std', 'SDF', sigma(i), 'Unit', 'ms'); %TODO x axis doesn:t match
    close
    
end
profile viewer




