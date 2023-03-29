classdef RecordInfo_test < matlab.unittest.TestCase
    %RecordInfo_test < matlab.unittest.TestCase
    %   clear;close all; clc; testCase = RecordInfo_test; res =testCase.run ; disp(res);
    %
    % See also
    % RecordInfo, Record_test, Record
    %
    % 3 Feb 2015
    % Totals:
    %    5 Passed, 0 Failed, 0 Incomplete.
    %    1.1383 seconds testing time.
    
    properties
    end
    
    methods (Test)
        function testSimpleData_EventChanAndWaveformChan(testCase)
            % clear;close all; clc; testCase = RecordInfo_test; res =testCase.run('testSimpleData_EventChanAndWaveformChan') ; disp(res);
            
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            
            sr = 1024;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            % e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            % E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            obj = RecordInfo({E, W});
            obj.testProperties;
            
            testCase.verifyEqual(obj.RecordTitle, '');
            
            clear chaninfos
            
            obj = RecordInfo({E, W}, 'Name', 'test 1');
            obj.testProperties;
            
            testCase.verifyEqual(obj.RecordTitle, 'test 1');
            testCase.verifyEqual(obj.SRate, 1024);
            testCase.verifyEqual(obj.Length, 1000);
            testCase.verifyThat(obj.SInterval, ...
                IsEqualTo(9.765625000000000e-04, ...
                'Within', RelativeTolerance(2*eps)));
            testCase.verifyThat(obj.MaxTime, ...
                IsEqualTo(0.975585937500000, ...
                'Within', RelativeTolerance(2*eps)));
            testCase.verifyThat(obj.Duration, ...
                IsEqualTo(0.975585937500000, ...
                'Within', RelativeTolerance(2*eps)));
            
            currentdir = pwd;
            cd(fileparts(which('RecordInfo.m')));
            save('obj','obj')
            S = load('obj');
            S.obj.testProperties;
            testCase.verifyEqual(obj,S.obj)
            delete('obj.mat')
            cd(currentdir)
        end
        
        function testNoInputArg(testCase)
            % clear;close all; clc; testCase = RecordInfo_test; res =testCase.run('testNoInputArg') ; disp(res);
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            
            obj = RecordInfo();
            obj.testProperties;
            
            testCase.verifyEqual(obj.RecordTitle,  '');
            testCase.verifyEqual(obj.Paths, {});
            testCase.verifyEqual(obj.Start, 0);
            testCase.verifyEqual(obj.SRate, 1);
            testCase.verifyEqual(obj.Length, 0);
            testCase.verifyEqual(obj.SInterval, 1);
            testCase.verifyEqual(obj.PathRefs,  {});
            testCase.verifyEqual(obj.TimeUnit,  'mV');
            testCase.verifyEqual(obj.MaxTime, []); 
            testCase.verifyEqual(obj.Duration, []);
            
        end
        
        %% addChan
        function test_addChan(testCase)
            % clear;close all; clc; testCase = RecordInfo_test; res =testCase.run('test_addChan') ; disp(res);
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            
            sr = 1024;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            obj = RecordInfo({E, W});
            
            obj.addChan(E2);
            obj.testProperties;

%             obj.removeChan('Event2');
%             obj.testProperties;
%             
%             obj = RecordInfo({E, W}, 'Name', 'test 1');
%             obj.testProperties;
            
%             testCase.verifyEqual(obj.RecordTitle, 'test 1');
%             testCase.verifyEqual(obj.SRate, 1024);
%             testCase.verifyEqual(obj.Length, 1000);
%             testCase.verifyThat(obj.SInterval, ...
%                 IsEqualTo(9.765625000000000e-04, ...
%                 'Within', RelativeTolerance(2*eps)));
%             testCase.verifyThat(obj.MaxTime, ...
%                 IsEqualTo(0.975585937500000, ...
%                 'Within', RelativeTolerance(2*eps)));
%             testCase.verifyThat(obj.Duration, ...
%                 IsEqualTo(0.975585937500000, ...
%                 'Within', RelativeTolerance(2*eps)));
            
            
        end
        
        function test_removeChan(testCase)
            % clear;close all;clc; testCase = RecordInfo_test; disp(run(testCase, 'test_removeChan'));
            
            sr = 1024;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            Info1 = RecordInfo({E, W, E2});
            
            Info2 = Info1.removeChan('testWF');
            testCase.verifyEqual(length(Info2.ChanInfos), 2);
            testCase.verifyEqual(Info2.ChanTitles, {'test Event';'Event2'}); 
            clear list2
            
            Info2 = Info1.removeChan('testWF');
            testCase.verifyEqual(length(Info2.ChanInfos), 2);
            clear list2
  
            Info2 = Info1.removeChan('testWF');
            Info2.testProperties;
            testCase.verifyEqual(length(Info2.ChanInfos), 2);
            testCase.verifyEqual(Info2.ChanTitles, {'test Event'; 'Event2'});
            clear list2            

            Info2 = Info1.removeChan([]);
            testCase.verifyEqual(Info2, Info1);           

            testCase.verifyError(@() Info1.removeChan(5), ...
                'K:FileList:removeChan:delChan:invalid');  
            
            testCase.verifyError(@() Info1.removeChan({'asdfa','asdfa';'asdfa','asdfa'}), ...
                'K:FileList:removeChan:delChan:invalid');  
            
            testCase.verifyError(@() Info1.removeChan('abcde'), ...
                'K:FileList:removeChan:delChan:notincluded');

        end
        
        function test_matfilename(testCase)
            % clear;close all;clc; testCase = RecordInfo_test; disp(testCase.run('test_matfilename'));
            
            
            pathstr1 = fileparts(which('WaveformChan.m'));
            
            matname1 = 'kjx127a01@0-20_double.mat';
            
            chsinf1 = RecordInfo(fullfile(pathstr1, matname1));
            testCase.verifyEqual(chsinf1.ChanTitles(), {'onset';'LTS';'LTSmk';'probeA07e';'EEG'});
            
            matname2 = 'kjx127a01@0-20_single.mat';
            
            chsinf2 = Record(fullfile(pathstr1, matname2));
            testCase.verifyEqual(chsinf2.ChanTitles(), {'onset';'LTS';'LTSmk';'probeA07e';'EEG'});
            
            matname3 = 'kjx127a01@0-20_int16.mat';
            
            chsinf3 = Record(fullfile(pathstr1, matname3));
            testCase.verifyEqual(chsinf3.ChanTitles(), {'onset';'LTS';'LTSmk';'probeA07e';'EEG'});
            
            pathstr2 = fileparts(which('MarkerChan.m'));
            
            matname4 = 'markerchan_demodata.mat';
            
            chsinf4 = Record(fullfile(pathstr2, matname4));
            testCase.verifyEqual(chsinf4.ChanTitles(), {'LTSmarker';'LTSbinned';'LTStextmark'});
            
            matname5 = 'BinFreq0MarkAs1.mat';
            
            testCase.verifyError(@() Record(fullfile(pathstr2, matname5)), ...
                'K:Record:matfileinput:marker:noref'); 
            
        end
        
        
    end
    
end

