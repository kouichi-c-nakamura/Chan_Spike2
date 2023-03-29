classdef K_PSTHcorr_test < matlab.unittest.TestCase
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    %
    % close all; clear; clc; testCase = K_PSTHcorr_test; res = testCase.run; disp(res);
    % See also
    % K_PSTHcorr
    
    %TODO need to amend to cover non-plotting options
    
    properties
        basedir
        datafile
    end
    
    methods (Test)
        function psth(testCase)
            % clear;close all;clc; testCase = K_PSTHcorr_test; res = testCase.run('psth'); disp(res)
            
            testCase = findthedatafile(testCase);
            load(testCase.datafile);
            
            target = smalle.values; % only these two chanels required
            trigger = onset.values;
            sInterval = smalle.interval;
            width = 4;% sec
            offset = 2; %sec
            
            mode = 'psth';
            binsize = 0.010;
            
            tic
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', ...
                'TriggerTitle' , 'onset', 'histY', 'rate');
            
            
            %%
            mode = 'psth';
            binsize = 0.010;
            
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'HistY', 'count','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Unit', 's', 'Raster', 'on','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Unit', 'ms', 'Raster', 'on', 'RasterType', 'line','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Unit', 'ms', 'Raster', 'on', 'RasterType', 'line','RasterY', 'time','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'std','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'std','PlotType','hist','Mode',mode);
            
           [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'Histogram', 'off',...
                'HistY', 'rate', 'Mode',mode)
            
            
            
            testCase.verifyEqual(size(out1.SDF_mean), [400 1])
            testCase.verifyEqual(size(out1.SDF_std), [400 1])
            testCase.verifyEqual(size(out1.rasterxmat), [313 137])
            testCase.verifyEqual(size(out1.rasterymat), [313 137])
            
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'Histogram', 'off','Raster','on',...
                'HistY', 'rate', 'Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'Histogram', 'off','Raster','on', 'RasterType', 'line',...
                'HistY', 'rate', 'Mode',mode);            
            
        end
        
        
        function correlograms(testCase)
            % clear;close all;clc; testCase = K_PSTHcorr_test; res = testCase.run('correlograms'); disp(res)
            
            testCase = findthedatafile(testCase);
            load(testCase.datafile);
            
            target = smalle.values; % only these two chanels required
            trigger = onset.values;
            sInterval = smalle.interval;
            width = 4;% sec
            binsize = 0.010;
            offset = 2; %sec
            
            %%
            
            mode = 'crosscorr';
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'HistY', 'count','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Unit', 's', 'Raster', 'on','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Unit', 'ms', 'Raster', 'on', 'RasterType', 'line','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Unit', 'ms', 'Raster', 'on', 'RasterType', 'line','RasterY', 'time','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'std','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate','Mode',mode, 'Histogram', 'off')
            
            testCase.verifyEqual(size(out1.SDF_mean), [400 1])
            testCase.verifyEqual(size(out1.SDF_std), [400 1])
            testCase.verifyEqual(size(out1.rasterxmat), [313 382])
            testCase.verifyEqual(size(out1.rasterymat), [313 382])           
            
            %%
            mode = 'crosscorr';
            binsize = 0.010;
            
            [out1] = K_PSTHcorr(trigger, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Raster', 'on','Mode',mode);
            
            mode = 'autocorr';
            
            binsize = 0.050;
            [out1] = K_PSTHcorr(trigger, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset','Mode',mode); %TODO no title
            
            [out1] = K_PSTHcorr(trigger, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Raster', 'on','Mode',mode);
            
            [out1] = K_PSTHcorr(target, target, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate','Mode',mode); %TODO no title
            
        end
        
        function sdf(testCase)
            % clear;close all;clc; testCase = K_PSTHcorr_test; res = testCase.run('sdf'); disp(res)
            
            testCase = findthedatafile(testCase);
            load(testCase.datafile);
            
            target = smalle.values; % only these two chanels required
            trigger = onset.values;
            sInterval = smalle.interval;
            width = 4;% sec
            binsize = 0.010;
            offset = 2; %sec
            
            %% SDF
            mode = 'psth';
            binsize = 0.001;
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'SDF', 'on','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'SDF', 'on' ,'SDFsigma', 0.01);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'SDF', 'on', 'Unit', 'ms','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate', 'Unit', 's', 'SDF', 'on','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'std', 'SDF', 'on','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'sem', 'SDF', 'on','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'std', 'SDF', 'on', 'Raster', 'on', 'Unit', 'ms','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'std', 'SDF','on', 'SDFsigma', 0.011, 'Raster', 'on', 'Unit', 'ms','Mode',mode);
            
            [out1] = K_PSTHcorr(target, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'Histogram','off',...
                'HistY', 'rate',  'ErrorBar', 'std', 'SDF','off', 'SDFsigma', 0.011, 'Raster', 'off', 'Unit', 'ms','Mode',mode)
            
            testCase.verifyEqual(size(out1.SDF_mean), [4000 1])
            testCase.verifyEqual(size(out1.SDF_std), [4000 1])
            testCase.verifyEqual(size(out1.rasterxmat), [313 137])
            testCase.verifyEqual(size(out1.rasterymat), [313 137])           

            
           
            
            %% SDF for autocorr
            
            mode = 'autocorr';
            binsize = 0.001;
            [out1] = K_PSTHcorr(trigger, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'std', 'Raster', 'on', 'Unit', 'ms','Mode',mode);
            
            mode = 'autocorr';
            binsize = 0.001;
            [out1] = K_PSTHcorr(trigger, trigger, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'std', 'SDF','on','SDFsigma', 0.001, 'Raster', 'on', 'Unit', 'ms','Mode',mode);
            
            %% tset SDF for single sweep
            mode = 'psth';
            
            trigger_  = zeros(size(trigger));
            trigger_( find(trigger, 1, 'first')) = 1;
            binsize = 0.0001;
            
            K_PSTHcorr(target, trigger_, sInterval,...
                width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
                'HistY', 'rate',  'ErrorBar', 'sem', 'SDF','on','SDFsigma', 0.001, 'Raster', 'on', 'Unit', 'ms','Mode',mode);
            
            %% test if an error happens
%             mode = 'psth';
%             
%             binsize = 0.001;
%             clc;profile on
%             % sigma = linspace( 0.0001, 0.05, 100);
%             sigma = rand(100,1) * 0.05;
%             
%             dbstop if error
%             
%             for i = 1:100
%                 
%                 K_PSTHcorr(target, trigger, sInterval,...
%                     width, binsize, offset, 'targettitle' , 'smalle', 'TriggerTitle' , 'onset',...
%                     'HistY', 'rate',  'ErrorBar', 'std', 'SDF','on','SDFsigma', sigma(i), 'Unit', 'ms','Mode',mode); %TODO x axis doesn:t match
%                 close
%                 
%             end
%             profile viewer
            
        end
    end
    
    methods
        function testCase = findthedatafile(testCase)
            startdir = fileparts(which('startup'));
            endind = regexp(startdir,regexptranslate('escape',...
                'Private_Dropbox'),'end');
            if ~isempty(endind)
                testCase.basedir = startdir(1:endind); % platform independent
                clear endind startdir
            else
                error('move to the folder "%s"',fullfile('Kouichi MATLAB data','thalamus'))
            end
            
            testCase.datafile = fullfile(testCase.basedir,'Kouichi MATLAB data',...
                'thalamus','S potentials','HF pauser','PC','SWA',...
                'kjx021i01_i02_spliced.mat');
        end
        
    end
    
end

