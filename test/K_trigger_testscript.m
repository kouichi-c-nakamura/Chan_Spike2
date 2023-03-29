% K_trigger_test.m
%
%function [ outdata ] = K_trigger( data, trigger, varargin)
% [ outdata ] = K_trigger( data, trigger, width, offset, newFs)
%
% [ outdata ] = K_trigger( {rec1, rec2, ...}, {MetaEventChan1, MetaEventChan2,...}, ...)
% [ outdata ] = K_trigger( {rec1, rec2, ...}, {timestamps1, timestamps2,...}, ...)
%
% [ outdata ] = K_trigger( {Chan1, Chan2, ...}, {MetaEventChan1, MetaEventChan2,...}, ...)
% [ outdata ] = K_trigger( {Chan1, Chan2, ...}, {timestamps1, timestamps2,...}, ...)
%
% [ outdata ] = K_trigger( rec1,, MetaEventChan1, ...)
% [ outdata ] = K_trigger( rec1, timestamps1, ...)
%
% [ outdata ] = K_trigger( Chan1, MetaEventChan1, ...)
% [ outdata ] = K_trigger( Chan1, timestamps1, ...)


%% prepare data

close all;clear;clc;
home = 'Z:\Dropbox\Private_Dropbox\MATLAB\Kouichi\classes\Chan' ;

thefolder = 'Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus GABA infusion\kjx160\';
cd(thefolder);

listing = dir('*.mat');
files ={listing.name}';
names = regexprep(files, '\.mat$', '');

for i = 1:length(files)
    
   load(files{i}); % load into S

   fldn = fieldnames(S);
   
   ind_EEG = strcmpi('IpsiEEG', fldn);
   ind_GABA = strcmpi('GABA', fldn);
   
   if nnz(ind_EEG) ~= 1 || nnz(ind_GABA) ~= 1 
      error('K:findrec','Failed to find rec'); 
   end
   
   EEG = WaveformChan(S.(fldn{ind_EEG}));
   GABA = MarkerChan(S.(fldn{ind_GABA}), S.(fldn{ind_EEG}));
   
   EEGr = EEG.resample(1024);
   GABAr = GABA.resample(1024);

   data.(names{i}) = Record({EEGr, GABAr}, 'Name', names{i});
   
   clear GABA EEG GABAr EEGr ind_EEG ind_GABA fldn

end
clear i

kjx160data = [data.kjx160h01; data.kjx160h02; data.kjx160h03; data.kjx160h05];


%% = 

triggered = kjx160data.GABA.MarkerFilter{'value0','mask0'} = false;

triggered = K_trigger(kjx160data, kjx160data.GABA ); % OK 13:15, 04/03/2014

triggered = K_trigger(kjx160data, kjx160data.GABA, 900, 200, 1024); %OK, 16:19, 04/03/2014


arrayfun(@(i) triggered{i}.Start, 1:length(triggered))
arrayfun(@(i) triggered{i}.Header.originalstart, 1:length(triggered))
arrayfun(@(i) triggered{i}.Header.triggeroffset, 1:length(triggered))







