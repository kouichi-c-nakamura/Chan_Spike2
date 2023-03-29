classdef K_folder_mat2sparse_test < matlab.unittest.TestCase
    % K_folder_mat2sparse_test < matlab.unittest.TestCase
    %
    % clear;close all;clc; testCase = K_folder_mat2sparse_test; disp(testCase.run);
    %
    %
    % The data for test is quite big, so you may not able to keep them around.
    % what you need is paired .mat files for waveform/event and marker/textmark
    % data, that are exported from Spike2 with ExportAsMat.s2s (Version 1.1).
    % The .mat file for marker/textmark has suffix "*_mk.mat".
    %
    %
    % *Data files in mat1*
    % kjx021i01A.mat              juxta data (waveforms and events)
    % kjx021i01A_mk.mat           juxta data (markers)
    % 
    % kjx021i01B.mat              juxta data (waveforms and events)
    % kjx021i01B_mk.mat           juxta data (markers)
    % 
    % kjx155r01@0-10A.mat         probe data (16x1)
    % kjx155r01@0-10B.mat
    % kjx155r01@0-10C.mat
    % 
    % kjx167a01@0-10.mat          probe data (16x2)
    % kjx167c01@0-100@0-10A.mat   
    %
    % See also
    % K_folder_mat2sparse, K_folder_mat2sparse_test_fixture1, K_folder_mat2sparse_test_fixture2 
    %
    %
    % Passed 01-Jun-2016 15:20:15
    % Totals:
    %    6 Passed, 0 Failed, 0 Incomplete.
    %    32.286 seconds testing time.
    
    properties
        home = fullfile(fileparts(which('K_folder_mat2sparse_test.m')), 'smr2mat_testdata','mat1');

        home2 = fullfile(fileparts(which('K_folder_mat2sparse_test.m')), 'smr2mat_testdata','mat1_withoutnumber');

    end
    
    methods (Test)
        function folderbased(testCase)
            % clear;close all;clc; testCase = K_folder_mat2sparse_test; disp(testCase.run('folderbased'));
            %
            % passed 31-May-2016 18:13:18
            
            ho = testCase.home;    

            testCase.applyFixture(K_folder_mat2sparse_test_fixture1);

            destaffix = '*_sp.mat';
            list = K_folder_mat2sparse(ho, fullfile(ho, 'COPY'), destaffix);
            
            testCase.verifyEqual(size(list), [7 1]);
            testCase.verifyTrue(all(cellfun(@(x) strfind(x, '_sp.mat'), list)));

            listing2 = dir(fullfile(ho, 'COPY', '*.mat'));
            outnames = {listing2(:).name}';

            % check the chan numbers
            for i = 1:length(outnames)
                S = load(fullfile(ho, 'COPY', outnames{i}));
                finames = fieldnames(S);
                N = zeros(size(finames));
                for j = 1:length(finames)
                   N(j) = S.(finames{j}).channumber;
                end
                
                testCase.verifyTrue(isnumeric(N) && all(fix(N) == N) && all(N > 0 ));
              
                testCase.verifyEqual(nnz(unique(N)), length(N));
            end
            
        end
        
        function samefolders(testCase)
            % clear;close all;clc; testCase = K_folder_mat2sparse_test; disp(testCase.run('samefolders'));
            %
            % passed 31-May-2016 18:33:52
            
            %% Prep

            testCase.applyFixture(K_folder_mat2sparse_test_fixture1);
            
            ho = testCase.home;
            cp = fullfile(ho, 'COPY');
            
            prep_COPYfolder(testCase);
            
            %% Job: delete when source and dest are the same
            listing4 = dir(fullfile(cp, '*.mat'));
            
            list = K_folder_mat2sparse(cp, cp);
            % should delete the originals
            % Worked 26/02/014, @10:40
            
            listing5 = dir(fullfile(cp, '*.mat'));
            
            testCase.verifyEqual(size(list), [7 1]);
            testCase.verifyTrue(all(cellfun(@(x) ~isempty(x), strfind(list, '.mat'))));
            testCase.verifyTrue(all(cellfun(@isempty, strfind(list, '_sp.mat'))));
            testCase.verifyEqual({listing4([1,3,5:9]).name}, {listing5(:).name}) ;% TODO
            testCase.verifyTrue(all([listing4([1,3,5:9]).datenum] < [listing5(:).datenum]));
             
            
        end
        
        function unmatchedmatfiles(testCase)
            % clear;close all;clc; testCase = K_folder_mat2sparse_test; disp(testCase.run('unmatchedmatfiles'));
            %
            % passed 01-Jun-2016 12:33:37


            %% Prep

            testCase.applyFixture(K_folder_mat2sparse_test_fixture1);

            ho = testCase.home;
            cp = fullfile(ho, 'COPY');
            
            prep_COPYfolder(testCase);
            
            %% unmatched mat files for waveform/event vs marker/textmark
           

            % prepare unmatched mat files
            delete(fullfile(cp, 'kjx021i01A.mat')); 
            delete(fullfile(cp, 'kjx021i01B_mk.mat')); 

            listing4 = dir(fullfile(cp, '*.mat'));
            
            list = testCase.verifyWarning(@() K_folder_mat2sparse(cp, cp),...
                'K:K_folder_mat2sparse:local_classify_mnames:mktmonly');
            %NOTE 01-Jun-2016 12:03:36
            % kjx021i01A_mk will issue the warning due to the lack of
            % kjx021i01A.mat that is to be combined, whereas kjx021i01B will
            % NOT issue warning, because this file can serve on its own
            % for waveform and event channels
            %
            % As a result, kjx021i01A.mat will be missing, whereas
            % kjx021i01B.mat will be there.
            
            
            listing5 = dir(fullfile(cp, '*.mat'));

            testCase.verifyEqual(size(list), [6 1]);
            % kjx021i01A.mat should be missing
            
            testCase.verifyTrue(all(cellfun(@(x) ~isempty(x), strfind(list, '.mat'))));
            testCase.verifyTrue(all(cellfun(@isempty, strfind(list, '_sp.mat'))));
            testCase.verifyEqual({listing4(2:7).name}, {listing5(:).name}) ;
            testCase.verifyTrue(all([listing4(2:7).datenum] < [listing5(:).datenum]));

        end
            
        
        function alreadyconverted(testCase)
            % clear;close all;clc; testCase = K_folder_mat2sparse_test; disp(testCase.run('alreadyconverted'));
            %
            % passed 01-Jun-2016 13:20:07
            
            %% Prep
            
            testCase.applyFixture(K_folder_mat2sparse_test_fixture1);

            ho = testCase.home;
            cp = fullfile(ho, 'COPY');
            
            prep_COPYfolder(testCase);
            
            %% Job: File specfic operation

            listing4 = dir(fullfile(cp, '*.mat'));

            list = K_folder_mat2sparse(cp, ...
                {'kjx021i01A.mat','kjx021i01A_mk.mat','kjx155r01@0-10B.mat'} , cp); % 1,2,6
            
            listing5 = dir(fullfile(cp, '*.mat'));

            testCase.verifyEqual(size(list), [2, 1]);
            testCase.verifyTrue(all(cellfun(@(x) ~isempty(x), strfind(list, '.mat'))));
            testCase.verifyTrue(all(cellfun(@isempty, strfind(list, '_sp.mat'))));
            testCase.verifyEqual(list, {listing4([1,6]).name}') ;
            testCase.verifyEqual({listing4([1,3,4:9]).name}', {listing5(:).name}');
            testCase.verifyEqual(find([listing4([1,3,4:9]).datenum] < [listing5(:).datenum]), [1, 5]); %#ok<FNDSB>
           
            
            %% Job: Folder operation including converted files

            list2 = K_folder_mat2sparse(cp, cp);
            %
            % already converted kjx021i01A.mat and kjx155r01@0-10B.mat
            % won't be included in list2 (they should have been skipped)
           
            listing6 = dir(fullfile(cp, '*.mat'));
           
            testCase.verifyEqual(list2, ...
                {...
                'kjx021i01B.mat';...
                'kjx155r01@0-10A.mat';...
                'kjx155r01@0-10C.mat';...
                'kjx167a01@0-10.mat';...
                'kjx167c01@0-100@0-10A.mat';...
                ...
                });

            testCase.verifyTrue(all(cellfun(@(x) ~isempty(x), strfind(list2, '.mat'))));
            testCase.verifyTrue(all(cellfun(@isempty, strfind(list2, '_sp.mat'))));
            
            testCase.verifyTrue(all([listing4([1,3,5:9]).datenum] < [listing6(:).datenum]));
            testCase.verifyEqual([listing5([1,2,4:8]).datenum] < [listing6(:).datenum],...
                logical([0 1 1 0 1 1 1]));

            
        end
        
        function textfilemissing(testCase)
            % clear;close all;clc; testCase = K_folder_mat2sparse_test; disp(testCase.run('textfilemissing'));
            %
            % passed 01-Jun-2016 13:39:09


            %% Prep
            
            testCase.applyFixture(K_folder_mat2sparse_test_fixture1);

            ho = testCase.home;
            cp = fullfile(ho, 'COPY');
            
            prep_COPYfolder(testCase);
            
            delete(fullfile(cp, 'kjx021i01A_chanMAT.txt'));
            delete(fullfile(cp, 'kjx155r01@0-10B_chanMAT.txt'));
           
            listing4 = dir(fullfile(cp, '*.mat'));

            list = K_folder_mat2sparse(cp, cp);
            
            % Absence of the text file does not matter
            
            listing5 = dir(fullfile(cp, '*.mat'));

            
            testCase.verifyEqual(size(list), [7 1]);
            testCase.verifyTrue(all(cellfun(@(x) ~isempty(x), strfind(list, '.mat'))));
            testCase.verifyTrue(all(cellfun(@isempty, strfind(list, '_sp.mat'))));
            testCase.verifyEqual({listing4([1,3,5:9]).name}, {listing5(:).name}) ;
            testCase.verifyTrue(all([listing4([1,3,5:9]).datenum] < [listing5(:).datenum]));
                        
        end
        
        
        function commentwithoutchannumber(testCase)
            % clear;close all;clc; testCase = K_folder_mat2sparse_test; disp(testCase.run('commentwithoutchannumber'));
            %
            % passed 01-Jun-2016 15:15:53
            
            %% Prep
            
            testCase.applyFixture(K_folder_mat2sparse_test_fixture2);

            ho = testCase.home2;
            
            destaffix = '*_sp.mat';
            list = testCase.verifyWarning(@() K_folder_mat2sparse(ho, fullfile(ho, 'COPY'), destaffix),...
                'K:K_folder_mat2sparse:local_assignChanNumber2field:thenum');
            
            listing5 = dir(fullfile(ho, 'COPY', '*.mat'));
            outnames = {listing5(:).name}';
            
            testCase.verifyEqual(size(list), [6 1]);
            testCase.verifyTrue(all(cellfun(@(x) strfind(x, '_sp.mat'), list)));
            
            
            % check the chan numbers
            for i = 1:length(outnames)
                S = load(fullfile(ho, 'COPY', outnames{i}));
                finames = fieldnames(S);
                N = zeros(size(finames));
                for j = 1:length(finames)
                   N(j) = S.(finames{j}).channumber;
                end
                
                testCase.verifyTrue(isnumeric(N) && ~any(N));
              
            end
        end
    end
    
%--------------------------------------------------------------------------
    
    methods
        function prep_COPYfolder(testCase)
   
            ho = testCase.home;
            
            listing1 = dir(fullfile(fullfile(ho), '*.mat'));
            listing2 = dir(fullfile(fullfile(ho), '*.txt'));
            listing3 = [listing1; listing2];

            mnamesall = {listing3.name}';
            clear listing1 listing2
            
            for i=1:length(mnamesall)
                copyfile(fullfile(ho, mnamesall{i}),...
                    fullfile(ho,'COPY', mnamesall{i}));
            end

        end


    end
end


