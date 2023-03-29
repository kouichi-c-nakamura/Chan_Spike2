% K_ISIhist_script

clc;close all;clear all;

load('Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus\S potentials\HF pauser\PC\SWA\kjx021i01_i02_spliced.mat')
% {'IpsiEEG';'LTS';'ME1_LFP';'ME1_Unit';'ans';'onset';'unite';}


target = smalle.values;
trigger = onset.values;
sInterval = smalle.interval;
maxInterval = 0.1;% sec
binsize =     0.0005;
minInterval = 0; %sec

%% OPTIONAL PARAMETER/VAlUE pairs (varargin)
% 'TargetTitle'         any string
% 'PlotType'            'line'   line drawing for PSTH/correlogram
%                       'hist'   histogram for PSTH/correlogram
% 'Unit'                's'      x axis in second (default)
%                       'ms'     x axis in msec



[out1] = K_ISIhist(target, sInterval, maxInterval, binsize, minInterval, 'targettitle' , 'smalle');

[out1] = K_ISIhist(target, sInterval, maxInterval, binsize, minInterval,...
    'targettitle' , 'smalle', 'PlotType', 'hist');
