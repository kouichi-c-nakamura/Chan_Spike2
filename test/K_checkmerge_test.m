classdef K_checkmerge_test < matlab.unittest.TestCase
    %K_checkmerge_test < matlab.unittest.TestCase
    %
    % clear;close all;clc; testCase = K_checkmerge_test; disp(testCase.run);
    %
    %
    % Passed on 17/03/2015, 13:49
    % Totals:
    %    1 Passed, 0 Failed, 0 Incomplete.
    %    0.69658 seconds testing time.
    
    properties

        home = fullfile(fileparts(which('K_checkmerge_test.m')), 'K_checkmerge_testdata');
        
    end
    
    methods
        function obj = K_checkmerge_test()
            homedir = fullfile(fileparts(which('K_checkmerge_test.m')), 'K_checkmerge_testdata');
            if ~isdir(homedir)
               unzip([homedir, '.zip'], fileparts(which('K_checkmerge_test.m'))) ;
            end
            
        end
        
    end
    
    methods (Test)
        

        function test_K_checkdmerge(testCase)
            % clear testCase;close all;clc; testCase = K_checkmerge_test; res =testCase.run('test_K_checkdmerge'); disp(res);

            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            mat = fullfile(testCase.home, 'mat-1');

            smr = fullfile(testCase.home, 'smr-1');
            xlsx = fullfile(testCase.home, 'xlsx-1');

            %%
            [S] = K_checkmerge(smr, '*.smr', xlsx, '*_info.xlsx', mat, '*_m.mat');
            testCase.verifyEqual(size(S.smr_updateMat), [0, 0]);
            testCase.verifyEqual(size(S.smr_addXlsxupdateMat), [0, 0]);
            testCase.verifyEqual(size(S.smr_addMat), [0, 0]);
            testCase.verifyEqual(size(S.xlsx_rmXlsx), [0, 0]);
            testCase.verifyEqual(size(S.mat_rmMat), [0, 0]);
            % Passed on 17/02/2015, 14:23
            testCase.verifyEqual(S.smr_all, {...
                'kjx158i01.smr';...
                'kjx160b01@0-100.smr';...
                'kjx160b05@150-250.smr';...
                ...
                });
            testCase.verifyEqual(S.xlsx_all, {...
                'kjx158i01_info.xlsx';...
                'kjx160b01_info.xlsx';...
                'kjx160b05_info.xlsx';...
                ...
                });
            testCase.verifyEqual(S.mat_all, {...
                'kjx158i01_m.mat';...
                'kjx160b01@0-100_m.mat';...
                'kjx160b05@150-250_m.mat';...
                ...
                });
            
            %%
            smr = fullfile(testCase.home, 'smr-2');
            [S] = K_checkmerge(smr, '*.smr', xlsx, '*_info.xlsx', mat, '*_m.mat');
            testCase.verifyEqual(S.smr_updateMat, {'kjx160b01@0-100.smr'});
            testCase.verifyEqual(S.smr_addXlsxupdateMat, {...
                'kjx160c01@0-100.smr';...
                'kjx160d01@17-43_46-70_73-89_91-119_122-148@0-100.smr';...
                ...
                });
            testCase.verifyEmpty(S.smr_addMat);
            testCase.verifyEmpty(S.xlsx_rmXlsx);
            testCase.verifyEmpty(S.mat_rmMat);
            % Passed on 17/02/2015, 14:30
            testCase.verifyEqual(S.smr_all, {...
                'kjx158i01.smr';...
                'kjx160b01@0-100.smr';...
                'kjx160b05@150-250.smr';...
                'kjx160c01@0-100.smr';...
                'kjx160d01@17-43_46-70_73-89_91-119_122-148@0-100.smr';...
                ...
                });
            testCase.verifyEqual(S.xlsx_all, {...
                'kjx158i01_info.xlsx';...
                'kjx160b01_info.xlsx';...
                'kjx160b05_info.xlsx';...
                ...
                }); 
            testCase.verifyEqual(S.mat_all, {...
                'kjx158i01_m.mat';...
                'kjx160b01@0-100_m.mat';...
                'kjx160b05@150-250_m.mat';...
                ...
                });
            %%
            smr = fullfile(testCase.home, 'smr-1');
            xlsx = fullfile(testCase.home, 'xlsx-2');
            [S] = K_checkmerge(smr, '*.smr', xlsx, '*_info.xlsx', mat, '*_m.mat');
            testCase.verifyEqual(S.smr_updateMat, {'kjx160b01@0-100.smr'});
            testCase.verifyEmpty(S.smr_addXlsxupdateMat);
            testCase.verifyEmpty(S.smr_addMat);
            testCase.verifyEqual(S.xlsx_rmXlsx, {'kjx160c01_info.xlsx'});
            testCase.verifyEmpty(S.mat_rmMat);
            % Passed on 17/02/2015, 14:35
            testCase.verifyEqual(S.smr_all, {...
                'kjx158i01.smr';...
                'kjx160b01@0-100.smr';...
                'kjx160b05@150-250.smr';...
                ...
                });
            testCase.verifyEqual(S.xlsx_all, {...
                'kjx158i01_info.xlsx';...
                'kjx160b01_info.xlsx';...
                'kjx160b05_info.xlsx';...
                'kjx160c01_info.xlsx';...
                ...
                }); 
            testCase.verifyEqual(S.mat_all, {...
                'kjx158i01_m.mat';...
                'kjx160b01@0-100_m.mat';...
                'kjx160b05@150-250_m.mat';...
                ...
                });
           %%
            smr = fullfile(testCase.home, 'smr-3');
            xlsx = fullfile(testCase.home, 'xlsx-2');
            [S] = K_checkmerge(smr, '*.smr', xlsx, '*_info.xlsx', mat, '*_m.mat');
            testCase.verifyEqual(S.smr_updateMat, {'kjx160b01@0-100.smr'});
            testCase.verifyEmpty(S.smr_addXlsxupdateMat);
            testCase.verifyEmpty(S.smr_addMat);
            testCase.verifyEqual(S.xlsx_rmXlsx, {'kjx158i01_info.xlsx';...
                'kjx160b05_info.xlsx';...
                'kjx160c01_info.xlsx';...
                ...
                });
            testCase.verifyEqual(S.mat_rmMat, {'kjx158i01_m.mat';...
                'kjx160b05@150-250_m.mat'});
            % Passed on 17/02/2015, 14:49
            testCase.verifyEqual(S.smr_all, {...
                'kjx160b01@0-100.smr';...
                ...
                });
            testCase.verifyEqual(S.xlsx_all, {...
                'kjx158i01_info.xlsx';...
                'kjx160b01_info.xlsx';...
                'kjx160b05_info.xlsx';...
                'kjx160c01_info.xlsx';...
                ...
                }); 
            testCase.verifyEqual(S.mat_all, {...
                'kjx158i01_m.mat';...
                'kjx160b01@0-100_m.mat';...
                'kjx160b05@150-250_m.mat';...
                ...
                });  
            %%
            smr = fullfile(testCase.home, 'smr-2');
            xlsx = fullfile(testCase.home, 'xlsx-3');
            [S] = K_checkmerge(smr, '*.smr', xlsx, '*_info.xlsx', mat, '*_m.mat');
            testCase.verifyEqual(S.smr_updateMat, {'kjx160b01@0-100.smr'});
            testCase.verifyEqual(S.smr_addXlsxupdateMat, {'kjx158i01.smr';...
                'kjx160c01@0-100.smr';...
                'kjx160d01@17-43_46-70_73-89_91-119_122-148@0-100.smr'});
            testCase.verifyEmpty(S.smr_addMat);
            testCase.verifyEmpty(S.xlsx_rmXlsx);
            testCase.verifyEmpty(S.mat_rmMat);    
            % Passed on 17/02/2015, 14:52
            testCase.verifyEqual(S.smr_all, {...
                'kjx158i01.smr';...
                'kjx160b01@0-100.smr';...
                'kjx160b05@150-250.smr';...
                'kjx160c01@0-100.smr';...
                'kjx160d01@17-43_46-70_73-89_91-119_122-148@0-100.smr';...
                ...
                });
            testCase.verifyEqual(S.xlsx_all, {...
                'kjx160b01_info.xlsx';...
                'kjx160b05_info.xlsx';...
                ...
                }); 
            testCase.verifyEqual(S.mat_all, {...
                'kjx158i01_m.mat';...
                'kjx160b01@0-100_m.mat';...
                'kjx160b05@150-250_m.mat';...
                ...
                });             
          
            %% In case a source file was renamed after saving destination files

            smr = fullfile(testCase.home, 'smr-4');
            xlsx = fullfile(testCase.home, 'xlsx-1');
            [S] = K_checkmerge(smr, '*.smr', xlsx, '*_info.xlsx', mat, '*_m.mat');
            testCase.verifyEmpty(S.smr_updateMat);
            testCase.verifyEqual(S.smr_addXlsxupdateMat, {'kjx160c01@0-100.smr'});
            testCase.verifyEmpty(S.smr_addMat);
            testCase.verifyEqual(S.xlsx_rmXlsx, {'kjx158i01_info.xlsx'});
            testCase.verifyEqual(S.mat_rmMat, {'kjx158i01_m.mat'});
            % Passed on 17/02/2015, 14:57
            testCase.verifyEqual(S.smr_all, {...
                'kjx160b01@0-100.smr';...
                'kjx160b05@150-250.smr';...
                'kjx160c01@0-100.smr';...
                ...
                });
            testCase.verifyEqual(S.xlsx_all, {...
                'kjx158i01_info.xlsx';...
                'kjx160b01_info.xlsx';...
                'kjx160b05_info.xlsx';...
                ...
                }); 
            testCase.verifyEqual(S.mat_all, {...
                'kjx158i01_m.mat';...
                'kjx160b01@0-100_m.mat';...
                'kjx160b05@150-250_m.mat';...
                ...
                }); 
        
            
            %% only one wild card is allowed for affixes
            testCase.verifyError(@() K_checkmerge(smr, '*data*.smr', xlsx, '*_info.xlsx', mat, '*_m.mat'), ...
                'MATLAB:InputParser:ArgumentFailedValidation');

            testCase.verifyError(@() K_checkmerge(smr, '*info*.smr|1.smr', xlsx, '*_info.xlsx', mat, '*_m.mat'), ...
                'K:pvt_parseaffix:affix');
 
            testCase.verifyError(@() K_checkmerge(smr, '.smr|*_*.smr', xlsx, '*_info.xlsx', mat, '*_m.mat'), ...
                'K:pvt_parseaffix:negaffixC');
            
            testCase.verifyError(@() K_checkmerge(smr, '.smr|*_*.smr|2.smr', xlsx, '*_info.xlsx', mat, '*_m.mat'), ...
                'K:pvt_parseaffix:negaffixC');  
            
            testCase.verifyError(@() K_checkmerge(smr, '*.smr', xlsx, '*_info*.xlsx|1.xlsx', mat, '*_m.mat'), ...
                'K:pvt_parseaffix:affix');
 
            testCase.verifyError(@() K_checkmerge(smr, '*.smr', xlsx, '_info.xlsx|*_info*.xlsx', mat, '*_m.mat'), ...
                'K:pvt_parseaffix:negaffixC');
                
            
        end
        
        
    end
    
end

