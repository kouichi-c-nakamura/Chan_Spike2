classdef WaveMarkChan_test < matlab.unittest.TestCase
    % clear;close all;clc; testCase = WaveMarkChan_test; disp(testCase.run);
    %
    % See also
    % WaveMarkChan, MarkerChan
    
    properties
        
    end
    
    
    methods (Test)
        
        function test_simple(testCase)
            % clear;close all;clc; testCase = WaveMarkChan_test; disp(testCase.run('test_simple'));
            
            
            S = load(fullfile(fileparts(which('WaveMarkChan')),'kjx021I01_i02_spliced_30_wm.mat'));
            
            traces = S.nw_3.values;
            
            codes = S.nw_3.codes;
            
            yy = timestamps2binned(S.nw_3.times,0,20,17000,'normal');
            
            wm = WaveMarkChan(yy, 0, 17000, codes, traces, S.nw_3.scale, S.nw_3.offset, S.nw_3.trigger, 'nw_3')
            testCase.verifyEqual(wm.NSpikes,1618)
            
            wm.plot
            
            
            wm.MarkerFilter{'value1',1} = false;
            
            testCase.verifyEqual(wm.NSpikes,363) % code1 is hidden
            
            testCase.verifyEqual(size(wm.Traces),[363 40])
            
            wm.plot

            
            %% extractTIme method
            
            wm.MarkerFilter = [];
            
            wm1 =  wm.extractTime(5,10,'normal')
            
            wm1.plot
            
            
                         
            wm2 = wm.extractTime(-5,5,'extend') 
            
            wm2.plot
            
            
            wm3 = wm.extractTime(15,22,'extend')
            
            wm3.plot 
            
        
        
        end
        
        function test2(testCase) % NOT WORKING
            % testCase = WaveMarkChan_test; disp(testCase.run('test2'));
            S = load(fullfile(fileparts(which('WaveMarkChan')),'kjx021I01_i02_spliced_30_wm.mat'));
            
            traces = S.nw_3.values;
            
            codes = S.nw_3.codes;
            
            yy = timestamps2binned(S.nw_3.times,0,20,17000,'normal');
            
            wm = WaveMarkChan(yy, 0, 17000, codes, traces, S.nw_3.scale, S.nw_3.offset, S.nw_3.trigger, 'nw_3')

            
            currentdir = pwd; %TODO use WokringFolderFixture class?
            cd(fileparts(which('WaveMarkChan.m')));
            save('wm','wm')
            S = load('wm');
            S.wm.testProperties;
            testCase.verifyEqual(wm,S.wm)
            delete('wm.mat')
            cd(currentdir)
     
            
            
        end
        
        
        
        
        
    end
    
    
    
    
end