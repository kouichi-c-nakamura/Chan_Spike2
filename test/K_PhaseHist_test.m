classdef K_PhaseHist_test  < matlab.unittest.TestCase
    %
    % clear;close all;clc; testCase=K_PhaseHist_test; res=testCase.run;disp(res);
    %
    % https://bitbucket.org/kouichi_c_nakamura/matlab-kouichi/issues/62/k_phasehist-related-plotting-functions
    %
    % See also
    % % K_PhaseHist
    % K_plotLinearPhaseHist
    % K_plotLinearPhaseHist_S  (to directly use output of K_PhaseHist as an input argument)
    % K_PhaseHist_histlabel    (add summary text to the plots made by K_PhaseHist)
    % K_plotCircPhaseHist_one, K_plotCircPhaseHist_group (for circular plots)
    % K_plotColorPhaseHist     (heatmap representation of phase coupling)
    % K_ECDFforRayleigh        (ECDF-based correction for Rayleigh's uniformity test)
    % K_PhaseHist_test         (UnitTest)
    %
    % Written by Kouichi C. Nakamura Ph.D.
    % MRC Brain Network Dynamics Unit
    % University of Oxford
    % kouichi.c.nakamura@gmail.com
    % 05-May-2017 09:33:08
    %
    %----------------------------------------------------------------------
    % 08-Jul-2016 22:41:07
    %
    % Totals:
    %    7 Passed, 0 Failed, 0 Incomplete.
    %    44.4272 seconds testing time.
    
    properties
        testdata1
        testdata2
        testdata3
    end
    
    methods (Test)
        function simpleRun(testCase)
            % testCase=K_PhaseHist_test; res=testCase.run('simpleRun');disp(res);
            
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.constraints.AbsoluteTolerance;

            testCase = testCase.prep_testdata;
            
            S = load(testCase.testdata1);
            sRate = 1/S.unite.interval;
            newRate = 1024;
            
            % make filter
            getNF = @(freq, Fs) freq/(Fs/2);
            [b, a] = butter(2, getNF([0.4, 1.6], newRate));
            fvtool(b,a,'Fs',newRate);
            xlim([0 5]);ylim('auto');
            assert(isstable(b,a));
            close
            
            results = K_PhaseHist(S.onset.values, S.IpsiEEG.values, sRate, newRate, b, a);
            
            testCase.verifyEqual(fieldnames(results),{...
                'unitrad';...
                'eegrad';...
                'eegpwelch';...
                'eegpwelchLow';...
                'ue_lres';...
                'ue_hres';...
                ...
                });
            
            %% unitrad
            testCase.verifyEqual(fieldnames(results.unitrad),{...
                'axang';...
                'axrad';...
                'histN';...
                'histnorm';...
                'unitrad';...
                'stats';...
                'cmean';...
                'rayl';...
                'raylecdf';...
                'vlen';...
                'cvar';...
                'cstd';...
                ...
                });
            

            testCase.verifyThat(results.unitrad.cmean, IsEqualTo(2.2609, ...
                'Within', AbsoluteTolerance(0.0001)));

            testCase.verifyThat(results.unitrad.vlen, IsEqualTo(0.5965, ...
                'Within', AbsoluteTolerance(0.0001)));

            testCase.verifyThat(results.unitrad.rayl, IsEqualTo(4.0034e-66, ...
                'Within', AbsoluteTolerance(0.0001e-66)));

            testCase.verifyThat(results.unitrad.raylecdf, IsEqualTo(3.1961e-68, ...
                'Within', AbsoluteTolerance(0.001e-68)));

            testCase.verifyThat(results.unitrad.cstd, IsEqualTo(0.8983, ...
                'Within', AbsoluteTolerance(0.0001)));

            testCase.verifyThat(results.unitrad.cvar, IsEqualTo(0.4035, ...
                'Within', AbsoluteTolerance(0.0001)));
            
            %% eegrad
            testCase.verifyEqual(fieldnames(results.eegrad),{...
                'axang';...
                'axrad';...
                'histN';...
                'histnorm';...
                'rayl';...
                'raylecdf';...
                'cmean';...
                'vlen';...
                ...
                });
            
            testCase.verifyThat(results.eegrad.rayl, IsEqualTo(2.7285e-203, ...
                'Within', AbsoluteTolerance(0.01e-203)));%TODO unstable, AbsoluteTolerance(0.0001e-203) fails
            
            testCase.verifyThat(results.eegrad.raylecdf, IsEqualTo(1, ...
                'Within', AbsoluteTolerance(0.0001)));
            
            testCase.verifyThat(results.eegrad.cmean, IsEqualTo(0.4419, ...
                'Within', AbsoluteTolerance(0.0001)));
            
            testCase.verifyThat(results.eegrad.vlen, IsEqualTo(0.0250, ...
                'Within', AbsoluteTolerance(0.0001)));
            
            %TODO
            % 'threshold' option
            
        end
        
        
        function K_plotLinearPhaseHist_one(testCase)
            % testCase=K_PhaseHist_test; res=testCase.run('K_plotLinearPhaseHist_one');disp(res);

            
            testCase = testCase.prep_testdata;
            
            S = load(testCase.testdata1);
            sRate = 1/S.unite.interval;
            newRate = 1024;
            
            % make filter
            getNF = @(freq, Fs) freq/(Fs/2);
            [b, a] = butter(2, getNF([0.4, 1.6], newRate));
            fvtool(b,a,'Fs',newRate);
            xlim([0 5]);ylim('auto');
            assert(isstable(b,a));
            close
            
            [results,handles] = K_PhaseHist(S.onset.values, S.IpsiEEG.values, sRate,...
                newRate, b, a,'plotECDF',true,'PlotLinear',true,'PlotCirc',true);         

            
            hlin = K_plotLinearPhaseHist(results.unitrad.unitrad);
            
            hlin = K_plotLinearPhaseHist(results.unitrad.unitrad, 'color', 'r',...
                'plottype','line');
            
            hlin = K_plotLinearPhaseHist(results.unitrad.unitrad, 'color', 'r',...
                'plottype','bar');
            
            testCase.verifyError(@()K_plotLinearPhaseHist(results.unitrad.unitrad, ...
                'plottype','hoge'),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            
            testCase.verifyError(@()K_plotLinearPhaseHist(results.unitrad.unitrad, ...
                'Color','f'),...
                'MATLAB:InputParser:ArgumentFailedValidation');
            
            testCase.verifyError(@()K_plotLinearPhaseHist(results.unitrad.unitrad, ...
                'Color',[0 0]),...
                'MATLAB:InputParser:ArgumentFailedValidation');          
            
            hlin = K_plotLinearPhaseHist(results.unitrad.unitrad, 'color', 'r',...
                'errorbar','std');% this is not group data so no error bar is shown
            
            hlin = K_plotLinearPhaseHist(results.unitrad.unitrad, 'color', 'r',...
                'Title','Neuron 1');
            
            %TODO 'radiansallpoints'
            % histc(?)
            
            
            hlin = K_plotLinearPhaseHist(results.unitrad.unitrad, 'color', 'r',...
                'XGrid','off');
            
            hlin = K_plotLinearPhaseHist(results.unitrad.unitrad, 18, 'color', 'k',...
                'plottype','bar');
            
            hlin = K_plotLinearPhaseHist(results.unitrad.unitrad, 18, 'color', 'k',...
                'rayleighecdf',results.unitrad.raylecdf);
            
            %% axh
            figure;
            axh = subplot(2,1,1);
            hlin = K_plotLinearPhaseHist(axh,results.unitrad.unitrad, 18, 'color', 'k',...
                'plottype','bar');
            
            close all
            
            %% Event with no spike
            nospk = false(size(S.onset.values));
            
            [results,handles] = testCase.verifyWarning(@() K_PhaseHist(nospk, S.IpsiEEG.values, sRate,...
                newRate, b, a,'plotECDF',true,'PlotLinear',true,'PlotCirc',true),...
                'K:K_plotLinearPhaseHist:radians:empty');
            
            hlin = testCase.verifyWarning(@() K_plotLinearPhaseHist(results.unitrad.unitrad),...
                'K:K_plotLinearPhaseHist:radians:empty');
            
            %TODO K_plotLinearPhaseHist and
            % K_plotCircPhaseHist_one/K_plotCircPhaseHist_group should be
            % renamed as
            % K_PhaseHist_plotLinear and
            % K_PhaseHist_plotCircOne/K_PhaseHist_plotCircGroup

        end
        
        function K_plotLinearPhaseHist_group(testCase)
            % testCase=K_PhaseHist_test; res=testCase.run('K_plotLinearPhaseHist_group');disp(res);
            
            testCase = testCase.prep_testdata;
            
            S1 = load(testCase.testdata1);
            S2 = load(testCase.testdata2);
            S3 = load(testCase.testdata3);
            
            S1.sRate = 1/S1.unite.interval;
            newRate = 1024;
            
            % make filter
            getNF = @(freq, Fs) freq/(Fs/2);
            [b, a] = butter(2, getNF([0.4, 1.6], newRate));
            fvtool(b,a,'Fs',newRate);
            xlim([0 5]);ylim('auto');
            assert(isstable(b,a));
            close
            
            results1 = K_PhaseHist(S1.onset.values, S1.IpsiEEG.values, 1/S1.unite.interval, newRate, b, a);
            results2 = K_PhaseHist(S2.onset.values, S2.IpsiEEG.values, 1/S2.unite.interval, newRate, b, a);
            results3 = K_PhaseHist(S3.onset.values, S3.IpsiEEG.values, 1/S3.unite.interval, newRate, b, a);

            radians = {results1.unitrad.unitrad,results2.unitrad.unitrad,results3.unitrad.unitrad};
            
            raylecdf = [results1.unitrad.raylecdf,results2.unitrad.raylecdf,results3.unitrad.raylecdf];
            
            h = K_plotLinearPhaseHist(radians,18); %TODO
            
            h = K_plotLinearPhaseHist(radians,18,'PlotType','bar');
            
            h = K_plotLinearPhaseHist(radians,18,'Errorbar','std');
            
            h = K_plotLinearPhaseHist(radians,18,'Errorbar','sem');

            h = K_plotLinearPhaseHist(radians,18,'PlotType','bar','Errorbar','std');
            h = K_plotLinearPhaseHist(radians,18,'PlotType','bar','Errorbar','sem');
            
            h = K_plotLinearPhaseHist(radians,18,'rayleighecdf',raylecdf);

            
            
            %% Identical three data
            radians2 = {results1.unitrad.unitrad,results1.unitrad.unitrad,results1.unitrad.unitrad};
            
            h = K_plotLinearPhaseHist(radians2,18,'Errorbar','std');
            
            h = K_plotLinearPhaseHist(radians2,18,'PlotType','bar','Errorbar','std');
            
            close all
        end
        
        function testCircularPhasePlot_one(testCase)
            % testCase=K_PhaseHist_test; res=testCase.run('testCircularPhasePlot_one');disp(res);

            testCase = testCase.prep_testdata;
            
            S = load(testCase.testdata1);
            sRate = 1/S.unite.interval;
            newRate = 1024;
            
            % make filter
            getNF = @(freq, Fs) freq/(Fs/2);
            [b, a] = butter(2, getNF([0.4, 1.6], newRate));
            fvtool(b,a,'Fs',newRate);
            xlim([0 5]);ylim('auto');
            assert(isstable(b,a));
            close
            
            [results,handles] = K_PhaseHist(S.onset.values, S.IpsiEEG.values, sRate,...
                newRate, b, a,'plotECDF',true,'PlotLinear',true,'PlotCirc',true);     
            
            radians = results.unitrad.unitrad;
            
            hcirc = K_plotCircPhaseHist_one(radians);

            hcirc = K_plotCircPhaseHist_one(radians, 18, 'color', 'g');

            hcirc = K_plotCircPhaseHist_one(radians,'Direction','anti');
            
            hcirc = K_plotCircPhaseHist_one(radians,'ZeroPos','bottom');

            hcirc = K_plotCircPhaseHist_one(radians,'HistLimPercent',20);
            
            %% axh
            figure;
            axh = subplot(2,1,1);
            hcirc = K_plotCircPhaseHist_one(axh,radians);
        
        end
        
        function testCircularPhasePlot_group(testCase)
            % testCase=K_PhaseHist_test; res=testCase.run('testCircularPhasePlot_group');disp(res);

            testCase = testCase.prep_testdata;
            
            S1 = load(testCase.testdata1);
            S2 = load(testCase.testdata2);
            S3 = load(testCase.testdata3);
            
            S1.sRate = 1/S1.unite.interval;
            newRate = 1024;
            
            % make filter
            getNF = @(freq, Fs) freq/(Fs/2);
            [b, a] = butter(2, getNF([0.4, 1.6], newRate));
            fvtool(b,a,'Fs',newRate);
            xlim([0 5]);ylim('auto');
            assert(isstable(b,a));
            close
            
            results1 = K_PhaseHist(S1.onset.values, S1.IpsiEEG.values, 1/S1.unite.interval, newRate, b, a);
            results2 = K_PhaseHist(S2.onset.values, S2.IpsiEEG.values, 1/S2.unite.interval, newRate, b, a);
            results3 = K_PhaseHist(S3.onset.values, S3.IpsiEEG.values, 1/S3.unite.interval, newRate, b, a);

            radians = {results1.unitrad.unitrad,results2.unitrad.unitrad,results3.unitrad.unitrad};
            
            raylecdf = [results1.unitrad.raylecdf,results2.unitrad.raylecdf,results3.unitrad.raylecdf];
            
            h = K_plotCircPhaseHist_group(radians);
            
            h = K_plotCircPhaseHist_group(radians,'Groupmean','on');

     
            h = K_plotCircPhaseHist_group(radians,'Direction','anti');

            h = K_plotCircPhaseHist_group(radians,'ZeroPos','bottom');
        
            h = K_plotCircPhaseHist_group(radians,'ZeroPos','right','Direction','anti');

        end
        
        function testECDF(testCase)
            %TODO
        end
        
        
        function testBadFilter(testCase)
            % testCase=K_PhaseHist_test; res=testCase.run('testBadFilter');disp(res);

            testCase = testCase.prep_testdata;
            
            S = load(testCase.testdata1);
            sRate = 1/S.unite.interval;
            newRate = 1024;
            
            % make filter
            getNF = @(freq, Fs) freq/(Fs/2);
            [b, a] = butter(2, getNF([0.4, 1.6], newRate));
            fvtool(b,a,'Fs',newRate);
            xlim([0 5]);ylim('auto');
            assert(isstable(b,a));
            close
            
            results = K_PhaseHist(S.onset.values, S.IpsiEEG.values, sRate, newRate, b, a);
            
            testCase.verifyEqual(fieldnames(results),{...
                'unitrad';...
                'eegrad';...
                'eegpwelch';...
                'eegpwelchLow';...
                'ue_lres';...
                'ue_hres';...
                ...
                });
            
            testCase.verifyEqual(fieldnames(results.unitrad),{...
                'axang';...
                'axrad';...
                'histN';...
                'histnorm';...
                'unitrad';...
                'stats';...
                'cmean';...
                'rayl';...
                'raylecdf';...
                'vlen';...
                'cvar';...
                'cstd';...
                ...
                });
            
            
            results = K_PhaseHist(S.onset.values, S.IpsiEEG.values, sRate, newRate, b, a);

            
            
            %TODO how to validate the results?
            % examine results?
            % examine plot?
            
            
        end

        
    end
    
    methods
        function testCase = prep_testdata(testCase)
            
            startdir = fileparts(which('startup'));
            endind = regexp(startdir,regexptranslate('escape','Private_Dropbox'),'end');
            if ~isempty(endind)
                
                testCase.testdata1 = fullfile(startdir(1:endind),...
                    'Kouichi MATLAB data','thalamus','S potentials','HF pauser',...
                    'PC','SWA','kjx021i01_i02_spliced.mat');
                
                testCase.testdata2 = fullfile(startdir(1:endind),...
                    'Kouichi MATLAB data','thalamus','S potentials','HF pauser',...
                    'PC','SWA','kjx040e01e02spliced.mat'); %TODO for group analysis

                testCase.testdata3 = fullfile(startdir(1:endind),...
                    'Kouichi MATLAB data','thalamus','S potentials','HF pauser',...
                    'PC','SWA','kjx019f02@300-828.mat'); %TODO for group analysis
                
            else
                error('move to the folder "%s"',fullfile('Kouichi MATLAB data','thalamus'))
            end
            
        end
        
    end
    
    
    
    
end

function local





%K_PhaseHist_script
clear;close all;clc;

load('Z:\Dropbox\Private_Dropbox\Kouichi MATLAB data\thalamus\S potentials\HF pauser\PC\SWA\kjx021i01_i02_spliced.mat');
srate = 1/unite.interval;

smalle_ts= EventChan(smalle.values, 0, srate, 'smalle');
eegw_ts = WaveformChan(IpsiEEG.values, 0, srate, 'eeg');
unite_ts = EventChan(unite.values, 0, srate, 'unite');
onset_ts = EventChan(onset.values, 0, srate, 'onset');

newRate = 1024;

% make filter
getNF = @(freq, srate) freq/(srate/2);
[b, a] = butter(2, getNF([0.4, 1.6], newRate));

[results] = K_PhaseHist(onset_ts.Data, eegw_ts.Data, srate, newRate, b, a);

[results, handles] = K_PhaseHist(onset_ts.Data, eegw_ts.Data, srate, newRate, b, a,...
    'plotECDF', true);



[results] = K_PhaseHist(onset_ts.Data, eegw_ts.Data, srate, newRate, b, a,...
    'plotLinear', true);

[results] = K_PhaseHist(onset_ts.Data, eegw_ts.Data, srate, newRate, b, a,...
    'plotCirc', true);

u = results.unitrad;

%method plotPhaseHist
[results] = onset_ts.plotPhaseHist(eegw_ts,  'plotECDF', true); %TODO to be implemented into a test case

% threshold
[results] = onset_ts.plotPhaseHist(eegw_ts, 'threshold', [0.02, 0.25], 'plotECDF', true);



%% transform [-pi, pi] to [0, 4*pi]
twopi = @(x) circshift(repmat(x, 2, 1), round(size(x, 1)/2));

ang2rad = @(x) x * pi /180;
rad2ang = @(x) x/pi*180;

%% plot linear phase histogram

ax(1) = subplot('Position', [0.13, 0.11, 0.775, 0.75]);
ax(2) = subplot('Position', [0.13, 0.87, 0.775, 0.10]);


x = twopi(u.axrad);
x = round(rad2ang(unwrap([x(end);x;x(1)]))); % 2 cylces + alpha
y = twopi(u.histnorm*100);
y = [y(end); y; y(1)]; % 2 cylces + alpha

lh1= plot(ax(1), x, y, 'LineWidth', 2);
xtic = cellfun(@(x) [num2str(x), '?'], num2cell(0:90:720), 'UniformOutput', false);
set(ax(1), 'TickDir', 'out', 'Box', 'off',...
    'XTick', 0:90:720, 'XTickLabel', xtic,...
    'XLim', [0, 720]);

hold(ax(1)) % doesn't work
lh2= plot(ax(1),[90:90:720;90:90:720], ylim(ax(1))', 'Color', [0.5 0.5 0.5]);
uistack (lh2, 'bottom');
xlabel(ax(1),'Phase');
ylabel(ax(1), 'Firing Probabiliy per 10? [%]');

%% subplot for cosine curve

x2 = linspace(0, 720, 1440);
y2 = cos(ang2rad(x2));
plot(ax(2), x2, y2, 'Color' , 'k', 'LineWidth', 2);
set(ax(2), 'Visible', 'off', 'XLim', [0, 720], 'YLim', [-1.1, 1.1]);



%% plot linear phase histogram
h = K_plotLinearPhaseHist(u.unitrad, 72);





%% plot circular phase histogram
% h = CircularPlotSingle_KCN(cmean, veclen, radians, color1, axh, omitcircles, zero_pos, direction)

% h = K_circularPlot_oneCell(u.unitrad);
% h = K_circularPlot_oneCell(u.unitrad, 'Color', 'g',...
%     'zeropos', 'bottom', 'dir', 'anti');
% h = K_circularPlot_oneCell(gca, u.unitrad);


% h = K_circularPlot_oneCell(u.unitrad, 'Histbin', 36);
% h = K_circularPlot_oneCell(u.unitrad, 'Histbin', 36, 'HistLimPercent', 12);
% h = K_circularPlot_oneCell(u.unitrad, 'Histbin', 36, 'HistLimPercent', 0);


%% built-in plots
rose(u.unitrad)

pol = polar(u.unitrad,ones(size(u.unitrad)));
set(pol, 'LineStyle', 'none', 'Marker', 'o')

circ_plot(u.unitrad, 'pretty');
circ_plot(u.unitrad, 'hist');
circ_plot(u.unitrad, 'density');

%%
datacell = [fieldnames(results)';...
    struct2cell(results)'];
data = cell2dataset(datacell, 'ObsName', {'kjx021i'})
openvar('data');

datacell(2, 11)





end

