% TestSuite for Spike 2 .smr to MATLAB .mat data file conversion process
% for the Kouichi Thalamus Project




clear;close all;clc;

disp('Make sure you turned off Dropbox syncing. It will affect rmdir operation and leads to unstable results.')
disp('Type "dbcont" to proceed.')
keyboard

import matlab.unittest.TestSuite;

names = {...
    'K_importXYZ_csv2masterxlsx_test.m';...
    'K_importExcelData2structSpike2_test.m';...
    'K_extractExcelDataForSpike2_test.m';...
    'K_folder_mat2sparse_test.m';...
    'K_getupdated_test.m';...
    'K_checkmerge_test.m';...
    ...'K_syncSmrXlsxMat_test.m' % under construction
    ...'smr2mat_dataflow_test.m'
    ...
    };

    
n = length(names);
C = cell(1, n);
for i = 1:n
    
    this = which(names{i}); % better be absolute path
    
    C{i} = TestSuite.fromFile(this); 
    %TODO once worked, but now issues an error
    % alhtough files are in search path, TestSuite.fromFile says it does
    % not exit
end

smrmat_foldersync_suite = [C{:}];

result = run(smrmat_foldersync_suite);

disp(result)
