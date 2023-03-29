%% K_folder_mat2sparse_test

% The data for test is quite big, so you may not able to keep them around.
% what you need is paired .mat files for waveform/event and marker/textmark
% data, that are exported from Spike2 with ExportAsMat.s2s (Version 1.1).
% The .mat file for marker/textmark has suffix "*_mk.mat".

clear;close all;clc;


% thefolder = 'Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus GABA infusion\kjx160';
thefolder = 'Z:\Dropbox\Private_Dropbox\MATLAB\Andy\test\mat1';

listing = dir(fullfile(thefolder, '*.mat'));
mnamesall = {listing.name}';

cd(thefolder);

list = K_folder_mat2sparse(thefolder, fullfile(thefolder, 'out'));
% Worked 26/01/014, @21:24
keyboard

%% delete when source and dest are the same

% save originals to "COPY"
cd(thefolder);
for i=1:length(mnamesall)
    copyfile(mnamesall{i}, fullfile('COPY', mnamesall{i}));
end

list2 = K_folder_mat2sparse(thefolder, thefolder);
% should delete the originals
% Worked 26/01/014, @21:58
keyboard

%% unmatched files for waveform/event vs marker/textmark

% delete .mat files in "thefolder"
cd(thefolder);
listing = dir(fullfile(thefolder, '*.mat'));
tobedeleted = {listing.name}';

for i = 1:length(tobedeleted)
    delete(tobedeleted{i});
end

% recover the original .mat fils from "COPY"
cd(thefolder);
listing = dir(fullfile(thefolder, 'COPY\*.mat'));
mnamesall = {listing.name}';
for i=1:length(mnamesall)
    copyfile(fullfile('COPY', mnamesall{i}), mnamesall{i});
end

% prepare unmatched files 
delete(mnamesall{1});
delete(mnamesall{4});


list3 = K_folder_mat2sparse(thefolder, thefolder);
% worked 26/01/2014 @22:22







