classdef K_folder_mat2sparse_test_fixture2 < matlab.unittest.fixtures.Fixture
      % K_folder_mat2sparse_test_fixture2 < matlab.unittest.fixtures.Fixture
      %
      % zip('mat1_withoutnumber.zip','mat1_withoutnumber')
      %
      % See also
      % K_folder_mat2sparse_test, K_folder_mat2sparse_test_fixture1
    
 properties (Access=private)
        home;
        
        base = fullfile(fileparts(which('K_folder_mat2sparse_test.m')), 'smr2mat_testdata');
        ho = fullfile(fileparts(which('K_folder_mat2sparse_test.m')), 'smr2mat_testdata','mat1_withoutnumber'); %DIFFERENCE

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
            unzip(fullfile(fixture.base,'mat1_withoutnumber.zip'),fixture.base); %DIFFERENCE
            
            cd(fixture.ho);
                        
            if isdir(fullfile(fixture.ho, 'COPY'))
                rmdir(fullfile(fixture.ho, 'COPY'), 's');
                mkdir(fullfile(fixture.ho, 'COPY'));
            else
                mkdir(fullfile(fixture.ho, 'COPY'));
            end

        end
        
        function teardown(fixture)
            cd(fixture.base);            
            
            if isdir(fullfile(fixture.ho, 'COPY'))
                rmdir(fullfile(fixture.ho, 'COPY'), 's'); % unstable
            end
            
            cd(fixture.home);
            
        end
    end
end

%% To check the content of .mat files
%
% s = load('kjx021i01A')
% 
% finames =fieldnames(s);
% 
% 
% for i = 1:length(finames)
%    disp(s.(finames{i}).comment);
% end