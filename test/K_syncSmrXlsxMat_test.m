classdef K_syncSmrXlsxMat_test < matlab.unittest.TestCase
    %K_syncSmrXlsxMat_test < matlab.unittest.TestCase
    % clear;close all;clc; testCase = K_syncSmrXlsxMat_test; disp(testCase.run);
    %
    %
    %TODO under construction
    
    properties
        %TODO need to prepare test data in folders from zip files
    end
    
    methods (Test)
        function testmethod1(testCase)
            % clear;close all;clc; testCase = K_syncSmrXlsxMat_test; disp(testCase.run('testmethod1'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            X = 1;
            testCase.verifyEqual(X, 1);
            
            [Sbef, Saft] = K_syncSmrXlsxMat(smrdir, matdir, excelmasterpath)

            %TODO
        end
        
    end
    
end

