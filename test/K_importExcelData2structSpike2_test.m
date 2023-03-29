classdef K_importExcelData2structSpike2_test < matlab.unittest.TestCase
    % K_importExcelData2structSpike2_test < matlab.unittest.TestCase
    %
    % clear;close all; clc; testCase = K_importExcelData2structSpike2_test; res =testCase.run ; disp(res);
    %
    %
    % 31-May-2016 16:41:38
    % Totals:
    %    6 Passed, 0 Failed, 0 Incomplete.
    %    55.3697 seconds testing time.
    %
    % See also
    % K_importExcelData2structSpike2, K_importExcelData2structSpike2_fixture_sp_mat

    
    properties
        home = pwd;
        thisdir = fullfile(fileparts(which('K_importExcelData2structSpike2_test')), ...
            'smr2mat_testdata');
        
        matspdir = fullfile(fileparts(which('K_importExcelData2structSpike2_test')), ...
            'smr2mat_testdata', 'mat1_sp');
        
        excelpath = fullfile(fileparts(which('K_importExcelData2structSpike2_test')), ...
            'smr2mat_testdata', 'kjx data summary bits.xlsx');

        
        % See K_importExcelData2structSpike2 > local_assign_others for
        % details about "isidentified"
        % the field is added only to juxta channels (not probe or EEG channels)
        
        wf_fieldnamesP = {...
            'title';...
            'comment';...
            'interval';...
            'scale';...
            'offset';...
            'units';...
            'start';...
            'length';...
            'values';...
            'channumber';...
            'animal';...
            'record';...
            'dopamine';...
            'isinjection';... % added
            'xyzrec';... % added
            'xyzinj';... % added
            'probemode';...
            'electrode';...
            'location';...
            'note_labeledcell';...
            ...
            };
        
        wf_fieldnamesJ = {...
            'title';...
            'comment';...
            'interval';...
            'scale';...
            'offset';...
            'units';...
            'start';...
            'length';...
            'values';...
            'channumber';...
            'animal';...
            'record';...
            'dopamine';...
            'isinjection';... % added
            'xyzrec';... % added
            'xyzinj';... % added
            'probemode';...
            'electrode';...
            'location';...
            'note_labeledcell';...
            'isidentified';... % added ... %TODO missing from some 
            ...
            };
        
        ev_fieldnamesP = {...   
            'title';...
            'comment';...
            'interval';...
            'start';...
            'length';...
            'values';...
            'channumber';...
            'animal';...
            'record';...
            'dopamine';...
            'isinjection';... % added
            'xyzrec';... % added
            'xyzinj';... % added
            'probemode';...
            'electrode';...
            'location';...
            'note_labeledcell';...
            ...
            };
        
        ev_fieldnamesJ = {...   
            'title';...
            'comment';...
            'interval';...
            'start';...
            'length';...
            'values';...
            'channumber';...
            'animal';...
            'record';...
            'dopamine';...
            'isinjection';... % added
            'xyzrec';... % added
            'xyzinj';... % added
            'probemode';...
            'electrode';...
            'location';...
            'note_labeledcell';...
            'isidentified';... % added %TODO missing from some 
            ...
            };
        
    end
    
    methods (Test)
        
        function testcase1_16x1(testCase)
            % clear;close all; clc; testCase = K_importExcelData2structSpike2_test; res =testCase.run('testcase1_16x1') ; disp(res);
            %
            % 2015-04-22 20:42
            % Totals:
            %    1 Passed, 0 Failed, 0 Incomplete.
            %    83.3178 seconds testing time.
            
            
            testCase.applyFixture(K_importExcelData2structSpike2_fixture_sp_mat);
            
            rowrange = 450:590;
            
            starttime = now;
            
            list0 = K_extractExcelDataForSpike2(testCase.excelpath, testCase.matspdir, rowrange);
            testCase.verifyEqual(length(list0), 9);
            
            list = dir(fullfile(testCase.matspdir, '*_info.xlsx'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 9);
            
            % requires *_sp.mat files
            list0 = K_importExcelData2structSpike2(testCase.matspdir, '-regexp', {'^kjx155r01'});
            list = dir(fullfile(testCase.matspdir, '*_m.mat'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 3);
            
            S = load(fullfile(testCase.matspdir, list(1).name));
            testCase.verifyEqual(fieldnames(S), {...
                'postEEG';...
                'IpsiEEG';...
                'probeA01';...
                'probeA02';...
                'probeA03';...
                'probeA04';...
                'probeA05';...
                'probeA06';...
                'probeA07';...
                'probeA08';...
                'probeA09';...
                'probeA10';...
                'probeA11';...
                'probeA12';...
                'probeA13';...
                'probeA14';...
                'probeA15';...
                'probeA16';...
                'HumCED';...
                'probeA01u';...
                'probeA01e';...
                'probeA02u';...
                'probeA03u';...
                'probeA04u';...
                'probeA04e';...
                'probeA05u';...
                'probeA06u';...
                'probeA07u';...
                'probeA07e';...
                'probeA08u';...
                'probeA09u';...
                'probeA10u';...
                'probeA11u';...
                'probeA12u';...
                'probeA13u';...
                'probeA14u';...
                'probeA15u';...
                'probeA16u';...
                ...
                });
            testCase.verifyEqual(fieldnames(S.postEEG), testCase.wf_fieldnamesP);%TODO
            testCase.verifyEqual(fieldnames(S.probeA01), testCase.wf_fieldnamesP);
            testCase.verifyEqual(fieldnames(S.probeA03u), testCase.wf_fieldnamesP);
            testCase.verifyEqual(fieldnames(S.HumCED), testCase.ev_fieldnamesP);
            
            
            list = dir(fullfile(testCase.matspdir, 'kjx155r01*_sp.mat'));
            testCase.verifyEqual(length(list), 0); % should have been deleted by now
            
            
        end
        
        
        function testcase2_16x1(testCase)
            % clear;close all; clc; testCase = K_importExcelData2structSpike2_test; res =testCase.run('testcase2_16x1') ; disp(res);
            
            testCase.applyFixture(K_importExcelData2structSpike2_fixture_sp_mat);
            
            rowrange = 450:590;
            
            starttime = now;
            
            list0 = K_extractExcelDataForSpike2(testCase.excelpath, testCase.matspdir, rowrange);
            testCase.verifyEqual(length(list0), 9);
            
            list = dir(fullfile(testCase.matspdir, '*_info.xlsx'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 9);
            
            % requires *_sp.mat files
            list0 = K_importExcelData2structSpike2(testCase.matspdir, '-regexp', {'^kjx155r01@0-10A','^kjx155r01@0-10C',}); % make sure it can handle multiple files at a time
            list = dir(fullfile(testCase.matspdir, '*_m.mat'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 2);
            
            list = dir(fullfile(testCase.matspdir, 'kjx155r01@0-10A*_sp.mat'));
            testCase.verifyEqual(length(list), 0); % should have been deleted by now
            
            list = dir(fullfile(testCase.matspdir, 'kjx155r01@0-10C*_sp.mat'));
            testCase.verifyEqual(length(list), 0); % should have been deleted by now
            
%             list0 = K_importExcelData2structSpike2(testCase.matspdir,testCase.matspdir, '-listdlg', true);
%             disp(list0);
            
        end
        
        
        function testcase3_16x1(testCase)
            % clear;close all; clc; testCase = K_importExcelData2structSpike2_test; res =testCase.run('testcase3_16x1') ; disp(res);
            
            testCase.applyFixture(K_importExcelData2structSpike2_fixture_sp_mat);
            
            rowrange = 450:590;
            
            starttime = now;
            
            list0 = K_extractExcelDataForSpike2(testCase.excelpath, testCase.matspdir, rowrange);
            testCase.verifyEqual(length(list0), 9);
            
            list = dir(fullfile(testCase.matspdir, '*_info.xlsx'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 9);
            
            % output in a subdirectory
            temp = fullfile(testCase.matspdir,'temp');
            mkdir(temp);
            
            % output in a subdirectory
            list0 = K_importExcelData2structSpike2(testCase.matspdir, temp, '-regexp', {'^kjx155r01'});
            list = dir(fullfile(temp, '*_m.mat'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 3);
            
            list = dir(fullfile(testCase.matspdir, 'kjx155r01*_sp.mat'));
            testCase.verifyEqual(length(list), 3); % should be still there
            
        end
        
        
        
        function testcase4_16x2(testCase)
            % clear;close all; clc; testCase = K_importExcelData2structSpike2_test; res =testCase.run('testcase4_16x2') ; disp(res);
            
            testCase.applyFixture(K_importExcelData2structSpike2_fixture_sp_mat);
            
            rowrange = 730:805;
            
            starttime = now;
            
            list0 =K_extractExcelDataForSpike2(testCase.excelpath, testCase.matspdir, rowrange);
            list = dir(fullfile(testCase.matspdir, '*_info.xlsx'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 3);
            
            list0 = K_importExcelData2structSpike2(testCase.matspdir, '-regexp', {'kjx127a01','jx167c'});
            testCase.verifyEqual(length(list0), 1);
            
            S = load(list0{1});
            testCase.verifyEqual(length(fieldnames(S)), 71);
            testCase.verifyEqual(fieldnames(S.IpsiEEGh), testCase.wf_fieldnamesP);
            testCase.verifyEqual(fieldnames(S.probeB08e), testCase.ev_fieldnamesP)
            
            
            list = dir(fullfile(testCase.matspdir, '*_m.mat'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 1);
        end
        
        function testcase5_16x2(testCase)
            % clear;close all; clc; testCase = K_importExcelData2structSpike2_test; res =testCase.run('testcase5_16x2') ; disp(res);
            
            testCase.applyFixture(K_importExcelData2structSpike2_fixture_sp_mat);
            
            rowrange = 730:805;
            
            starttime = now;
            
            list0 =K_extractExcelDataForSpike2(testCase.excelpath, testCase.matspdir, rowrange);
            list = dir(fullfile(testCase.matspdir, '*_info.xlsx'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 3);
            
            list0 = K_importExcelData2structSpike2(testCase.matspdir, testCase.matspdir, '-ismember', {'kjx127a01_sp.mat', 'kjx167c01@0-100@0-10A_sp.mat'});
            testCase.verifyEqual(length(list0), 1);
            
            list = dir(fullfile(testCase.matspdir, '*_m.mat'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 1);
            
%             K_importExcelData2structSpike2(testCase.matspdir, testCase.matspdir, '-listdlg', true);
            
        end
        
        function testcase6_juxta(testCase)
            % clear;close all; clc; testCase = K_importExcelData2structSpike2_test; res =testCase.run('testcase6_juxta') ; disp(res);
            %
            % 2015-04-22 20:59
            % Totals:
            %    1 Passed, 0 Failed, 0 Incomplete.
            %    85.836 seconds testing time.
            
            testCase.applyFixture(K_importExcelData2structSpike2_fixture_sp_mat);
            
            rowrange = 18:28;
            
            starttime = now;
            
            list0 = K_extractExcelDataForSpike2(testCase.excelpath, testCase.matspdir, rowrange);
            list = dir(fullfile(testCase.matspdir, '*_info.xlsx'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 11);
            
            % output in a subdirectory
            temp = fullfile(testCase.matspdir,'temp');
            mkdir(temp);
            
            list0 = K_importExcelData2structSpike2(testCase.matspdir, temp, '-regexp', {'kjx021a01','jx021i'});
            list = dir(fullfile(testCase.matspdir, 'temp', '*.mat'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 2);
            
            S = load(fullfile(testCase.matspdir, 'temp', list(1).name));
            testCase.verifyEqual(fieldnames(S), {...
                'Spliced';...
                'IpsiEEG';...
                'ME1_Unit';...
                'ME1_LFP';...
                'bige';...
                'bsts_on_5';...
                'LTS';...
                'onset';...
                'SpkBst5';...
                'Sngl';...
                'sSngl';...
                'bstO_2';...
                'bstO_3';...
                'bstO_4';...
                'bstO_5';...
                'bstO_6';...
                'bstO_7';...
                'LTSmk';...
                'Pinch';...
                'smalle';...
                'bigMark';...
                'pure';...
                'merged';...
                'smallWMth';...
                'BigThresh';...
                ...
                });
            
            testCase.verifyEqual(fieldnames(S.IpsiEEG), testCase.wf_fieldnamesP);
            
            testCase.verifyEqual(fieldnames(S.ME1_Unit), testCase.wf_fieldnamesJ);
            
            testCase.verifyEqual(fieldnames(S.bige), testCase.ev_fieldnamesJ);
            
            
            list = dir(fullfile(testCase.matspdir, '*jx021i*_sp.mat'));
            testCase.verifyEqual(length(list), 2); % should be still there
            
            % the same directory
            list0 = K_importExcelData2structSpike2(testCase.matspdir, '-ismember', {'kjx021i01A_sp.mat', 'kjx021i01B_sp.mat'});
            list = dir(fullfile(testCase.matspdir,'*.mat'));
            ind = [list(:).datenum]' > starttime ;
            testCase.verifyEqual(nnz(ind), 2);
            
            list = dir(fullfile(testCase.matspdir, 'kjx021i01*_sp.mat'));
            testCase.verifyEqual(length(list), 0); % should be gone
            
            
        end
        
    end
    
end

