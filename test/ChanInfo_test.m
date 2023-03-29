classdef ChanInfo_test < matlab.unittest.TestCase
    % ChanInfo_test < matlab.unittest.TestCase
    %
    % clear;close all;clc; testCase = ChanInfo_test; disp(testCase.run);
    %
    %
    % 22 Jan 2015
    % Totals:
    %    3 Passed, 1 Failed, 0 Incomplete.
    %    3.0026 seconds testing time.
    
    properties
        
    end
    
    methods (Test)
        function testNoInputArg(testCase)
            % clear;close all;clc; testCase = ChanInfo_test; disp(testCase.run('testNoInputArg'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
  
            obj = ChanInfo();
            obj.testProperties;            
            
            testCase.verifyEqual(obj.ChanTitle,  '');
            testCase.verifyEqual(obj.DataUnit,  '');
            testCase.verifyEqual(obj.Start, 0);
            testCase.verifyEqual(obj.SRate, 1);
            testCase.verifyEqual(obj.Path, '');
            testCase.verifyEqual(obj.ChanNumber, 0);
            testCase.verifyEqual(obj.Length, 0);
            testCase.verifyEqual(obj.SInterval, 1);
            testCase.verifyEqual(obj.MaxTime, []);
            testCase.verifyEqual(obj.TimeUnit, 'second');
            testCase.verifyEqual(obj.ChanStructVarName, '');
            testCase.verifyEqual(obj.PathRef, '');
            testCase.verifyEqual(obj.ChanTitleRef, '');
            testCase.verifyEqual(obj.ChanStructVarNameRef, '');
            testCase.verifyEqual(obj.Bytes, []);
            testCase.verifyEqual(obj.LastModDate, '');
    
            testCase.verifyError(@() obj.loadChan(), 'K:ChanInfo:loadChan:Path:empty');

        end
        
        function testEventWithPath(testCase)
            % clear;close all;clc; testCase = ChanInfo_test; disp(testCase.run('testEventWithPath'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.TestSuite;
            
            matfilepath = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');
            
            % onset
            % LTS
            % LTSmk
            % probeA07e
            % EEG
            
            obj = ChanInfo(matfilepath, 'onset');
            obj.testProperties;
            
            chan = obj.loadChan();
            chan.plot;
            chan.testProperties;
            
            testCase.verifyEqual(obj.SRate, 17000);
            testCase.verifyEqual(obj.Length, 340000);
            testCase.verifyEqual(obj.Bytes, 2042840);
            disp(obj.LastModDate);
            
            testCase.verifyThat(chan.FiringRate, IsEqualTo(0.350001029414792, 'Within', AbsoluteTolerance(1.0e-8)));
            testCase.verifyThat(chan.Stats.duration, IsEqualTo(19.999941176470589, 'Within', AbsoluteTolerance(1.0e-8)));
            testCase.verifyThat(chan.Stats.ISI_mean, IsEqualTo(2.797284313725490, 'Within', AbsoluteTolerance(1.0e-8)));
            
            %test for eq
            obj2 = obj;
            testCase.verifyTrue(obj == obj2);
            
            obj2.ChanTitle = 'hoge';
%             testCase.verifyTrue(obj ~= obj2); % ne has not defined

            
        end
        
        function testWaveformWithPath (testCase)
            % clear;close all;clc; testCase = ChanInfo_test; disp(testCase.run('testWaveformWithPath'));
            
            matfilepath = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');
            
            % onset
            % LTS
            % LTSmk
            % probeA07e
            % EEG
            
            obj = ChanInfo(matfilepath, 'EEG');
            obj.testProperties;
            
            chan = obj.loadChan();
            chan.plot;
            chan.testProperties;
            
            testCase.verifyEqual(obj.SRate, 17000);
            testCase.verifyEqual(obj.Length, 340000);
            testCase.verifyEqual(obj.Bytes, 2042840);
            disp(obj.LastModDate);
        end
        
        function testMarkerWithPath (testCase)
            % clear;close all;clc; testCase = ChanInfo_test; disp(testCase.run('testMarkerWithPath'));
            
            matfilepathMk = fullfile(fileparts(which('MarkerChan.m')), 'BinFreq0MarkAs1.mat');
            matfilepathBin = fullfile(fileparts(which('MarkerChan.m')), 'BinFreq17000MarkAs0.mat');
            
            obj = ChanInfo(matfilepathMk, 'demo_LTSmk', matfilepathBin, 'demo_LTSmk');
            obj.testProperties;
            
            chan = obj.loadChan();
            chan.plot;
            chan.testProperties;
            
            testCase.verifyEqual(obj.SRate, 17000);
            testCase.verifyEqual(obj.Length, 1700000);
            testCase.verifyEqual(obj.Bytes, 1824);
            testCase.verifyEqual(obj.ChanStructVarNameRef,  'demo_LTSmk');
            testCase.verifyEqual(obj.LastModDate, '2015-03-04 04:48:01.000'); % this is dependent on local time!
            
        end
        
        function saveload (testCase)
            % clear;close all;clc; testCase = ChanInfo_test; disp(testCase.run('saveload'));
            
            matfilepath = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');

            matfilepathMk = fullfile(fileparts(which('MarkerChan.m')), 'BinFreq0MarkAs1.mat');
            matfilepathBin = fullfile(fileparts(which('MarkerChan.m')), 'BinFreq17000MarkAs0.mat');
            
            thisfolder = fileparts(which('ChanInfo_test'));
            cd(thisfolder);
            
            obj0 = ChanInfo();
            
            save('obj0.mat','obj0')
            S = load('obj0.mat');
            
            testCase.verifyEqual(obj0,S.obj0);
            delete('obj0.mat');

            %%
            
            obj0 = ChanInfo(matfilepath, 'onset');
            save('obj0.mat','obj0')
            S = load('obj0.mat');
            
            testCase.verifyEqual(obj0,S.obj0);
            delete('obj0.mat');
            
            %%
            
            obj0 = ChanInfo(matfilepath, 'EEG');
            save('obj0.mat','obj0')
            S = load('obj0.mat');
            
            testCase.verifyEqual(obj0,S.obj0);
            delete('obj0.mat');
            
            %%
            
            obj0 = ChanInfo(matfilepathMk, 'demo_LTSmk', matfilepathBin, 'demo_LTSmk');
            save('obj0.mat','obj0')
            S = load('obj0.mat');
            
            testCase.verifyEqual(obj0,S.obj0);
            delete('obj0.mat');
            
        end

        
    end
    
end

