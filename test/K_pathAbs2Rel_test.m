classdef K_pathAbs2Rel_test < matlab.unittest.TestCase
    %
    % relpath = K_pathAbs2Rel( targetpath, refdirpath )
    %
    % to run a test:
    % clear;close all;clc; test1= K_pathAbs2Rel_test; disp(test1.run);
    %
    % 22 Jan 2015
    % Totals:
    %    11 Passed, 0 Failed, 0 Incomplete.
    %    0.12877 seconds testing time.
    
    properties
    end
    
    methods (Test)
        function testFolderFolder(testCase)
            targetpath = 'C:\local\data\matlab';
            refdirpath = 'C:\local';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '\data\matlab');
        end
        
        function testFolderFolder2(testCase)
            targetpath = 'C:\local\data\matlab\';
            refdirpath = 'C:\local\';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '\data\matlab');
        end
        
        function testFolderFolder3(testCase)
            targetpath = 'C:\local\data\matlab\';
            refdirpath = 'C:\local';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '\data\matlab');
        end
        
        function testFolderFolder4(testCase)
            targetpath = 'C:\local\data\matlab';
            refdirpath = 'C:\local\';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '\data\matlab');
        end
        
        function testFolderFolder5(testCase)
            targetpath = 'C:\local\demo';
            refdirpath = 'C:\local\data\hoge';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '..\..\demo');
        end   
 
        
        function testFileFolder(testCase)
            targetpath = 'C:\local\data\matlab.m';
            refdirpath = 'C:\local';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '\data\matlab.m');
        end
        
        
        function testFileFolder2(testCase)
            targetpath = 'C:\local\data\matlab.m';
            refdirpath = 'C:\local\';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '\data\matlab.m');
        end
        
        function testFileFolder3(testCase)
            targetpath = 'C:\local\demo.mat';
            refdirpath = 'C:\local\data\hoge';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '..\..\demo.mat');
        end  
        
        
        function testFileFolderDifVol(testCase)
            targetpath = 'A:\MyProject\test.m';
            refdirpath = 'C:\local';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, 'A:\MyProject\test.m');
        end
        
        function testFolderFolderDifVol(testCase)
            targetpath = 'A:\MyProject\';
            refdirpath = 'C:\local';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, 'A:\MyProject\');
        end
        
        function testEmptyTarget(testCase)
            targetpath = '';
            refdirpath = 'C:\local';
            
            res = K_pathAbs2Rel(targetpath, refdirpath);
            testCase.verifyEqual(res, '');
        end
        
%         function testEmptyRef(testCase)
%             cd(fileparts(which(K_pathAbs2Rel_test)));
%             
%             targetpath = 'C:\local\data\matlab';
%             refdirpath = '';
%             
%             res = K_pathAbs2Rel(targetpath, refdirpath);
%             testCase.verifyEqual(res, '\data\matlab');
%         end
        
    end
    
end

