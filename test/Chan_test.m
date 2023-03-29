classdef Chan_test < matlab.unittest.TestCase
    %Chan_test < matlab.unittest.TestCase
    % clear;close all;clc; testCase = Chan_test; disp(testCase.run);
    %
    %
    %
    % Passed on 10 Feb 2015
    % Totals:
    %    1 Passed, 0 Failed, 0 Incomplete.
    %    0.66225 seconds testing time.
    
    properties
        
    end
    
    methods (Test)
        function testmethod1(testCase)
            % clear;close all;clc; testCase = Chan_test; disp(testCase.run('testmethod1'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            pathstr1 = fileparts(which('WaveformChan.m'));
            
            S = load(fullfile(pathstr1,'kjx127a01@0-20_double.mat'));
                        
            finames = fieldnames(S);
            
            testCase.verifyClass(Chan.constructChan(S.(finames{1})), 'EventChan');
            testCase.verifyClass(Chan.constructChan(S.(finames{5})), 'WaveformChan');
            
            
            [obj1, obj2, obj3, obj4, obj5] = ...
                Chan.constructChan(S.(finames{1}), S.(finames{2}), S.(finames{3}), S.(finames{4}), S.(finames{5}));
            
            testCase.verifyClass(obj1, 'EventChan');
            testCase.verifyClass(obj2, 'EventChan');
            testCase.verifyClass(obj3, 'EventChan');
            testCase.verifyClass(obj4, 'EventChan');
            testCase.verifyClass(obj5, 'WaveformChan');
            
            
            pathstr2 = fileparts(which('MarkerChan.m'));
            
            S = load(fullfile(pathstr2,'markerchan_demodata.mat'));
            finames = fieldnames(S);

            testCase.verifyError(@() Chan.constructChan(S.(finames{1})), ...
                'K:Chan:constructChan:datastruct:marker:noref');
            
            testCase.verifyClass(Chan.constructChan(S.(finames{1}), 'ref', S.(finames{2})), ...
                'MarkerChan');
            
            
            [obj6, obj7] = ...
                Chan.constructChan(S.(finames{1}), S.(finames{3}),'ref',  S.(finames{2}));
            testCase.verifyClass(obj6, 'MarkerChan');
            testCase.verifyClass(obj7, 'MarkerChan');

            testCase.verifyError(@() Chan.constructChan(obj1), ...
                'K:Chan:constructChan:datastruct:notstruct');
            
            
            

        end
        
    end
    
end

