classdef K_extractExcelDataForSpike2_fixture < matlab.unittest.fixtures.Fixture
      % K_extractExcelDataForSpike2_fixture < matlab.unittest.fixtures.Fixture
      %
      % zip('mat1.zip','mat1')
      %
      % See also
      % K_extractExcelDataForSpike2_test, K_extractExcelDataForSpike2
    
 properties (Access=private)
        home;
        
        thisdir = fullfile(fileparts(which('K_extractExcelDataForSpike2_test')), 'smr2mat_testdata');
        temp =    fullfile(fileparts(which('K_extractExcelDataForSpike2_test')), 'smr2mat_testdata','temp');
        
    end

    methods
        function setup(fixture)
            % See also
            % K_folder_mat2sparse_test.prep_COPYfolder;
            
            disp('Make sure you turned off Dropbox syncing. It will affect rmdir operation and leads to unstable results.')
            
            fixture.home = pwd;
            
            cd(fixture.thisdir); 
            
            if ~isdir(fixture.temp)
                mkdir(fixture.temp);
            else
                rmdir(fixture.temp,'s');
                mkdir(fixture.temp);                
            end   
            
        end
        
        function teardown(fixture)
            cd(fixture.thisdir);

            if isdir(fixture.temp)
                rmdir(fixture.temp, 's'); 
            end
            
            cd(fixture.home);
            
        end
    end
end
