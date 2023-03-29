classdef K_folder_mat2sparse_test_fixture1 < matlab.unittest.fixtures.Fixture
      % K_folder_mat2sparse_test_fixture1 < matlab.unittest.fixtures.Fixture
      %
      % zip('mat1.zip','mat1')
      %
      % See also
      % K_folder_mat2sparse_test, K_folder_mat2sparse_test_fixture2
    
 properties (Access=private)
        home;
        
        base = fullfile(fileparts(which('K_folder_mat2sparse_test.m')), 'smr2mat_testdata');
        ho = fullfile(fileparts(which('K_folder_mat2sparse_test.m')), 'smr2mat_testdata','mat1');

    end

    methods
        function setup(fixture)
            % See also
            % K_folder_mat2sparse_test.prep_COPYfolder;
            
            disp('Make sure you turned off Dropbox syncing. It will affect rmdir operation and leads to unstable results.')
            
            fixture.home = pwd;
            
            cd(fixture.base);            
            
            if isdir(fixture.ho)
                rmdir(fixture.ho,'s'); % always unzip
            end
            unzip(fullfile(fixture.base,'mat1.zip'),fixture.base);
            
            cd(fixture.ho);
            
            cp = fullfile(fixture.ho, 'COPY');
                        
            if isdir(cp)
                rmdir(cp, 's');
                mkdir(cp);
            else
                mkdir(cp);
            end

        end
        
        function teardown(fixture)
            cd(fixture.base);
            
            cp = fullfile(fixture.ho, 'COPY');

            if isdir(cp)
                rmdir(cp, 's'); 
            end
            
            cd(fixture.home);
            
        end
    end
end
