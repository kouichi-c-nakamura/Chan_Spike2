classdef smr2mat_dataflow_test < matlab.unittest.TestCase
    %smr2mat_dataflow_test < matlab.unittest.TestCase
    %
    % clear;close all;clc; testCase = smr2mat_dataflow_test; disp(testCase.run);
    %
    % cf. matlab.unittest.fixtures.TemporaryFolderFixture
    %
    % See also
    % K_getupdatedmerge, K_extractExcelDataForSpike2,
    % K_importExcelData2structSpike2, K_folder_mat2sparse, ChanSpecifier
    % 
    %
    %  kjx100a01.smr in smr1dir
    %  kjx100a01.mat and kjx100a01_mk.mat in mat1dir
    %  kjx100a01_sp.mat and kjx100a01_info.xlsx in mat1dir
    %  kjx100a01_m.mat in mat1dir
    
    properties
        
    end
    
    methods (Test)
        function testmethod1(testCase)
            % clear;close all;clc; testCase = smr2mat_dataflow_test; disp(testCase.run('testmethod1'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            fxt = testCase.applyFixture(smr2mat_dataflow_fixture);

            % for brevity
            excelpath = fxt.excelpath;
            smr1dir = fxt.smrdir;
            mat1dir = fxt.matdir;
            xlsxdir = fxt.matdir;
            
            smraffix = '*.smr';
            xlsxaffix = '*_info.xlsx';
            mat1affix = '_m.mat';

            S = K_getupdatedmerge(smr1dir, smraffix, xlsxdir, xlsxaffix, mat1dir, mat1affix);
            
            % S = K_getupdatedf(src1dir, src1affix, src2dir, src2affix, destdir, destaffix);
            
            if ~isempty(S.src1_updateDest)
                
                %TODO
            end
            
            if ~isempty(S.src1_addSrc2updateDest) % this can be a method of a class S
                
                % getfilenames2animals_records()
                animalrecord = regexp(S.src1_addSrc2updateDest, '^[a-zA-Z-]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d', 'match');
                
                % handle the case in which not match returned
                notempty = cellfun(@(y) ~isempty(y), animalrecord);
                
                animalrecord(notempty) = cellfun(@(x) x{1}, ...
                    animalrecord(notempty), ...
                    'UniformOutput', false);
                
                animalrecord(~notempty) = repmat({''}, nnz(~notempty), 1);
                
                expr_animalrecord = strjoin(animalrecord(notempty)', '|');
                
                [list1, skipped1] = K_extractExcelDataForSpike2(excelpath, mat1dir, expr_animalrecord);
                
                
                %% then update process
                
                % check if the first mat is new
                
                % TODO what if they have been erased?
                
                S = K_getupdated(smr1dir, '*.smr', mat1dir, '*.mat|*_m.mat');

                
                list2 = K_importExcelData2structSpike2(mat1dir, '-regexp', expr_animalrecord); %TODO
                
            end
            
%             if ~isempty(S.src1_addDest)
%                  %TODO
%             end
%             
%             if ~isempty(S.src2_rmSrc2)
%                  %TODO
%             end
%             
%             if ~isempty(S.dest_rmDest)
%                  %TODO
%             end
            
            
%             [list] = K_folder_mat2sparse(destdir1, destdir1);
            
            
            
            
            
            
            %%
            
            S = K_getupdatedf(src1dir, src1affix, src2dir, src2affix, destdir, destaffix);
            
            
            chanspec = ChanSpecifier(destdir1);
            matnames = chanspec.MatNames;
            
            animalrecord = regexp(matnames, 'kjx\d\d\d[a-z]\d\d', 'match'); % cell array whose each cell contains a cellstr
            expr_animalrecord = cellfun(@(x) ['^', x{:}], animalrecord, 'UniformOutput', false); % cellstr; ^ specifies the word beginning
            
            %% extract from Excel
            
            K_extractExcelDataForSpike2(excelpath, matfolder, expr_animalrecord);
            
            
            %% merge
            
            K_importExcelData2structSpike2(matfolder, matfolder, '-regexp', expr_animalrecord);
            
            
            % so far so good, no error, job done with just a few lines, very organized,
            % I'm happy
            
            
            %% choose event 'e' channels
            
            clear chanspec
            
            chanspec = ChanSpecifier(matfolder);
            
            
            [isformat_probeA00e, name] = chanspec.ischanvalid('title', @(x) ismatchedany(x, 'probe[AB]\d\de')');
            
            chanspec_sua = chanspec.choose(isformat_probeA00e);
            
            outlist = chanspec_sua.List;
            
            
            
            %% Style 1
            % n = length(outlist);
            % for i = 1:n
            %     rec = Record(fullfile(matfolder, outlist(i).name));
            %
            %     chselected = fieldnames(outlist(i).channels);
            %     m = length(chselected);
            %
            %     for j = 1:m
            %         outlist(i).stats(j) = rec.(chselected{j}).Stats;
            %     end
            % end
            
            %% Style 2
            
            
            for i = 1:chanspec_sua.MatNum
                rec = Record(chanspec_sua.MatNamesFull{i});
                
                for j = 1:chanspec_sua.ChanNum(i)
                    outlist(i).stats(j) = rec.(chanspec_sua.ChanTitles{i}{j}).Stats;
                end
            end
            
            
            channum = sum(chanspec_sua.ChanNum);
            fields = fieldnames(outlist(1).stats(1));
            fields = [fields;{'parent'}];
            fn = length(fields);
            
            fival= repmat({{}}, 1, fn*2);
            fival(1:2:(fn*2)) = fields'; %% Creation of this vector was the most tricky
            
            result = struct(fival{:}); % Empty structure with fields
            k =1;
            for i = 1:length(outlist)
                thisname = outlist(i).name;
                for j = 1:length(outlist(i).stats)
                    outlist(i).stats(j).parent = thisname;
                    
                    result(k) = outlist(i).stats(j); %% assignment to non-scalar structure requires exact match of fieldnames
                    k = k+1;
                end
                
            end
            
            length(fieldnames(result )), length(fieldnames(outlist(i).stats(j)))
            
            
            
            testCase.verifyEqual(X, 1);
            
        end
        
    end
    
end

