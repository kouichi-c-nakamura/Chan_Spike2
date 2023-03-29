classdef ChanInfo_6OHDA_KCN_test < matlab.unittest.TestCase
    % ChanInfo_6OHDA_KCN_test < matlab.unittest.TestCase
    %
    % usage example
    % clear;close all; clc;  mytest = ChanInfo_6OHDA_KCN_test; disp(run(mytest))
    %
    % 22 Jan 2015
    % Totals:
    %    2 Passed, 0 Failed, 0 Incomplete.
    %    4.6827 seconds testing time.
    
    properties
        path6OHDA_KCN = fullfile(fileparts(which('K_PSTHcorr.m')), '6OHDA_KCN')
    end
    
    methods(Test)
        
        function testChanInfo_6OHDA_KCN_event_withPath(testCase)
            addpath(testCase.path6OHDA_KCN);
            
            matfilepath = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');
            
            chaninfo_e = ChanInfo_6OHDA_KCN(matfilepath, 'onset');
            
            try
                
                ME1 = [];
                chaninfo_e.testProperties;
            catch ME1
                throw(ME1);
            end
            
            testCase.verifyEmpty(ME1);
            
        end
        
        function testChanInfo_6OHDA_KCN_event_loadChan(testCase)
            % clear;close all; clc;  mytest = ChanInfo_6OHDA_KCN_test; disp(run(mytest, 'testChanInfo_6OHDA_KCN_event_loadChan'))
            
            try
                ME1 = [];
                addpath(testCase.path6OHDA_KCN);
                
                matfilepath = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');
                
                chaninfo_e = ChanInfo_6OHDA_KCN(matfilepath, 'onset');
                
                chaninfo_e.testProperties;
                
                chan_e = chaninfo_e.loadChan();
                chan_e.plot;
                chan_e.testProperties;
            catch ME1
                throw(ME1);
            end
            
            testCase.verifyEmpty(ME1);
            
            
        end
        
        
        % clear;close all;clc;
        %
        % addpath('Z:\Dropbox\Private_Dropbox\MATLAB\Kouichi\classes\Chan\6OHDA_KCN');
        %
        % matfilepath = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');
        %
        % % onset
        % % LTS
        % % LTSmk
        % % probeA07e
        % % EEG
        %
        %
        % chaninfo_e = ChanInfo_6OHDA_KCN(matfilepath, 'onset');
        % % OK, 2014/06/10 22:10
        %
        % chaninfo_e.testProperties;
        %
        % chan_e = chaninfo_e.loadChan()
        % chan_e.plot;
        % chan_e.testProperties;
        % OK, 2014/06/10 22:41
    end
end