classdef smr2mat_dataflow_fixture < matlab.unittest.fixtures.Fixture
    % smr2mat_dataflow_fixture < matlab.unittest.fixtures.Fixture
    %
    % fixture = smr2mat_dataflow_fixture;
    
 properties
        home
        
        thisdir = fullfile(fileparts(which('smr2mat_dataflow_fixture')), ...
            'smr2mat_testdata');
        
        matdir

        matdirzip
        
        smrdir
        
        smrdirzip
        
        excelpath

        csvzip

    end

    methods
        function setup(fixture)
            disp('Make sure you turned off Dropbox syncing. It will affect rmdir operation and leads to unstable results.')

            fixture.home = pwd;
            
            cd(fixture.thisdir);

            if isdir(fixture.matdir)
                rmdir(fixture.matdir, 's');
            end
            
            unzip(fixture.matdirzip, fixture.thisdir);
            
            unzip(fixture.csvzip, fixture.matdir);
            
            copyfile(fixture.excelpath, fixture.matdir);
            
            if isdir(fixture.smrdir)
                rmdir(fixture.smrdir, 's');
            end
            
            unzip(fixture.smrdirzip, fixture.thisdir);

        end
        
        function teardown(fixture)
            if isdir(fixture.matdir)
                rmdir(fixture.matdir, 's');
            end
            
            unzip(fixture.matdirzip, fixture.thisdir);

            
            if isdir(fixture.smrdir)
                rmdir(fixture.smrdir, 's');
            end
            
            unzip(fixture.smrdirzip, fixture.thisdir);
                        
            cd(fixture.home);
            
        end
        
        function out = get.matdir(fixture)
            
            out =  fullfile(fixture.thisdir,  'mat1');

        end
        
        function out = get.matdirzip(fixture)
            
            out =  fullfile(fixture.thisdir,  'mat1.zip');

        end
        
        function out = get.smrdir(fixture)
            
            out =  fullfile(fixture.thisdir,  'smr1');

        end
        
        function out = get.smrdirzip(fixture)
            
            out =  fullfile(fixture.thisdir,  'smr1.zip');

        end
        
        function out = get.excelpath(fixture)
            
            out =  fullfile(fixture.thisdir,  'kjx data summary bits.xlsx');

        end
        
        function out = get.csvzip(fixture)
            
            out =  fullfile(fixture.thisdir,  'csv1.zip');

        end

    end
end
