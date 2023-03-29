classdef FileList_test < matlab.unittest.TestCase
    %FileList_test < matlab.unittest.TestCase
    %
    % clear;close all;clc; test1 = FileList_test; disp(test1.run);
    %
    % 3 Feb 2015
    % Totals:
    %    16 Passed, 0 Failed, 0 Incomplete.
    %    25.0529 seconds testing time.
    
    properties
    end
    
    methods (Test)
        
        %% FileList()
        function testSimpleCase(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'testSimpleCase'));
            
            sr = 1024;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            chaninfo1 = RecordInfo({E, W});
            chaninfo1.testProperties;
            
            list1 = FileList({chaninfo1});
            list1.testProperties;
            
            verifyClass(testCase, list1.List{1}, 'RecordInfo');

            
        end
        
        function testSimpleCaseWithName(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'testSimpleCaseWithName'));

            
            sr = 1024;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            chaninfo1 = RecordInfo({E, W});
            chaninfo1.testProperties;
            
            list1 = FileList({chaninfo1}, 'Name', 'list 1'); %OK, 2014/06/08, 16:49
            list1.testProperties;
            
            verifyClass(testCase, list1.List{1}, 'RecordInfo');
            testCase.verifyEqual(list1.ListName, 'list 1');
            
        end
        
        function testNoInput(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'testNoInput'));
            
            list1 = FileList();
            list1.testProperties;
            
            verifyEmpty(testCase, list1.List);
            testCase.verifyEqual(list1.ListName, '');
            
        end
        
        function testNoInputWithName(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'testNoInputWithName'));
            
            list1 = FileList( 'Name', 'list 1'); %OK, 2014/06/08, 16:49
            list1.testProperties;
            
            verifyEmpty(testCase, list1.List);
            testCase.verifyEqual(list1.ListName, 'list 1');
            
        end
        
        %% saveSummaryXlsx()
        function test_saveSummaryXlsx(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_saveSummaryXlsx'));
            %
            % Passed on 3/2/2015
            % Totals:
            %    1 Passed, 0 Failed, 0 Incomplete.
            %    5.458 seconds testing time.
            
            % profile on
            
            
            sr = 1024;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            chaninfo1 = RecordInfo({E, W});
            
            list1 = FileList({chaninfo1}, 'Name', 'list 1'); %OK, 2014/06/08, 16:49
            list1.Comment = 'hoge';
            
            path1 = fileparts(which('FileList_test.m'));
            listing = dir(path1);
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, 'summary\.xlsx')));
            xlsx = fullfile(path1,'summary.xlsx');
            if any(tf)
                delete(xlsx)
            end
            
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, '*\.back\.xlsx')));
            if any(tf)
                delete(fullfile(path1,'*.back.xlsx'))
            end
                        
            list1.saveSummaryXlsx(path1);
            
            
            [~,txt] = xlsread(xlsx, 'summary', 'B1');
            testCase.verifyEqual(txt, {'list 1'});
            
            [~,txt] = xlsread(xlsx, 'summary', 'C7');
            testCase.verifyEqual(txt, {'test Event'});

            [~,txt] = xlsread(xlsx, 'summary', 'C8');
            testCase.verifyEqual(txt, {'testWF'});
                      
            % profile viewer
            
        end
        
        function test_saveSummaryXlsxBackup(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_saveSummaryXlsxBackup'));
            %
            % Passed on 3/2/2015
            % Totals:
            %    1 Passed, 0 Failed, 0 Incomplete.
            %    10.4213 seconds testing time.
            


            
            % profile on
            
            sr = 1024;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            chaninfo1 = RecordInfo({E, W});
            
            list1 = FileList({chaninfo1}, 'Name', 'list 1'); %OK, 2014/06/08, 16:49
            list1.Comment = 'hoge';

            
            path1 = fileparts(which('FileList_test.m'));
            listing = dir(path1);
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, 'summary\.xlsx')));
            xlsx = fullfile(path1,'summary.xlsx');
            if any(tf)
                delete(xlsx)
            end
            
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, '*\.back\.xlsx')));
            if any(tf)
                delete(fullfile(path1,'*.back.xlsx'))
            end
            
            list1.saveSummaryXlsx(path1);
            
            [~,txt] = xlsread(xlsx, 'summary', 'B1');
            testCase.verifyEqual(txt, {'list 1'});
            
            [~,txt] = xlsread(xlsx, 'summary', 'C7');
            testCase.verifyEqual(txt, {'test Event'});

            [~,txt] = xlsread(xlsx, 'summary', 'C8');
            testCase.verifyEqual(txt, {'testWF'});
            
            % check if backup is OK
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');

            list1.List{1} = list1.List{1}.addChan(E2); %not handle class
            
            list1.saveSummaryXlsx(path1);
            listing = dir(fullfile(path1, '*.back.xlsx'));
            listing(1).name
            
            [~,~, raw] = xlsread(xlsx, 'summary');
            testCase.verifyEqual(raw{9,3}, 'testWF');
            testCase.verifyTrue(ismember('Event2', raw(7:9,3)));
            testCase.verifyEqual(size(raw), [9,17]);

            [~,~, raw] = xlsread(fullfile(path1, listing(1).name), 'summary');
            testCase.verifyEqual(raw{8,3}, 'testWF');
            testCase.verifyEqual(size(raw), [8,17]);

            % profile viewer
            
        end
        
        function test_saveSummaryXlsxFromMat_withChanInfo_6OHDA_KCN(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_saveSummaryXlsxFromMat_withChanInfo_6OHDA_KCN'));
            
            % OK, 2014/07/01 13:48
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            
            % profile on
            
            matfilepath = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');
            
            addpath( fullfile(regexprep(  fileparts(which('WaveformChan.m')), '@WaveformChan',''), '6OHDA_KCN'));

            chi_e1 = ChanInfo_6OHDA_KCN(matfilepath, 'onset');
            chi_e1.Coordinate = [1 2 3; 10 200 300];
            
            chi_e2 = ChanInfo_6OHDA_KCN(matfilepath, 'probeA07e');
            chi_w = ChanInfo_6OHDA_KCN(matfilepath, 'EEG');
         
            chaninfo1 = RecordInfo({chi_e1, chi_e2, chi_w});
            
            list1 = FileList({chaninfo1}, 'Name', 'kjx127a01@0-20_int16');
            list1.Comment = 'hoge';
            
            path1 = fileparts(which('FileList_test.m'));
            listing = dir(path1);
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, 'summary\.xlsx')));
            xlsx = fullfile(path1,'summary.xlsx');
            if any(tf)
                delete(xlsx)
            end
            
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, '*\.back\.xlsx')));
            if any(tf)
                delete(fullfile(path1,'*.back.xlsx'))
            end
                        
            list1.saveSummaryXlsx(path1);
            
            [~,~,sheet_summary] = xlsread(xlsx, 'summary');

            testCase.verifyEqual(sheet_summary{1, 2}, 'kjx127a01@0-20_int16');
            
            
            testCase.verifyEqual(sheet_summary{7, 3}, 'EEG');
            testCase.verifyEqual(sheet_summary{8, 3}, 'onset');
            testCase.verifyEqual(sheet_summary{9, 3}, 'probeA07e');
           
            testCase.verifyEqual(sheet_summary{7, 6}, 'ChanInfo_6OHDA_KCN');

            testCase.verifyThat(sheet_summary{7, 10}, ...
                IsEqualTo(list1.List{1}.ChanInfos{3}.MaxTime, ...
                'Within', RelativeTolerance(2*eps)));
            
            testCase.verifyEqual(sheet_summary{7, 4}, '..\@WaveformChan\kjx127a01@0-20_int16.mat');
          
            % profile viewer
            
        end
        
        function test_saveSummaryXlsxFromMatRealData(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_saveSummaryXlsxFromMatRealData'));
            %
            % Try construct FileList for all .mat files in a folder and
            % save summary.xlsx for those data
            
            % OK, 2014/07/01 13:55
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            
            % profile on
            
            matfilepath = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');
            
            chi_e1 = ChanInfo_6OHDA_KCN(matfilepath, 'onset');
            chi_e1.Coordinate = [1 2 3; 10 200 300];
            
            chi_e2 = ChanInfo_6OHDA_KCN(matfilepath, 'probeA07e');
            chi_w = ChanInfo_6OHDA_KCN(matfilepath, 'EEG');
         
            chaninfo1 = RecordInfo({chi_e1, chi_e2, chi_w});
            
            list1 = FileList({chaninfo1}, 'Name', 'kjx127a01@0-20_int16');
            list1.Comment = 'hoge';
            
            path1 = fileparts(which('FileList_test.m'));
            listing = dir(path1);
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, 'summary\.xlsx')));
            xlsx = fullfile(path1,'summary.xlsx');
            if any(tf)
                delete(xlsx)
            end
            
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, '*\.back\.xlsx')));
            if any(tf)
                delete(fullfile(path1,'*.back.xlsx'))
            end
                        
            list1.saveSummaryXlsx(path1);
            
            [~,~,sheet_summary] = xlsread(xlsx, 'summary');

            
            testCase.verifyEqual(sheet_summary{1,2}, 'kjx127a01@0-20_int16');
            testCase.verifyEqual(sheet_summary{7,3}, 'EEG');
            
            testCase.verifyThat(sheet_summary{7, 10}, ...
                IsEqualTo(list1.List{1}.ChanInfos{3}.MaxTime, ...
                'Within', RelativeTolerance(2*eps)));
            
            testCase.verifyEqual(sheet_summary{7, 4}, '..\@WaveformChan\kjx127a01@0-20_int16.mat');
            
            % profile viewer
            
        end
        
        %% addRecord()
        function test_addRecord_RecordInfo_obj(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_addRecord_RecordInfo_obj'));
            
            sr = 1024;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            Info1 = RecordInfo({E, W}, 'Name', 'set 1');
            
            list1 = FileList({Info1}, 'Name', 'list 1');
                        
            Info2 = RecordInfo({E2}, 'Name', 'set 2');
            list1 = list1.addRecord(Info2); % scalar RecordInfo obj as input arg
            list1.testProperties;
            
            testCase.verifyClass(list1.List{2}, 'RecordInfo');
            
            
            w2 = randn(1000, 1);
            W2 = WaveformChan(w2, 0, sr, 'testWF 2');
            W2.DataUnit = 'mV';
            
            rec3 = Record({W2}, 'Name', 'set 3');
            list1 = list1.addRecord(rec3); % scalar Record obj as input arg
            
            testCase.verifyClass(list1.List{3}, 'RecordInfo');
   

        end
        
        function test_addRecord_RecordInfo_cell(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_addRecord_RecordInfo_cell'));
            
            sr = 1024;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
 

            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            
            w2 = randn(1000, 1);
            W2 = WaveformChan(w2, 0, sr, 'testWF2');
            W2.DataUnit = 'mV';

            
            Info1 = RecordInfo({E, W}, 'Name', 'set 1');
            
            list1 = FileList({Info1}, 'Name', 'list 1');
                        
            Info2 = RecordInfo({E2, W2}, 'Name', 'set 2');
            list1 = list1.addRecord({Info2});
            list1.testProperties;
            
            testCase.verifyClass(list1.List{2}, 'RecordInfo');
            testCase.verifyClass(list1.List{2}, 'RecordInfo');
            
        end
        
        
        function test_addRecord_RecordInfo_errRecordTitle(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_addRecord_RecordInfo_errRecordTitle'));
            
            sr = 1024;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            Info1 = RecordInfo({E, W});
            Info1.testProperties;
            
            list1 = FileList({Info1});
            list1.testProperties;
            
            verifyClass(testCase, list1.List{1}, 'RecordInfo');
            
            Info2 = RecordInfo({E2});
            testCase.verifyError(@() list1.addRecord({Info2}), ...
                'K:FileList:addRecord:RecordTitle:notunique');

        end
        
        %% removeRecord()
        function test_removeRecord(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_removeRecord'));
            
            sr = 1024;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            Info1 = RecordInfo({E}, 'Name', 'set 3');
            Info2 = RecordInfo({E2}, 'Name', 'set 1');
            Info3 = RecordInfo({W}, 'Name', 'set 2');

            list1 = FileList({Info1, Info2, Info3});

            list2 = list1.removeRecord('set 2');
            testCase.verifyEqual(length(list2.List), 2);
            testCase.verifyEqual(list2.MemberTitles, {'set 3'; 'set 1'});
            clear list2
            
            list2 = list1.removeRecord({'set 2'});
            testCase.verifyEqual(length(list2.List), 2);
            testCase.verifyEqual(list2.MemberTitles, {'set 3'; 'set 1'});
            clear list2
  
            list2 = list1.removeRecord({'set 2';'set 3' });
            list2.testProperties;
            testCase.verifyEqual(length(list2.List), 1);
            testCase.verifyEqual(list2.MemberTitles, {'set 1'});
            clear list2       
            
            list2 = list1.removeRecord({'set 2', 'set 3' });
            list2.testProperties;
            testCase.verifyEqual(length(list2.List), 1);
            testCase.verifyEqual(list2.MemberTitles, {'set 1'});
            clear list2 

            
            list2 = list1.removeRecord([]);
            testCase.verifyEqual(list2, list1);           

            testCase.verifyError(@() list1.removeRecord(5), ...
                'K:FileList:removeRecord:delRecord:invalid');  
            
            testCase.verifyError(@() list1.removeRecord({'asdfa','asdfa';'asdfa','asdfa'}), ...
                'K:FileList:removeRecord:delRecord:invalid');  
            
            testCase.verifyError(@() list1.removeRecord('abcde'), ...
                'K:FileList:removeRecord:delRecord:notincluded');

        end
        
          %% obj.MemberTitles    
        function test_MemberTitles(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_MemberTitles'));
            
            sr = 1024;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            Info1 = RecordInfo({E, W}, 'Name', 'number 1');
            Info2 = RecordInfo({E2}, 'Name', 'number 2');
            
            list1 = FileList({Info1, Info2});

            testCase.verifyEqual(list1.MemberTitles, {'number 1'; 'number 2' })
            

        end
        
        
        
        function test_readSummaryXlsx_simpleData(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_readSummaryXlsx_simpleData'));
                        
            sr = 1024;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            rec1 = RecordInfo({E, W});
            
            list1 = FileList({rec1}, 'Name', 'list 1'); %OK, 2014/06/08, 16:49
            list1.Comment = 'hoge';
            
            path1 = fileparts(which('FileList_test.m'));
            listing = dir(path1);
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, 'summary\.xlsx')));
            xlsx = fullfile(path1,'summary.xlsx');
            if any(tf)
                delete(xlsx)
            end
            
            tf = ~cellfun(@isempty, (regexp({listing(:).name}, '*\.back\.xlsx')));
            if any(tf)
                delete(fullfile(path1,'*.back.xlsx'))
            end
                        
            list1.saveSummaryXlsx(path1);
            
            list2 = FileList('Name', 'read from file');
            list2 = list2.readSummaryXlsx(path1);
            
            %TODO
            
            
        end
        
        function test_RecordAsInput(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_RecordAsInput'));

            sr = 1024;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            
            w2 = randn(1000, 1);
            W2 = WaveformChan(w2, 0, sr, 'testWF2');
            W2.DataUnit = 'mV';
            
            
            rec1 = Record({E, W}, 'Name', 'set 1');
            list1 = FileList({rec1}, 'Name', 'list 1');
            
            rec2 = Record({E2, W2}, 'Name', 'set 2');
            
            list1 = list1.addRecord({rec2});
            list1.testProperties;
            
            testCase.verifyClass(list1.List{2}, 'RecordInfo');
            testCase.verifyClass(list1.List{2}, 'RecordInfo');

        end  
        
        function test_folderpath(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_folderpath'));
            
            pathstr1 = fileparts(which('WaveformChan.m'));
            list1 = FileList(pathstr1);
            testCase.verifyEqual(length(list1.List), 3);
            testCase.verifyEqual(list1.List{1}.ChanTitles, {'onset';'LTS';'LTSmk';'probeA07e';'EEG'});
            testCase.verifyEqual(list1.MemberTitles,...
                {'kjx127a01@0-20_double.mat';'kjx127a01@0-20_int16.mat';'kjx127a01@0-20_single.mat'});


            pathstr2 = fileparts(which('MarkerChan.m'));
            testCase.verifyError(@() FileList(pathstr2), ...
                'K:Record:matfileinput:marker:noref');
            
        end
        
        function test_matfilenames(testCase)
            % clear;close all;clc; test1 = FileList_test; disp(run(test1, 'test_matfilenames'));
            
            pathstr1 = fileparts(which('WaveformChan.m'));
            matlist1 = dir(fullfile(pathstr1, '*.mat'));
            matnames1 = {matlist1(:).name}';
            
            list1 = FileList(matnames1);
            testCase.verifyEqual(length(list1.List), 3);
            testCase.verifyEqual(list1.List{1}.ChanTitles, {'onset';'LTS';'LTSmk';'probeA07e';'EEG'});
            testCase.verifyEqual(list1.MemberTitles,...
                {'kjx127a01@0-20_double.mat';'kjx127a01@0-20_int16.mat';'kjx127a01@0-20_single.mat'});
                        

            pathstr2 = fileparts(which('MarkerChan.m'));
            matlist2 = dir(fullfile(pathstr2, '*.mat'));
            matnames2 = {matlist2(:).name}';
            
            % must be cell array of strings
            testCase.verifyError(@() FileList(matnames2{1:3}),...
                'K:FileList:FileList:pvsetInvalid');
            
            testCase.verifyError(@() FileList(matnames2(1:3)),...
                'K:Record:matfileinput:marker:noref');
            
            list2 = FileList(matnames2(4));
            testCase.verifyEqual(length(list2.List), 1);
            testCase.verifyEqual(list2.List{1}.ChanTitles, {'LTSmarker';'LTSbinned';'LTStextmark'});
            testCase.verifyEqual(list2.MemberTitles,...
                {'markerchan_demodata.mat'});
            
            
        end
        
        
    end
    
end

