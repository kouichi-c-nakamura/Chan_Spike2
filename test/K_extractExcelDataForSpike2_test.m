classdef K_extractExcelDataForSpike2_test < matlab.unittest.TestCase
    %     K_extractExcelDataForSpike2_test < matlab.unittest.TestCase
    %
    %     clear;close all; clc; testCase = K_extractExcelDataForSpike2_test; res =testCase.run ; disp(res);
    %
    %NOTE absolute addresses in Excel file is affected by addition of
    % headers in Excel file.
    %
    % passed 31-May-2016 17:11:40
    % Totals:
    %    7 Passed, 0 Failed, 0 Incomplete.
    %    24.4775 seconds testing time.
    
    properties
        %         destdir = 'Z:\Work\Spike2 folder\Kouichi MATLAB\thalamus\probe\6OHDA\swa\SUA\Spike2MAT';
        home = pwd;
        
        thisdir = fullfile(fileparts(which('K_extractExcelDataForSpike2_test')), 'smr2mat_testdata');
        matdir = fullfile(fileparts(which('K_extractExcelDataForSpike2_test')), 'smr2mat_testdata', 'mat1');
        excelpath = fullfile(fileparts(which('K_extractExcelDataForSpike2_test')), 'smr2mat_testdata', 'kjx data summary bits.xlsx');
        xlsx = fullfile('temp', '*.xlsx');
        
    end
    
    
    methods (Test)
        
        function test16x1_74_84(testCase)
            % clear;close all; clc; testCase = K_extractExcelDataForSpike2_test; res =testCase.run('test16x1_74_84') ; disp(res);
            %
            % Passed 31-May-2016 16:59:33

            testCase.applyFixture(K_extractExcelDataForSpike2_fixture);

%             delete(testCase.xlsx);
            list0 = K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 74:84);
            
            list = dir('temp/*xlsx');
            testCase.verifyEqual(list.name,  'kjx155a01_info.xlsx');
            testCase.verifyEqual(length(list0),  1);
            
            [~, ~, raw] = xlsread(list0{1});
            testCase.verifySize(raw, [17, 22]);
            testCase.verifyEqual(raw(1,:)', {...
                'Animal';...
                'Record';...
                'Electrode';...
                'ProbeMode';...
                'Dopamine';...
                'Tag';...
                'Stim';...
                'Description';...
                'Label';...
                'Location';...
                'Identified';...
                'Note for Labeled Cell';...
                'Spike sorting';...
                'SUA Copied to Analysis Folder';...
                'LFP Copied to Analysis Folder';...
                'recX';...
                'recY';...
                'recZ';...
                'isinjection';...
                'injX';...
                'injY';...
                'injZ';...
                ...
                });
            
            testCase.verifyEqual(raw(2:end,1), repmat({'kjx155'}, 16, 1));
            testCase.verifyEqual(raw(2:end,2), repmat({'a01'}, 16, 1));
            
        end
        
        function test16x2_673_708(testCase)
            % clear;close all; clc; testCase = K_extractExcelDataForSpike2_test; res =testCase.run('test16x2_673_708') ; disp(res);
            %
            % passed 31-May-2016 17:02:36

            testCase.applyFixture(K_extractExcelDataForSpike2_fixture);

