% Spike Density Function
% MATLAB for Neuroscience second edition pp. 319-320

clear;close all;clc;

S = load('Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus\S potentials\HF pauser\PC\SWA\kjx021i01_i02_spliced.mat');



X = S.smalle;

%% SDF

binnedData = X.values;
binWidth = X.interval; % in [sec]
T = (X.start : binWidth : X.start+binWidth*(X.length - 1))'; % in [sec]

sigma = 0.015;                             % SD in [sec] of the kernel = 15 ms

edges = (-3*sigma : binWidth : 3*sigma)';  % Time ranges form -3*SD to 3*SD
kernel = normpdf(edges, 0, sigma);  
kernel = kernel * binWidth;                % multiply by bin width
% to set SDF [1/sec] as probability of spike events for a given period. The
% definite integral of an SDF gives you an estimate of the number of spike
% events during that period.

sdf = conv(binnedData, kernel, 'same');      % convolve spike data with the kernel

%% plot
ind = find(binnedData);

figure;
ax1 = subplot(2,1,1);
plot([T(ind), T(ind)]' , [zeros(length(ind),1), ones(length(ind),1)]', 'b')
ax2 = subplot(2,1,2);
plot(T, sdf, 'r');
ylabel('SDF [1/sec]');

linkaxes([ax1 ax2], 'x')
zoom xon; pan xon;






SDF = WaveformChan(s, Spot.Start, Spot.SRate, 'SDF');

rec = Record({Spot, SDF});
rec.plot;


plot(Spot.time, s, Spot.time,  Spot.Data);
