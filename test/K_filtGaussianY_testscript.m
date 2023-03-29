% K_filtGaussianY_test

clear;close all;clc;
cd(fileparts(which('WaveformChan.m')));

S = load('kjx127a01@0-20_double.mat');

wfeeg = WaveformChan(S.EEG); 
evt = EventChan(S.probeA07e); 

clear S;

wfeeg.plot;

T = wfeeg.time;

size = 1700; % in points
sigma = 200; % in points

yy = K_filtGaussianY(wfeeg.Data, size, sigma);
plot(T, yy, 'r', T, wfeeg.Data, 'b');
zoom xon; pan xon;

yyy = K_filtGaussianY_sec(wfeeg.Data, 0.2, 0.05, wfeeg.SRate, true);
figure;
plot(T, yyy, 'r', T, wfeeg.Data, 'b');
zoom xon; pan xon;





