classdef K_importXYZ_csv2masterxlsx_fixture < matlab.unittest.fixtures.Fixture
      % K_importXYZ_csv2masterxlsx_fixture < matlab.unittest.fixtures.Fixture
      %
      % See also
      % K_importXYZ_csv2masterxlsx_test
    
 properties (Access=private)
        home;
        
        thisdir = fullfile(fileparts(which('K_importXYZ_csv2masterxlsx_fixture')), ...
            'smr2mat_testdata');
        
        matspdir = fullfile(fileparts(which('K_importXYZ_csv2masterxlsx_fixture')), ...
            'smr2mat_testdata', 'mat1_sp');

        matspdirzip = fullfile(fileparts(which('K_importXYZ_csv2masterxlsx_fixture')), ...
            'smr2mat_testdata', 'mat1_sp.zip');
        
        excelpath = fullfile(fileparts(which('K_importXYZ_csv2masterxlsx_fixture')), ...
            'smr2mat_testdata', 'kjx data summary bits.xlsx');

        csvzip = fullfile(fileparts(which('K_importXYZ_csv2masterxlsx_fixture')),...
            'smr2mat_testdata', 'csv1.zip');

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
            
            unzip(fixture.csvzip, fixture.matspdir);
            
            copyfile(fixture.excelpath, fixture.matspdir);

        end
        
        function teardown(fixture)
            if isdir(fixture.matspdir)
                rmdir(fixture.matspdir, 's');
            end
                        
            cd(fixture.home);

            
        end
    end
end
