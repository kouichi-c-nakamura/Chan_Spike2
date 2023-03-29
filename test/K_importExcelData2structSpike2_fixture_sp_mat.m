classdef K_importExcelData2structSpike2_fixture_sp_mat < matlab.unittest.fixtures.Fixture
    % K_importExcelData2structSpike2_fixture_sp_mat < matlab.unittest.fixtures.Fixture
    %
    %
    % fixture for K_importExcelData2structSpike2_test
    %
    % See also K_importExcelData2structSpike2_test
        
    properties (Access=private)
        home;
        thisdir = fullfile(fileparts(which('K_importExcelData2structSpike2_test')), 'smr2mat_testdata');
        matspdir = fullfile(fileparts(which('K_importExcelData2structSpike2_test')), 'smr2mat_testdata', 'mat1_sp');

        matspdirzip = fullfile(fileparts(which('K_importExcelData2structSpike2_test')), 'smr2mat_testdata', 'mat1_sp.zip');
        %         excelpath = fullfile(fileparts(which('K_importExcelData2structSpike2_test')), 'smr2mat_testdata', 'kjx data summary bits.xlsx');
        
    end

    methods
        function setup(fixture)
            disp('Make sure you turned off Dropbox syncing. It will affect rmdir operation and leads to unstable results.') 
            
            fixture.home = pwd;
            
            cd(fixture.thisdir);

            if isdir(fixture.matspdir)
                rmdir(fixture.matspdir, 's');
            end
            
            unzip(fixture.matspdirzip, fixture.thisdir);
            
        end
        
        function teardown(fixture)
            
            cd(fixture.thisdir);
            
            if isdir(fixture.matspdir)
                rmdir(fixture.matspdir, 's'); % unstable
            end
            
            cd(fixture.home);
        end
    end
end