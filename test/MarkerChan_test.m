classdef MarkerChan_test < matlab.unittest.TestCase
    % MarkerChan_test < matlab.unittest.TestCase
    % clear;close all;clc; testCase = MarkerChan_test; disp(testCase.run);
    %
    % Passed on 3/2/2015 12:54
    % Totals:
    %    5 Passed, 0 Failed, 0 Incomplete.
    %    6.3424 seconds testing time.
    
    properties
        
    end
    
    methods (Test)
        
        function test_noinputarg(testCase)
            % disp(testCase.run('test_noinputarg'));
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
 
            M = MarkerChan;
            disp(M)
            
        end
        
        function test_simplecase(testCase)
            % clear;close all;clc; testCase = MarkerChan_test; disp(testCase.run('test_simplecase'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            
            Fs = 1000;
            rng('default');
            events = double(logical(poissrnd(30/Fs, 1000, 1)));
            
            ind1 = find(events);
            
            codes  = logical(poissrnd(3/10, length(ind1), 1)) ...
                + logical(poissrnd(2/10, length(ind1), 1)) .*2 ...
                + logical(poissrnd(1/10, length(ind1), 1)) .*3 ;
            
            M = MarkerChan(events, 0, Fs, codes, 'test1'); % 370 byte
            h = M.plot;
            M.testProperties;
            
            testCase.verifyEqual(M.NSpikes, 24);
            testCase.verifyEqual(M.ChanTitle, 'test1');
            testCase.verifyEqual(M.SRate, 1000);
            testCase.verifyEqual(M.Length, 1000);
            testCase.verifyEqual(M.MaxTime, 0.9990);
            
            currentdir = pwd; %TODO use WokringFolderFixture class?
            cd(fileparts(which('MarkerChan.m')));
            save('M','M')
            S = load('M');
            S.M.testProperties;
            testCase.verifyEqual(M,S.M)
            delete('M.mat')
            cd(currentdir)
            
        end
        
        function test_Spike2data(testCase)
            % clear;close all;clc; testCase = MarkerChan_test; disp(testCase.run('test_Spike2data'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            path = (fileparts(which('MarkerChan.m')));
            
            S_mark = load(fullfile(path, 'BinFreq0MarkAs1.mat')); % S1.demo_LTSmk
            S_binned = load(fullfile(path, 'BinFreq17000MarkAs0.mat')); % S2.demo_LTSmk
            S_textmark = load(fullfile(path, 'BinFreq0TMarkAs2.mat')); % S3.demo_textmk
            
            %% you need to get start and sRateNew from another binned channel
            
            data  = S_binned.demo_LTSmk.values;
            start = S_binned.demo_LTSmk.start;
            srate = 1/S_binned.demo_LTSmk.interval;
            name  = S_binned.demo_LTSmk.title;
            codes = S_mark.demo_LTSmk.codes;
            
            M1 = MarkerChan(data, start, srate, codes, name);
            M1.testProperties;
            
            %% you need to get start and sRateNew from another binned channel
            
            % Marker channel
            M2 = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);
            M2.testProperties;
            
            % TextMark channel
            M3 = MarkerChan(S_textmark.demo_textmk, S_binned.demo_LTSmk);
            M3.testProperties;
            
            
            testCase.verifyEqual(find(M1.Data ~= M2.Data), [13491;13492]); % they differ at one data point probably due to rounding error
            testCase.verifyEqual(M1.IsMarkerFilterOn, M2.IsMarkerFilterOn);
            testCase.verifyEqual(M1.MarkerCodes, M2.MarkerCodes);
            testCase.verifyEqual(M1.FiringRate, M2.FiringRate);
            testCase.verifyEqual(M1.NSpikes, M2.NSpikes);
            testCase.verifyEqual(M1.Length, M2.Length);
            testCase.verifyEqual(M1.MaxTime, M2.MaxTime);
            
            testCase.verifyEqual(M3.Data, M2.Data);
            testCase.verifyEqual(M3.IsMarkerFilterOn, M2.IsMarkerFilterOn);
            testCase.verifyEqual(M3.MarkerCodes, M2.MarkerCodes);
            testCase.verifyEqual(M3.FiringRate, M2.FiringRate);
            testCase.verifyEqual(M3.NSpikes, M2.NSpikes);
            testCase.verifyEqual(M3.Length, M2.Length);
            testCase.verifyEqual(M3.MaxTime, M2.MaxTime);
            
            testCase.verifyEqual(M3.TextMark(1:5), ...
                {'adagadgadg';'adfa';'ssssssssssss';'da daf a';''})
            
        end
        
        function test_Spike2data_methods(testCase)
            % clear;close all;clc; testCase = MarkerChan_test; disp(testCase.run('test_Spike2data_methods'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            path = (fileparts(which('MarkerChan.m')));
            
            S_mark = load(fullfile(path, 'BinFreq0MarkAs1.mat')); % S1.demo_LTSmk
            S_binned = load(fullfile(path, 'BinFreq17000MarkAs0.mat')); % S2.demo_LTSmk
            
            %% you need to get start and sRateNew from another binned channel
            
            % Marker channel
            M = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);
            
            
            %% MarkerCodes subsasgn
            testCase.verifyEqual(table2array(M.MarkerCodes(2,:)), uint8([0, 0, 0, 0])); 
            M.MarkerCodes(2,:) = [100, 100, 100, 100];
            testCase.verifyEqual(table2array(M.MarkerCodes(2,:)), uint8([100, 100, 100, 100]));
            
            %% getSpikeInfo
            spikeinfo = M.getSpikeInfo; %TODO
            openvar('spikeinfo');
            % keyboard
            
            %% resample
            
            M0 = M.resample(1000); %OK 10:39 28/02/2014
            figure;
            ax1 = subplot(2,1,1);
            ax2 = subplot(2,1,2);
            M.plot(ax1);
            M0.plot(ax2);
            linkaxes([ax1 ax2], 'x');
            testCase.verifyEqual(M.SRate, 17000);
            testCase.verifyEqual(M0.SRate, 1000);
            
            
            %% extractTime
                        
            
            M0.TextMark = 'code'+ string(M0.MarkerCodes{:,1});
            
            M1 = M0.extractTime(20,70,'normal');
                        
            testCase.verifyEqual(M0.NSpikes, 98);
            testCase.verifyEqual(M1.NSpikes, 50);

            testCase.verifyEqual(length(M1.TextMark), 50);
            
            M1.plot
            
            
            %% extractTime extend
            
                       
            M2 = M0.extractTime(-10,10,'extend');
                        
            testCase.verifyEqual(M2.NSpikes, 14);

            testCase.verifyEqual(length(M2.TextMark), 14);
            
            M2.plot
            
            
            M3 = M0.extractTime(90,105,'extend'); 
                        
            testCase.verifyEqual(M3.NSpikes, 10);

            testCase.verifyEqual(length(M3.TextMark), 10);
            
            M3.plot         
            
            
        end
        
        function test_Spike2data_setData_setMarkerCodes_setTextMark(testCase)
            % clear;close all;clc; testCase = MarkerChan_test; disp(testCase.run('test_Spike2data_setData_setMarkerCodes_setTextMark'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            path = (fileparts(which('MarkerChan.m')));
            
            S_mark = load(fullfile(path, 'BinFreq0MarkAs1.mat')); % S1.demo_LTSmk
            S_binned = load(fullfile(path, 'BinFreq17000MarkAs0.mat')); % S2.demo_LTSmk
            
            
            %% you need to get start and sRateNew from another binned channel
            
            % Marker channel
            M = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);
            
            testCase.verifyEqual(table2array(M.MarkerCodes(1:3,1)), uint8([1;0;1]));
            testCase.verifyEqual(M.Data(1), 0);
            M.Data(1) = 1;
            testCase.verifyEqual(M.Data(1), 1);
            
            testCase.verifyEqual(M.Data(1:3), [1;0;0]);
            M.Data(1:3) = [1;1;1];
            testCase.verifyEqual(M.Data(1:3), [1;1;1]);
            
            testCase.verifyEqual(table2array(M.MarkerCodes(1:3,1)), uint8([0;0;0])); % Addition of spikes pads 0 MarkerCodes accordingly
            M.MarkerCodes(1) = 5;
            testCase.verifyEqual(table2array(M.MarkerCodes(1,1)), uint8(5));
            
            testCase.verifyError(@()table2array(M.MarkerCodes(1)),...
                'MATLAB:table:NDSubscript');
            
            testCase.verifyEqual(table2array(M.MarkerCodes(1:2,1)), uint8([5;0]));
            M.MarkerCodes(1:2) = [10;10];
            testCase.verifyEqual(table2array(M.MarkerCodes(1:2,1)), uint8([10;10]));
            
            testCase.verifyError(@()table2array(M.MarkerCodes(1:2)),...
                'MATLAB:table:NDSubscript');
            
            
            
            
            testCase.verifyEqual(M.TextMark{1}, '');
            M.TextMark(1) = {'What the fuck are you doing?'};
            testCase.verifyEqual(M.TextMark{1}, 'What the fuck are you doing?');
            
            testCase.verifyEqual(M.TextMark{2}, '');
            M.TextMark(1:2) = {'What the fuck are you doing!?';'Breathing.'};
            testCase.verifyEqual(M.TextMark{1}, 'What the fuck are you doing!?');
            testCase.verifyEqual(M.TextMark{2}, 'Breathing.');
            
            testCase.verifyEqual(length(M.Data), 1700000);
            M.Data = zeros(20,1);
            testCase.verifyEqual(length(M.Data), 20);
            testCase.verifyEqual(M.Data, zeros(20,1));
            
            
        end
        
        function test_Spike2data_setMarkerFilter_subsasgn(testCase)
            % clear;close all;clc; testCase = MarkerChan_test; disp(testCase.run('test_Spike2data_setMarkerFilter_subsasgn'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            path = (fileparts(which('MarkerChan.m')));
            
            S_mark = load(fullfile(path, 'BinFreq0MarkAs1.mat')); % S1.demo_LTSmk
            S_binned = load(fullfile(path, 'BinFreq17000MarkAs0.mat')); % S2.demo_LTSmk
            
            
            %% you need to get start and sRateNew from another binned channel
            
            % Marker channel
            M = MarkerChan(S_mark.demo_LTSmk, S_binned.demo_LTSmk);
            
            
            %% subsref works fine by default
            openvar('M.MarkerFilter');
            
            disp(M.MarkerFilter(1:5,:)); %OK
            disp(M.MarkerFilter('value1',:)) %OK
            disp(M.MarkerFilter(1:10,'mask2')) %OK
            
            %% subsasgn
            
            disp(M.MarkerFilter); %OK
            testCase.verifyEqual(M.MarkerFilter.mask0('value1'), true);
            
            M.MarkerFilter{'value1', 'mask0'} = false; %TODO
            testCase.verifyEqual(M.MarkerFilter.mask0('value1'), false);
            
            M.MarkerFilter{'value1', 'mask0'} = 1;
            testCase.verifyEqual(M.MarkerFilter.mask0('value1'), true);
           
            M.MarkerFilter{2, 1} = false;

            testCase.verifyEqual(M.MarkerFilter.mask0('value1'), false);
            
%             mexc1 = [];
%             try
                M.MarkerFilter(2, :) = false; % ALLOWED
%             catch mexc1
%             end
%             testCase.verifyError(@() throw(mexc1), 'MATLAB:table:InvalidRHS');

            M.MarkerFilter(2, 2) = false; % () and {} are both valid %TODO
            M.MarkerFilter(2, 3) = false;
            M.MarkerFilter(2, 4) = false;
            testCase.verifyEqual(M.MarkerFilter.mask1('value1'), false);
            testCase.verifyEqual(M.MarkerFilter.mask2('value1'), false);
            testCase.verifyEqual(M.MarkerFilter.mask3('value1'), false);

            M.MarkerFilter = [];
            testCase.verifyEqual(all(M.MarkerFilter.mask0 & M.MarkerFilter.mask1 &...
                M.MarkerFilter.mask2 & M.MarkerFilter.mask3), true);
          
            M.MarkerFilter = 'hide';
            testCase.verifyEqual(all(M.MarkerFilter.mask0 & M.MarkerFilter.mask1 &...
                M.MarkerFilter.mask2 & M.MarkerFilter.mask3), false);           
            
            M.MarkerFilter = 'show';  
            testCase.verifyEqual(all(M.MarkerFilter.mask0 & M.MarkerFilter.mask1 &...
                M.MarkerFilter.mask2 & M.MarkerFilter.mask3), true);           
            
            M.MarkerFilter = 'hide';
            M.MarkerFilter(1:5,1) = 'show'; 
            testCase.verifyEqual(all(M.MarkerFilter.mask0(1:5)), true);
            testCase.verifyEqual(all(M.MarkerFilter.mask0(6:end)), false);
            testCase.verifyEqual(all(M.MarkerFilter.mask1 &...
                M.MarkerFilter.mask2 & M.MarkerFilter.mask3), false);             
            
            M.MarkerFilter = [];
            M.MarkerFilter = false(256,4);
            testCase.verifyEqual(all(M.MarkerFilter.mask0 & M.MarkerFilter.mask1 &...
                M.MarkerFilter.mask2 & M.MarkerFilter.mask3), false);
            
            M.MarkerFilter = [];
            M.MarkerFilter(2:5,1) = false(4,1);
            testCase.verifyEqual(all(M.MarkerFilter.mask0(2:5)), false);
            testCase.verifyEqual(all(M.MarkerFilter.mask0([1,6:end])), true);
            testCase.verifyEqual(all(M.MarkerFilter.mask1 &...
                M.MarkerFilter.mask2 & M.MarkerFilter.mask3), true);
            
            M.MarkerFilter(2:5,1) = []; 
            testCase.verifyEqual(all(M.MarkerFilter.mask0 & M.MarkerFilter.mask1 &...
                M.MarkerFilter.mask2 & M.MarkerFilter.mask3), true);          
            
            M.MarkerFilter(2:5,1) = 'hide'; % hide subset
            testCase.verifyEqual(all(M.MarkerFilter.mask0(2:5)), false);
            testCase.verifyEqual(all(M.MarkerFilter.mask0([1,6:end])), true);
            testCase.verifyEqual(all(M.MarkerFilter.mask1 &...
                M.MarkerFilter.mask2 & M.MarkerFilter.mask3), true);
                        
            M.MarkerFilter(1:2, 1) = [false;true]; % multiple assignment allowed for ()
            testCase.verifyEqual(M.MarkerFilter.mask0(1:2), [false;true]);

            M.MarkerFilter([1:3,5], 1) = [1; 0; 1 ; 1]; % allowed for ()
            testCase.verifyEqual(M.MarkerFilter.mask0([1:3,5]), [true;false;true;true]);
            
            M.MarkerFilter = [];
            M.MarkerFilter{1:2, 1} = [true; false]; % multiple assignment is allowed for {}

            %% <NOT ALLOWED>
            M.MarkerFilter = [];
            
            try
                M.MarkerFilter = [false; false] ; % 'the number of rows in newstate must be 256.'
            catch mexc1
            end
            testCase.verifyError(@() throw(mexc1), ...
                'K:MarkerFilter:newstate:rows');

            try
                 M.MarkerFilter = table(false, 'VariableNames', {'mask0'}, 'RowNames', {'value1'});  % 'the number of rows in newstate must be 256.'
            catch mexc1
            end
            testCase.verifyError(@() throw(mexc1), ...
                'K:MarkerFilter:newstate:rows');
           
            
            try
                  M.MarkerFilter = false;  % 'the number of rows in newstate must be 256.'
            catch mexc1
            end
            testCase.verifyError(@() throw(mexc1), ...
                'K:MarkerFilter:newstate:rows');            
            
            
            
        end
        
        function test_Spike2data_MarkerFilter(testCase)
            % clear;close all;clc; testCase = MarkerChan_test; disp(testCase.run('test_Spike2data_MarkerFilter'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            Fs = 1000;
            rng('default');
            events = double(logical(poissrnd(30/Fs, 1000, 1)));
            
            ind1 = find(events);
            codes  = logical(poissrnd(3/10, length(ind1), 1)) ...
                + logical(poissrnd(2/10, length(ind1), 1)) .*2 ...
                + logical(poissrnd(1/10, length(ind1), 1)) .*3
            
            M = MarkerChan(events, 0, Fs, codes, 'test1'); % 370 byte
            M.plot;
            
            testCase.verifyEqual(M.NSpikes, 24)
            
            disp(M.MarkerCodes)

            
            M.MarkerFilter = 'hide';
            disp(M.MarkerFilter)
            disp(M.MarkerCodes)

            testCase.verifyEqual(M.NSpikes, 0)
            
            M.MarkerFilter = 'show';
            disp(M.MarkerFilter)
            disp(M.MarkerCodes)

            testCase.verifyEqual(M.NSpikes, 24)
            
            M.MarkerFilter{'value0',1} = false;
            M.MarkerFilter{'value2',1} = false;
            disp(M.MarkerFilter)
            testCase.verifyEqual(M.MarkerFilter{1,1}, false)
            testCase.verifyEqual(M.MarkerFilter{2,1}, true)
            testCase.verifyEqual(M.MarkerFilter{3,1}, false)
            testCase.verifyEqual(M.MarkerFilter{4,1}, true)
 
            testCase.verifyEqual(M.NSpikes, 9)
            
            testCase.verifyEqual(size(M.getSpikeInfo,1), 9)
            testCase.verifyEqual(size(M.getSpikeInfoAll,1), 24)
                                    
            M.plot
            
        end
        
    end
    
end

