classdef LTSburst_test < matlab.unittest.TestCase
    % LTSburst_test < matlab.unittest.TestCase
    % clear;close all; clc; testCase = LTSburst_test; res =testCase.run ; disp(res);
    %
    % See also
    % LTSburst, K_LTSburst_groupplot, K_LTSburst_detect
    
    properties
        homedir = fileparts(which('LTSburst'));
        demofile1 =  fullfile(fileparts(which('LTSburst')),'kjx006a01@200-300.mat');
        demofile2 =  fullfile(fileparts(which('LTSburst')),'kjx010a01@170-270.mat');
        demofile3 =  fullfile(fileparts(which('LTSburst')),'kjx015b01@0-100.mat');
        
        %TODO add Hirai TRN-S1 data to the folder as a better example
    end
    
    methods (Test)
        
        function constructor(testCase)
            % clear;close all; clc; testCase = LTSburst_test; res =testCase.run('constructor') ; disp(res);
            
            S1 = load(testCase.demofile1);
            S2 = load(testCase.demofile2);
            S3 = load(testCase.demofile3);
            
            R1 = Record(testCase.demofile1);
            R2 = Record(testCase.demofile2);
            R3 = Record(testCase.demofile3);
            
            %% No input
            bst0 = LTSburst;
            disp(bst0)
            testCase.verifyTrue(all(checkproperties(bst0)));
            
            %% Column vector of 0 or 1
            bst1 = LTSburst(S1.unite.values,1/S1.unite.interval);
            testCase.verifyEqual(bst1.PreburstSilence_ms, 100);
            testCase.verifyTrue(all(checkproperties(bst1)));
            
            
            %% Cell vector of column vectors of 0 or 1
            bst2 = LTSburst({S1.unite.values},1/S1.unite.interval);
            testCase.verifyEqual(bst1,bst2);
            testCase.verifyTrue(all(checkproperties(bst2)));
            
            testCase.verifyTrue(iscell(bst2.Spike));
            testCase.verifyTrue(isa(bst2.Spike{1}, 'double'));
            testCase.verifyTrue(issparse(bst2.Spike{1})); %sparse double array
            
            
            testCase.verifyError(@() LTSburst({S1.unite.values,S1.unite.values},1/S1.unite.interval),...
                'K:LTSburst:setFs:length:invalid');
            
            bst3 = LTSburst({S1.unite.values,S2.unite.values,S3.unite.values},...
                [1/S1.unite.interval,1/S2.unite.interval,1/S3.unite.interval]);
            disp(bst3);
            testCase.verifyEqual(size(bst3.ISIordinal),[1,3]);
            testCase.verifyEqual(size(bst3.ISIordinalmeta_perRecord),[5,4]);
            testCase.verifyTrue(all(checkproperties(bst3)));
            
            
            
            %% Record object as input
            
            bst4 = LTSburst(R1);
            testCase.verifyEqual(size(bst4.SpikeInfo{1}),[149,1]);
            testCase.verifyEqual(bst4.Names,{'kjx006a01@200-300.mat|unite'});
            testCase.verifyTrue(all(checkproperties(bst4)));
            
            
            %% cell vector of Record objects as input
            
            bst5 = LTSburst({R1,R2,R3});
            disp(bst5);
            testCase.verifyTrue(all(checkproperties(bst5)));
            
            
            testCase.verifyTrue(iscell(bst5.Spike));
            testCase.verifyTrue(isa(bst5.Spike{1}, 'double'));
            testCase.verifyTrue(issparse(bst5.Spike{1})); %sparse double array
            
            testCase.verifyEqual(bst5.Names,...
                {'kjx006a01@200-300.mat|unite',...
                'kjx010a01@170-270.mat|unite',...
                'kjx015b01@0-100.mat|unite'});
            
            
            %% EventChan as input
            bst6 = LTSburst(R1.unite);
            disp(bst6)
            testCase.verifyTrue(all(checkproperties(bst6)));
            
            
            
            %% cell vector of EventChan as input
            bst7 = LTSburst({R1.unite,R2.unite,R3.unite});
            disp(bst7)
            testCase.verifyEqual(bst7.Names,...
                {'unite',...
                'unite',...
                'unite'});
            testCase.verifyTrue(all(checkproperties(bst7)));
            
            
            
            %% No spike input
            bst8 = LTSburst(zeros(10000,1),10000);
            testCase.verifyTrue(all(checkproperties(bst8)));
            
            bst9 = LTSburst({S1.unite.values,zeros(10000,1)},...
                [1/S1.unite.interval,1/S1.unite.interval]);
            testCase.verifyTrue(all(checkproperties(bst9)));
            
            
            %% No spike input
            empty = EventChan(zeros(10000,1),0,10000);
            bst10 = LTSburst(empty);
            testCase.verifyTrue(all(checkproperties(bst10)));
            
            %% only one burst included
            %TODO
            
            keyboard
            noburst = EventChan(repmat([1;zeros(9999,1)],100,1),0,10000);
            bst11 = LTSburst(noburst);
            disp(bst11)
            testCase.verifyTrue(all(checkproperties(bst11))); 
            
            bst11.plotFistISI;
            
            bst11.plotISIordinal;

            
            %% Wrong syntax; Fs is missing
            testCase.verifyError(@() LTSburst(S1.unite.values),...
                'K:LTSburst:LTSburst:narginOne:syntax:invalid');
            
            testCase.verifyError(@() LTSburst({S1.unite.values}),...
                'K:LTSburst:LTSburst:narginOne:syntax:invalid');
            
            
        end
        
        function methods(testCase)
            % clear;close all; clc; testCase = LTSburst_test; res =testCase.run('methods') ; disp(res);

            R1 = Record(testCase.demofile1);
            R2 = Record(testCase.demofile2);
            R3 = Record(testCase.demofile3);
            bst1 = LTSburst({R1,R2,R3});
            
            bst1.plotFistISI
            
            bst1.plotISIbefaft
            
            bst1.plotISIordinal
            
            % only subset of data to plot
            bst1.plotISIordinal('spikerange',[2,3,5])
            
            bst1.plotTimeView
            
            %TODO effect of changing the parameters on plots.
            
            %TODO examine outputs?
            
            %TODO put parameters into figures
            
        end
        
        
        
        
    end
    
    
    
end