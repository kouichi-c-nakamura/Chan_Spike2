classdef plotPowerSpectra_parse_test < matlab.unittest.TestCase
    %plotPowerSpectra_parse_test < matlab.unittest.TestCase
    %
    % clear;close all;clc;testCase = XXXXX_test;res = testCase.run;disp(res);
    %
    %
    % See also
    % WaveformChan.plotPowerSpectra, WaveformChan.plotCohere
    %
    % Passed 
    % 01-Jul-2016 10:35:47
    % Totals:
    %    1 Passed, 0 Failed, 0 Incomplete.
    %    0.33699 seconds testing time.
    
    properties
        int16matname = fullfile(fileparts(which('WaveformChan.m')), 'kjx127a01@0-20_int16.mat');
        
    end
    
    methods (Test)
        function test1(testCase)
            % clear;close all;clc; testCase = plotPowerSpectra_parse_test; disp(testCase.run('test1'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            load(testCase.int16matname);
            
            W = WaveformChan(EEG.values, 0, 1/EEG.interval, EEG.scale, EEG.offset, 'EEG'); %int16
            W.testProperties;
            
            W2 = W.resample(1024);
                        
            
            %% parse(W)
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W);
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,1024);
            testCase.verifyEqual(window,1024);
            testCase.verifyEqual(noverlap,512);
            testCase.verifyEqual(nfft,1024);
            testCase.verifyEqual(xrange,[0 100]);
            testCase.verifyEqual(yrange,[0 1e-4]);
            testCase.verifyEqual(plottype,'line');
            testCase.verifyEqual(axh,[]);01-Jul-2016 10:35:36

            
            clear obj newRate window noverlap nfft xrange yrange plottype axh
            
            %% parse(W2)
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W2);
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,1024);
            testCase.verifyEqual(window,256);
            testCase.verifyEqual(noverlap,128);
            testCase.verifyEqual(nfft,256);
            testCase.verifyEqual(xrange,[0 100]);
            testCase.verifyEqual(yrange,[0 1e-4]);
            testCase.verifyEqual(plottype,'line');
            testCase.verifyEqual(axh,[]);
            
            clear obj newRate window noverlap nfft xrange yrange plottype axh
            
            
            %% parse(W,newRate,window,nfft)
            newRate = 2048;
            window = 2048;
            nfft = 2048;
            
            
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W,newRate,window,nfft);
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,2048);
            testCase.verifyEqual(window,2048);
            testCase.verifyEqual(noverlap,1024);
            testCase.verifyEqual(nfft,2048);
            testCase.verifyEqual(xrange,[0 100]);
            testCase.verifyEqual(yrange,[0 1e-4]);
            testCase.verifyEqual(plottype,'line');
            testCase.verifyEqual(axh,[]);
            
            clear obj newRate window noverlap nfft xrange yrange plottype axh
            
            %% parse(W,axh)
            figure
            axh = axes;
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh2] = ...
                testCase.parse(W,axh);
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,1024);
            testCase.verifyEqual(window,1024);
            testCase.verifyEqual(noverlap,512);
            testCase.verifyEqual(nfft,1024);
            testCase.verifyEqual(xrange,[0 100]);
            testCase.verifyEqual(yrange,[0 1e-4]);
            testCase.verifyEqual(plottype,'line');
            testCase.verifyEqual(axh2,axh);
            
            close
            clear obj newRate window noverlap nfft xrange yrange plottype axh axh2
            
            %% parse(W,'plottype','line')
            
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W,'plottype','line');
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,1024);
            testCase.verifyEqual(window,1024);
            testCase.verifyEqual(noverlap,512);
            testCase.verifyEqual(nfft,1024);
            testCase.verifyEqual(xrange,[0 100]);
            testCase.verifyEqual(yrange,[0 1e-4]);
            testCase.verifyEqual(plottype,'line');
            testCase.verifyEqual(axh,[]);
            
            clear obj newRate window noverlap nfft xrange yrange plottype axh
            
            %% parse(W,'plottype','hist')
            
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W,'plottype','hist');
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,1024);
            testCase.verifyEqual(window,1024);
            testCase.verifyEqual(noverlap,512);
            testCase.verifyEqual(nfft,1024);
            testCase.verifyEqual(xrange,[0 100]);
            testCase.verifyEqual(yrange,[0 1e-4]);
            testCase.verifyEqual(plottype,'hist');
            testCase.verifyEqual(axh,[]);
            
            clear obj newRate window noverlap nfft xrange yrange plottype axh
            
            
            %% parse(W,'plottype','none')
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W,'plottype','none');
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,1024);
            testCase.verifyEqual(window,1024);
            testCase.verifyEqual(noverlap,512);
            testCase.verifyEqual(nfft,1024);
            testCase.verifyEqual(xrange,[0 100]);
            testCase.verifyEqual(yrange,[0 1e-4]);
            testCase.verifyEqual(plottype,'none');
            testCase.verifyEqual(axh,[]);
            
            clear obj newRate window noverlap nfft xrange yrange plottype axh
            
            %% parse(W,'XLim',[0 50],'ylim',[0 0.001])
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W,'XLim',[0 50],'ylim',[0 0.001]);
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,1024);
            testCase.verifyEqual(window,1024);
            testCase.verifyEqual(noverlap,512);
            testCase.verifyEqual(nfft,1024);
            testCase.verifyEqual(xrange,[0 50]);
            testCase.verifyEqual(yrange,[0 0.001]);
            testCase.verifyEqual(plottype,'line');
            testCase.verifyEqual(axh,[]);
            
            clear obj newRate window noverlap nfft xrange yrange plottype axh
            
            %% parse(W,'noverlap',128);
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W,'noverlap',128);
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,1024);
            testCase.verifyEqual(window,1024);
            testCase.verifyEqual(noverlap,128);
            testCase.verifyEqual(nfft,1024);
            testCase.verifyEqual(xrange,[0 100]);
            testCase.verifyEqual(yrange,[0 1e-4]);
            testCase.verifyEqual(plottype,'line');
            testCase.verifyEqual(axh,[]);
            
            clear obj newRate window noverlap nfft xrange yrange plottype axh
            
            %%  parse(W,newRate,window,nfft,'XLim',[0 50],'ylim',[0 0.001],'plottype','hist')
            
            newRate = 2048;
            window = 2048;
            nfft = 2048;
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh] = ...
                testCase.parse(W,newRate,window,nfft,'XLim',[0 50],...
                'ylim',[0 0.001],'plottype','hist');
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,2048);
            testCase.verifyEqual(window,2048);
            testCase.verifyEqual(noverlap,1024);
            testCase.verifyEqual(nfft,2048);
            testCase.verifyEqual(xrange,[0 50]);
            testCase.verifyEqual(yrange,[0 0.001]);
            testCase.verifyEqual(plottype,'hist');
            testCase.verifyEqual(axh,[]);
            
            clear obj newRate window noverlap nfft xrange yrange plottype axh

            %%  parse(W,axh,newRate,window,nfft,'XLim',[0 50],'ylim',[0 0.001],'plottype','hist')
            
            figure
            axh = axes;
            
            newRate = 2048;
            window = 2048;
            nfft = 2048;
            [obj,newRate,window,noverlap,nfft,xrange,yrange,plottype,axh2] = ...
                testCase.parse(W,axh,newRate,window,nfft,'XLim',[0 50],...
                'ylim',[0 0.001],'plottype','hist');
            
            testCase.verifyTrue(isa(obj,'Chan'));
            testCase.verifyEqual(newRate,2048);
            testCase.verifyEqual(window,2048);
            testCase.verifyEqual(noverlap,1024);
            testCase.verifyEqual(nfft,2048);
            testCase.verifyEqual(xrange,[0 50]);
            testCase.verifyEqual(yrange,[0 0.001]);
            testCase.verifyEqual(plottype,'hist');
            testCase.verifyEqual(axh2,axh);
            
            close
            clear obj newRate window noverlap nfft xrange yrange plottype axh

            
            %%  parse(W,axh,newRate,'XLim',[0 50],'ylim',[0 0.001],'plottype','hist'
            
            figure
            axh = axes;
            
            newRate = 2048;
            window = 2048;
            nfft = 2048;
            testCase.verifyError(@() ...
                testCase.parse(W,axh,newRate,'XLim',[0 50],...
                'ylim',[0 0.001],'plottype','hist'), ...
                'plotPowerSpectra:windownfft:missing');

            
        end
        
    end
    
    methods (Static)
        function [obj, newRate, window, noverlap, nfft, xrange, yrange, plotType, axh] ...
                = parse(obj, varargin)
            % [h, out] = plotPowerSpectrum(obj)
            % [h, out] = plotPowerSpectrum(obj, newRate, window, nfft)
            % [h, out] = plotPowerSpectrum(obj, ______, 'Param', value, ...)
            % [h, out] = plotPowerSpectrum(obj, axh, ______)
            %
            % OPTIONAL PARAMETER/VALUE PAIRS
            %
            % 'PlotType'     'line'   line drawing
            %                'hist'   histogram
            %                'none'   no plot produced and only returns out and empty h.
            %
            % 'XLim'         [left, right] in Hz. Default is [0 100]
            %
            % 'YLim'         [bottom, top]. Default is [0 1e-4]
            %
            % 'noverlap'     The number of overlap.
            %                (default) window/2
            
            p = inputParser;
            p.addRequired('obj');
            
            if ~isempty(varargin) && isscalar(varargin{1}) && ishandle(varargin{1})
                
                axh = varargin{1};
                assert(isequal(axh.Type,'axes'));
                varargin = varargin(2:end);
                
            else
                axh = [];
            end
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                assert(~ischar(varargin{2}) &&  ~ischar(varargin{3}),...
                    'plotPowerSpectra:windownfft:missing',...
                    'The syntax plotPowerSpectrum(obj, newRate, window, nfft) requires all  newRate, window and nfft at the same time');
            end
            
            vfscpos = @(x) ~isempty(x) && isscalar(x) && isreal(x) && x > 0;
            p.addOptional('newRate', [], vfscpos);
            
            vfscposint = @(x) ~isempty(x) && isscalar(x) && isreal(x) && ...
                x > 0 && fix(x) == x;
            
            p.addOptional('window', [], vfscposint);
            p.addOptional('nfft',   [], vfscposint);
            
            p.addParameter('plotType', 'line', ...
                @(x) ~isempty(x) && ismember(lower(x),{'line','hist','none'}));
            
            vflim = @(x) ~isempty(x) && isreal(x) && isrow(x) && ...
                (numel(x) == 2) && x(1) >= 0 && x(2) > 0 && x(1) < x(2);
            
            p.addParameter('xlim', [0 100], vflim);
            
            p.addParameter('ylim', [0 1e-4], vflim);
            
            p.addParameter('noverlap', [], vfscposint);
            
            p.parse(obj,varargin{:});
            
            newRate = p.Results.newRate;
            window = p.Results.window;
            nfft = p.Results.nfft;
            plotType = p.Results.plotType;
            xrange = p.Results.xlim;
            yrange = p.Results.ylim;
            noverlap = p.Results.noverlap;
            
            
            if isempty(window)
                if obj.SRate >= 1024
                    newRate = 1024;
                    window = 1024;
                    nfft = 1024;
                else
                    newRate = obj.SRate;
                    window = 256;
                    nfft = 256;
                end
            end
            
            if isempty(noverlap)
                noverlap = round(window/2);
            end
            
        end
    end
end
