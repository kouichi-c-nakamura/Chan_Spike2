


clear; close all; clc

srcdir = 'Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus\double EEGs rostrocaudal\6OHDA\swa\Spike2MAT';

cd(srcdir);

load('kjx148a01@0-500.mat');

W2 = WaveformChan(IpsiEEG); %chan 2
W1 = WaveformChan(PostEEG); %chan 1



% [states, h] = W2.detectUPandDOWNwavelet(1.6, 0, 250, 'Doplot', true);
%OK, 25/06/2013, 22:23

[states2, h] = W2.detectUPandDOWNwavelet();
[states1, h] = W1.detectUPandDOWNwavelet();


t = W1.time;

UPstart1 = timestamps2binned(states1.UPstart, 0, t(end), 1000);
UPstart2 = timestamps2binned(states2.UPstart, 0, t(end), 1000);

DOWNstart1 = timestamps2binned(states1.DOWNstart, 0, t(end), 1000);
DOWNstart2 = timestamps2binned(states2.DOWNstart, 0, t(end), 1000);

h1 = K_PSTHcorr('crosscorr', UPstart1, UPstart2, 1/1000, 1, 0.010, 0.5);
set(h1.l1, 'Color', 'r');
% M1 UP precedes S1 UP

h2 = K_PSTHcorr('crosscorr', DOWNstart1, DOWNstart2, 1/1000, 1, 0.010, 0.5);
fig2 = gcf;
copyobj(h2.l1, h1.ax1);
close(fig2);
ylim([0 inf]);
legend('UP start','DOWN start')
xlabel('M2 relative to S1 [sec]')



