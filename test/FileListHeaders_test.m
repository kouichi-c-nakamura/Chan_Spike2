classdef FileListHeaders_test < matlab.unittest.TestCase
    %FileListHeaders_test < matlab.unittest.TestCase
    %
    % clc;clear; test1 = FileListHeaders_test; res =test1.run ; disp(res);
    %
    % 22 Jan 2015
    % Totals:
    %    9 Passed, 0 Failed, 0 Incomplete.
    %    0.47179 seconds testing time.
    
    properties
        defh = {'RecordTitle', 'ChanNumber', 'ChanTitle',  'Path', 'ChanStructVarName','ChanInfoClassName', ...
            'DataUnit', 'TimeUnit', 'Start [sec]', 'MaxTime [sec]', 'SRate [Hz]','SInterval [sec]',...
            'Length', 'Header', 'ChanTitleRef', 'PathRef', 'ChanStructVarNameRef'}
        % MUST be identical to FileListHeaders.Headers
        
    end
    
    methods (Test)
        function testObjDefault(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testObjDefault') ; disp(res);
            
            obj = FileListHeaders();
            
            verifyEqual(testCase, obj.Headers, testCase.defh);
            
        end
        
        function testObjWithInput(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testObjWithInput') ; disp(res);
            
            %% new header items Test1 and Test2 are added in the middle
            
            h = {'RecordTitle', 'ChanNumber', 'ChanTitle',  'Path', 'ChanStructVarName','ChanInfoClassName', ...
            'DataUnit', 'TimeUnit', 'Start [sec]', 'MaxTime [sec]', 'SRate [Hz]','SInterval [sec]',...
            'Length', 'Header', 'Test1', 'ChanTitleRef', 'PathRef',  'Test2', 'ChanStructVarNameRef'};
            
            
            obj = FileListHeaders(h);
            
            verifyEqual(testCase, obj.Headers, ...
                [testCase.defh, {'Test1', 'Test2'}]);
            
        end
        
        function testObjWithInputUnits(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testObjWithInputUnits') ; disp(res);
            
            %% new header items Test1 and Test2 are added in the middle
            
            h = {'RecordTitle', 'ChanNumber', 'ChanTitle',  'Path', 'ChanStructVarName','ChanInfoClassName', ...
            'DataUnit', 'TimeUnit', 'Start [sec]', 'MaxTime [sec]', 'SRate [Hz]','SInterval [sec]',...
            'Length', 'Header', 'Test1 [sec]', 'ChanTitleRef', 'PathRef',  'Test2 [mV]', 'ChanStructVarNameRef'};
                       
            obj = FileListHeaders(h);
            
            verifyEqual(testCase, obj.Headers, ...
                [testCase.defh, {'Test1 [sec]', 'Test2 [mV]'}]);

            
        end
        
        function testObjWithInputUnitsNoSpace(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testObjWithInputUnitsNoSpace') ; disp(res);
            
            %% 'Test1[sec]' is not allowed (a space is required inbetween)
            
            h = {'RecordTitle', 'ChanNumber', 'ChanTitle',  'Path', 'ChanStructVarName','ChanInfoClassName', ...
            'DataUnit', 'TimeUnit', 'Start [sec]', 'MaxTime [sec]', 'SRate [Hz]','SInterval [sec]',...
            'Length', 'Header', 'Test1[sec]', 'ChanTitleRef', 'PathRef',  'Test2 [mV]', 'ChanStructVarNameRef'};
        
            testCase.verifyError(@() FileListHeaders(h), 'K:FileListHeaders:assertCoreTextUniqAndNotContainingSpace:headers:containinsqbrckt');
            
            
        end
        
        function testObjWithInputWithSpace(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testObjWithInputWithSpace') ; disp(res);
            
            %% 'Test 1' is not allowed (a space is only allowed in front of [measuring unit])
            
            h = {'RecordTitle', 'ChanNumber', 'ChanTitle',  'Path', 'ChanStructVarName','ChanInfoClassName', ...
            'DataUnit', 'TimeUnit', 'Start [sec]', 'MaxTime [sec]', 'SRate [Hz]','SInterval [sec]',...
            'Length', 'Header', 'Test 1', 'ChanTitleRef', 'PathRef',  'Test2 [mV]', 'ChanStructVarNameRef'};
        
            testCase.verifyError(@() FileListHeaders(h), 'K:FileListHeaders:assertCoreTextUniqAndNotContainingSpace:headers:containingspace');

        end
        
        function testObjWithInputNotUniq(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testObjWithInputNotUniq') ; disp(res);
            
            %% Header elements (except measuring units) must be unique (Path is included twice)
            
            h = {'RecordTitle', 'ChanNumber', 'ChanTitle',  'Path', 'ChanStructVarName','ChanInfoClassName', ...
            'DataUnit', 'TimeUnit', 'Start [sec]', 'MaxTime [sec]', 'SRate [Hz]','SInterval [sec]',...
            'Length', 'Header', 'Path', 'ChanTitleRef', 'PathRef',  'Test2 [mV]', 'ChanStructVarNameRef'};
            
            testCase.verifyError(@() FileListHeaders(h), 'K:FileListHeaders:assertCoreTextUniqAndNotContainingSpace:headers:notunique');

        end
        
        function testAppendH(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testAppendH') ; disp(res);
            
            %% Header elements (except measuring units) must be unique
            
            obj = FileListHeaders;
            obj = obj.appendHeaders({'Test2', 'Test1 [sec]'}); % need to capture the result (not handle class)
            
            verifyEqual(testCase, obj.Headers, ...
                [testCase.defh, {'Test1 [sec]', 'Test2'}]);
 
        end
        
        function testDeleteH(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testDeleteH') ; disp(res);
            
            %% Header elements (except measuring units) must be unique
            
            obj = FileListHeaders;
            obj = obj.appendHeaders({'Test2', 'Test1 [sec]', 'Test3'}); % need to capture the result (not handle class)
            verifyEqual(testCase, obj.Headers, ...
                [testCase.defh, {'Test1 [sec]', 'Test2', 'Test3'}]);
            
            obj = obj.deleteHeaders({'Test2', 'Test1 [sec]'}); 
            
            verifyEqual(testCase, obj.Headers, ...
                 [testCase.defh, {'Test3'}]);
               
        end

        function testDeleteHwithCore(testCase)
            % clear;close all; clc; test1 = FileListHeaders_test; res =test1.run('testDeleteHwithCore') ; disp(res);
            
            %% Header elements (except measuring units) must be unique
            
            obj = FileListHeaders;
            obj = obj.appendHeaders({'Test2', 'Test1 [sec]', 'Test3'}); % need to capture the result (not handle class)
            verifyEqual(testCase, obj.Headers, ...
                [testCase.defh, {'Test1 [sec]', 'Test2', 'Test3'}]);
            
            obj = obj.deleteHeaders({'Test2', 'Test1'}); 
            
            verifyEqual(testCase, obj.Headers, ...
                 [testCase.defh, {'Test3'}]);
               
        end
        
        
        
    end
    
end

