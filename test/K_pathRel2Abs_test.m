classdef K_pathRel2Abs_test < matlab.unittest.TestCase
    %
    % relpath = K_pathRel2Abs( targetpath, refdirpath )
    %
    % to run a test:
    % clear;close all;clc; test1= K_pathRel2Abs_test; disp(test1.run);
    %
    % 22 Jan 2015
    % Totals:
    %    9 Passed, 0 Failed, 0 Incomplete.
    %    0.11294 seconds testing time.
    
    properties
    end
    
    methods (Test)
        function testFolderFolder(testCase)
            
            targetpath = '\data\matlab';
            refdirpath = 'C:\local';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, 'C:\local\data\matlab');
        end
        
        function testFolderFolder2(testCase)
            targetpath = '\data\matlab';
            refdirpath = 'C:\local\';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, 'C:\local\data\matlab');
        end
        
        function testFolderFolder3(testCase)
            targetpath = '\data\matlab';
            refdirpath = 'C:\local';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, 'C:\local\data\matlab');
        end
        
        function testFolderFolder4(testCase)
            targetpath = '\data\matlab';
            refdirpath = 'C:\local\';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, 'C:\local\data\matlab');
        end
 
        function testFolderFolder5(testCase)
            targetpath = '..\..\demo';
            refdirpath = 'C:\local\data\hoge';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, 'C:\local\demo');
        end   
        
        
        function testFileFolder(testCase)
            targetpath = '\data\matlab.m';
            refdirpath = 'C:\local';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, 'C:\local\data\matlab.m');
        end
        
        
        function testFileFolder2(testCase)
            targetpath = '\data\matlab.m';
            refdirpath = 'C:\local\';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, 'C:\local\data\matlab.m');
        end
        
        function testFileFolder3(testCase)
            targetpath = '..\..\demo.mat';
            refdirpath = 'C:\local\data\hoge';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, 'C:\local\demo.mat');
        end  
        
        function testEmptyTarget(testCase)
            targetpath = '';
            refdirpath = 'C:\local';
            
            res = K_pathRel2Abs(targetpath, refdirpath);
            testCase.verifyEqual(res, '');
        end
        
    end
    
end

