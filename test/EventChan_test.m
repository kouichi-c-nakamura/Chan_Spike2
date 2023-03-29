classdef EventChan_test < matlab.unittest.TestCase
    %EventChan_test < matlab.unittest.TestCase
    %  clear;close all; clc; testCase = EventChan_test; res =testCase.run ; disp(res);
    %
    %
    % 12 Feb 2015 15:51
    % Totals:
    %    10 Passed, 0 Failed, 0 Incomplete.
    %    11.3709 seconds testing time.
    
    properties
        testmatname = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_double.mat');
        basedir
        kjx021i01_i02_spliced
    end
    
    methods (Test)
        function testEventChanSimpleData(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testEventChanSimpleData') ; disp(res);
            
            sr2 = 1000;
            rng('default') % To get reproducible results
            e = double(logical(poissrnd(10/sr2, 1000, 1)));
            
            E = EventChan(e, 0, sr2, 'test1'); % 370 byte
            E.plot;
            
            testCase.verifyEqual(E.NSpikes , 5);
            testCase.verifyEqual(E.SRate , 1000);
            testCase.verifyEqual(E.ChanNumber , 0);
            testCase.verifyEqual(E.Data , e);
            
            
            B = E.chan2ts; %8893 byte
            EE = EventChan.ts2chan(B);
            EE.testProperties;
            
            testCase.verifyEqual(class(B) , 'timeseries');
            testCase.verifyEqual(class(EE) , 'EventChan');
            testCase.verifyEqual(EE.Data , e);
            
            currentdir = pwd;
            cd(fileparts(which('EventChan.m')));
            save('E','E')
            S = load('E');
            S.E.testProperties;
            testCase.verifyEqual(E,S.E)
            delete('E.mat')
            cd(currentdir)
        end
        
        function  testEventChanFromMatDoubleEachArgs(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testEventChanFromMatDoubleEachArgs') ; disp(res);
                        
            load(testCase.testmatname);
            
            E = EventChan(onset.values, 0, 1/onset.interval, 'onset'); %double
            E.plot;
            E.testProperties;
            
            testCase.verifyEqual(E.NSpikes , 7);
            testCase.verifyEqual(E.Length , 340000);
            testCase.verifyEqual(E.ChanNumber , 0);
            testCase.verifyEqual(E.Data , onset.values);
            
        end
        
        function  testEventChanFromMatDoubleStruct(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testEventChanFromMatDoubleStruct') ; disp(res);
            
            load(testCase.testmatname);

            
            E = EventChan(onset); %double
            E.plot;
            E.testProperties;
            
            testCase.verifyEqual(E.NSpikes , 7);
            testCase.verifyEqual(E.Length , 340000);
            testCase.verifyEqual(E.ChanNumber , 0);
            testCase.verifyEqual(E.Data , onset.values);
            
        end
        
        
        function  testEventChanFromMatDoubleWaveform(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testEventChanFromMatDoubleWaveform') ; disp(res);
            
            load(testCase.testmatname);

            % Wrong type of data
            testCase.verifyError(@() EventChan(EEG), 'K:Chan:EventChan:EventChan:struct:invalid');
            
        end
        
        function  test_eq(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testEventChanFromMatDoubleStruct') ; disp(res);
            
            load(testCase.testmatname);

            
            E = EventChan(onset); %double
            E.testProperties;
            
            testCase.verifyEqual(E.NSpikes , 7);
            testCase.verifyEqual(E.Length , 340000);
            testCase.verifyEqual(E.ChanNumber , 0);
            testCase.verifyEqual(E.Data , onset.values);
            
            E2 = E;
            testCase.verifyEqual(E , E2);

            E2.Data(1) = 1;
            testCase.verifyNotEqual(E , E2);

            E2.Data(1) = 0;
            testCase.verifyEqual(E , E2);

            E2.Header.comment = 'hoge';
            testCase.verifyNotEqual(E , E2);
            
            
        end
        
        
        function  testMethod_chan2ts_ts2chan(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testMethod_chan2ts_ts2chan') ; disp(res);
            
            load(testCase.testmatname);

            E = EventChan(onset); %double
            Ets = E.chan2ts;
            EE = EventChan.ts2chan(Ets);
            
            testCase.verifyTrue(isa(Ets, 'timeseries'));
            testCase.verifyEqual(E.Data, Ets.Data);
            testCase.verifyEqual(E, EE);

            
        end
        
        function  testMethod_plotISIbefaft(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testMethod_plotISIbefaft') ; disp(res);
            
            load(testCase.testmatname);

            E = EventChan(probeA07e); %double
            [h, figh] = E.plotISIbefaft;
            
            testCase.verifyTrue(ishandle(h));
            testCase.verifyTrue(ishandle(figh));
            
        end
        
        function  testMethod_plotCorr(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testMethod_plotCorr') ; disp(res);
            
            load(testCase.testmatname);

            E = EventChan(probeA07e); %double
            
            width = 2; binsize = 0.002; offset = 1;
            h1 = E.plotCorr(E, width, binsize, offset, 'HistY', 'rate', ...
                'Raster', 'on','RasterType','dot', 'Unit', 'ms', 'PlotType', 'hist');
            
            h2 = K_PSTHcorr( E.Data, E.Data, E.SInterval, width, binsize, offset, ...
                'Mode','autocorr','HistY', 'rate', 'Raster','on',...
                'RasterType','dot', 'Unit', 'ms', 'PlotType', 'hist');
            
            testCase.verifyTrue(isstruct(h1));
            testCase.verifyEqual(h1.binCounts, h2.binCounts);
            testCase.verifyEqual(h1.sweepXT, h2.sweepXT);
            testCase.verifyEqual(h1.psthRate_mean, h2.psthRate_mean);
            testCase.verifyEqual(h1.psthRate_std, h2.psthRate_std);
            testCase.verifyEqual(h1.psthRate_sem, h2.psthRate_sem);
            testCase.verifyEqual(h1.sweeps_Tok, h2.sweeps_Tok);
            testCase.verifyEqual(h1.sweepn, h2.sweepn);
            
        end
        
        function  testMethod_getSpikeInfo(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testMethod_getSpikeInfo') ; disp(res);
            
            load(testCase.testmatname);

            E = EventChan(probeA07e); %double
            
            spikeInfo = E.getSpikeInfo;
            disp(spikeInfo);
            
            testCase.verifyTrue(isa(spikeInfo, 'table'));
            testCase.verifyEqual(size(spikeInfo), [18 6]);
            
        end
        
        function  testMethod_resample(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testMethod_resample') ; disp(res);
            
            load(testCase.testmatname);

            E = EventChan(probeA07e); %double
            
            E1000 = E.resample(1000);
            E1000.testProperties;
            
            testCase.verifyEqual(E1000.Length, 20000);
            testCase.verifyEqual(E1000.SRate, 1000);
            testCase.verifyEqual(E1000.NSpikes, E.NSpikes);
            testCase.verifyEqual(E1000.ChanTitle, E.ChanTitle);
            
        end
        
          function testMethod_extractTime(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testMethod_extractTime') ; disp(res);
            
            load(testCase.testmatname);

            E = EventChan(probeA07e); %double
                        
            E5_15 = E.extractTime(5,15);
            E5_15.testProperties;
            
            testCase.verifyEqual(E5_15.Start, 5);
            testCase.verifyEqual(E5_15.MaxTime, 15);
            testCase.verifyEqual(E5_15.Length, 170001);
            
            E5_15.plot

            
            E_m5_5 = E.extractTime(-5,5,'extend');
            E_m5_5.testProperties;
            
            testCase.verifyEqual(E_m5_5.Start, -5);
            testCase.verifyEqual(E_m5_5.MaxTime, 5);
            testCase.verifyEqual(E_m5_5.Length, 170001);
          
            E_m5_5.plot
            
            
            E_15_25 = E.extractTime(15,25,'extend');
            E_15_25.testProperties;
            
            testCase.verifyEqual(E_15_25.Start, 15);
            testCase.verifyEqual(E_15_25.MaxTime, 25);
            testCase.verifyEqual(E_15_25.Length, 170001);
          
            E_15_25.plot
            
           
            
        end      
        
        function  testMethod_plotPhaseHist(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testMethod_plotPhaseHist') ; disp(res);
            %TODO 
            
            load(testCase.testmatname);

            E = EventChan(probeA07e); %double
            
            W = WaveformChan(EEG.values, 0, 1/EEG.interval, 'IpsiEEG');
            
            out2 = E.plotPhaseHist(W, 'slow');
            %OK 03-Nov-2016 12:28:32
            
            out3 = E.plotPhaseHist(W,'slow','plotECDF', true);
            
            out4 = E.plotPhaseHist(W,'slow','plotLinear', false);
            
            out5 = E.plotPhaseHist(W,'slow','plotCirc', false);
            
        end
        
        function  testMethod_plotTriggered(testCase)
            % clear;close all; clc; testCase = EventChan_test; res =testCase.run('testMethod_plotTriggered') ; disp(res);
            
            testCase = findkjx021i01datafile(testCase);

            S = load(testCase.kjx021i01_i02_spliced);

            Eunite = EventChan(S.unite); %double
            Eonset = EventChan(S.onset); %double
            Esmalle = EventChan(S.smalle); %double

            Wunit = WaveformChan(S.ME1_Unit);
            
            width = 1;
            offset = 0.5;
            Esmalle.plotTriggered(Eonset,width,offset)
            
            disp('under construction')
            
%             out1 = E.plotPhaseHist(W);
%             %OK, 8/6/2013, 22:27
%             
%             out2 = E.plotPhaseHist(W, 'Preset', 'slow');
%             %OK, 8/6/2013, 22:36
%             
%             out3 = E.plotPhaseHist(W,'plotECDF', true);
%             %OK, 8/6/2013, 22:38
%             
%             out4 = E.plotPhaseHist(W,'plotLinear', false);
%             out5 = E.plotPhaseHist(W,'plotCirc', false);
%             %OK, 8/6/2013, 22:38
            
        end
        
    end
    
    methods
        function testCase = findkjx021i01datafile(testCase)
            startdir = fileparts(which('startup'));
            endind = regexp(startdir,regexptranslate('escape',...
                'Private_Dropbox'),'end');
            if ~isempty(endind)
                testCase.basedir = startdir(1:endind); % platform independent
                clear endind startdir
            else
                error('move to the folder "%s"',fullfile('Kouichi MATLAB data','thalamus'))
            end
            
            testCase.kjx021i01_i02_spliced = fullfile(testCase.basedir,'Kouichi MATLAB data',...
                'thalamus','S potentials','HF pauser','PC','SWA',...
                'kjx021i01_i02_spliced.mat');
        end
        
    end
    
end