%             delete(testCase.xlsx);
            list0 = K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 673:708);
            
            list = dir('temp/*xlsx');
            testCase.verifyEqual({list(:).name}',  {'kjx167b01_info.xlsx';...
                'kjx167b02_info.xlsx'});
            testCase.verifyEqual(length(list),  2);
            
            [~, ~, raw] = xlsread(list0{1});
            testCase.verifySize(raw, [33, 22]);
            testCase.verifyEqual(raw(1,:)', {...
                'Animal';...
                'Record';...
                'Electrode';...
                'ProbeMode';...
                'Dopamine';...
                'Tag';...
                'Stim';...
                'Description';...
                'Label';...
                'Location';...
                'Identified';...
                'Note for Labeled Cell';...
                'Spike sorting';...
                'SUA Copied to Analysis Folder';...
                'LFP Copied to Analysis Folder';...
                'recX';...
                'recY';...
                'recZ';...
                'isinjection';...
                'injX';...
                'injY';...
                'injZ';...
                ...
                });
            
            testCase.verifyEqual(raw(2:end,1), repmat({'kjx167'}, 32, 1));
            testCase.verifyEqual(raw(2:end,2), repmat({'b01'}, 32, 1));
            
            
            % Passed 2015/03/31 13:57
            
        end
        
        
        function testcase_106_138(testCase)
            % clear;close all; clc; testCase = K_extractExcelDataForSpike2_test; res =testCase.run('testcase_106_138') ; disp(res);
            
            %% row 122 contains no Record, but has Animal and Electrode.

            testCase.applyFixture(K_extractExcelDataForSpike2_fixture);
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 122:122);
            
            list = dir(testCase.xlsx);
            testCase.assertEqual(numel(list), 0); % no output expected
            delete(testCase.xlsx);
            clear list
            fprintf('\n');
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 122:123);
            list = dir(testCase.xlsx);
            testCase.assertEqual(numel(list), 1);
            testCase.assertEqual(list.name, 'kjx155c01_info.xlsx'); % just one file
            delete(testCase.xlsx);
            clear list
            fprintf('\n');
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 123);
            list = dir(testCase.xlsx);
            testCase.assertEqual(numel(list), 1);
            testCase.assertEqual(list.name, 'kjx155c01_info.xlsx'); % just one file
            delete(testCase.xlsx);
            clear list
            fprintf('\n');
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 124);
            list = dir(testCase.xlsx);
            testCase.assertEqual(numel(list), 0); % the fist row (123) was not included
            delete(testCase.xlsx);
            clear list
            fprintf('\n');
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 123:144);
            list = dir(testCase.xlsx);
            testCase.assertEqual(numel(list), 2); % 144 is in the middle of kjx155c01 but the whole 16 channels are extracted.
            delete(testCase.xlsx);
            clear list
            fprintf('\n');
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 100:150);
            list = dir(testCase.xlsx);
            testCase.assertEqual(numel(list), 3);
            delete(testCase.xlsx);
            clear list
            fprintf('\n');
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), [122,139,153:160]); %155.156,157 do not contain Record
            list = dir(testCase.xlsx);
            testCase.assertEqual(numel(list), 2);
            delete(testCase.xlsx);
            clear list
            fprintf('\n');
            
            % passed 2015/3/31 15:59
            
        end
        
        function testcase_kjx155c02(testCase)
            % clear;close all; clc; testCase = K_extractExcelDataForSpike2_test; res =testCase.run('testcase_kjx155c02') ; disp(res);

            testCase.applyFixture(K_extractExcelDataForSpike2_fixture);
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 'kjx155c02');
            
            list = dir('temp/*xlsx');
            
            testCase.verifyEqual(list.name,  'kjx155c02_info.xlsx');
            
            % Passed /19/01/2015 21:36
            
        end
        
        function testcase_kjx155c01_kjx167b(testCase)
            % clear;close all; clc; testCase = K_extractExcelDataForSpike2_test; res =testCase.run('testcase_kjx155c01_kjx167b') ; disp(res);
            

            testCase.applyFixture(K_extractExcelDataForSpike2_fixture);
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 'kjx155c01|kjx167b');
            
            list = dir('temp/*xlsx');
            
            testCase.assertEqual(numel(list), 3);
            delete(testCase.xlsx);
            clear list
            fprintf('\n');
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), {'kjx155c01','kjx167b02'});
            
            list = dir('temp/*xlsx');
            testCase.assertEqual(numel(list), 2);
            
            % Passed /19/01/2015 22:15
            
        end
        
        function updateexistingxlsx(testCase)
            % clear;close all; clc; testCase = K_extractExcelDataForSpike2_test; res =testCase.run('updateexistingxlsx') ; disp(res);
            
            %% Only update when there is a change in the contents

            testCase.applyFixture(K_extractExcelDataForSpike2_fixture);
            
            tempxlsx = regexprep(testCase.excelpath, '.xlsx$', '_temp.xlsx');
            copyfile(testCase.excelpath, tempxlsx);
            

            K_extractExcelDataForSpike2(tempxlsx, fullfile(testCase.thisdir, 'temp'), 'kjx155c01|kjx167b');
            
            list = dir('temp/*xlsx');
            testCase.assertEqual(numel(list), 3);
            
            [~, txt] = xlsread(tempxlsx, 'Detail', 'P126:P126');
            testCase.assertEqual(txt, {'nowhere'});
            
            % update the master file
            xlswrite(tempxlsx, {'EVERYWHERE'}, 'Detail', 'P126:P126');
            [~, txt] = xlsread(tempxlsx, 'Detail', 'P126:P126');
            %NOTE absolute addresses in Excel file is affected by addition of
            % headers in Excel file.
            
            testCase.assertEqual(txt, {'EVERYWHERE'});
            
            % Do it again
            list2 = K_extractExcelDataForSpike2(tempxlsx, fullfile(testCase.thisdir, 'temp'), 'kjx155c01|kjx167b');
            testCase.assertEqual(numel(list2), 1);
            clear list2
            
            list2 = dir('temp/*xlsx');
            testCase.verifyEqual( [list(:).datenum] <  [list2(:).datenum], [true, false, false]);
            % only update the file whose content has been updated
            
            
            delete(tempxlsx);
            
        end
        
        
        
        function testcase_juxta1(testCase)
            % clear;close all; clc; testCase = K_extractExcelDataForSpike2_test; res =testCase.run('testcase_juxta1') ; disp(res);
            
            %TODO LOCATION is not included in every row

            testCase.applyFixture(K_extractExcelDataForSpike2_fixture);
            
            K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 6:8);
            list = dir('temp/*xlsx');
            testCase.assertEqual(numel(list), 3);
            clear list
            
%             delete(testCase.xlsx);
%             K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), 25);
%             list = dir('temp/*xlsx');
%             testCase.assertEqual(numel(list), 0);
%             
%             delete(testCase.xlsx);
%             K_extractExcelDataForSpike2(testCase.excelpath, fullfile(testCase.thisdir, 'temp'), [31,30,33,38,39]);
%             list = dir('temp/*xlsx');
%             testCase.assertEqual(numel(list), 3);

             
        end
        
        
        
    end
end

