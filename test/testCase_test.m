classdef XXXXX_test < matlab.unittest.TestCase
    %XXXXX_test < matlab.unittest.TestCase
    %
    % clear;close all;clc;testCase = XXXXX_test;res = testCase.run;disp(res);
    %
    %
    % See also
    % 
    
    properties
        
    end
    
    methods (Test)
        function test1(testCase)
            % clear;close all;clc; testCase = XXXXX_test; disp(testCase.run('test1'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            X = 1;
            testCase.verifyEqual(X, 1);

        end
        
    end
    
end

