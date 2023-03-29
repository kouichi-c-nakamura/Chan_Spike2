classdef Record_test < matlab.unittest.TestCase
    %Record_test < matlab.unittest.TestCase
    %
    %    clear;close all; clc; testCase = Record_test; res =testCase.run ; disp(res);
    %
    % See also
    % Record, RecordInfo_test
    %
    % 6 Feb 2015
    % Totals:
    %    10 Passed, 0 Failed, 0 Incomplete.
    %    24.5547 seconds testing time.
    
    properties
    end
    
    methods (Test)
        function testRecord_simpleVal(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('testRecord_simpleVal') ; disp(res);
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            sr = 1000;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            
            W.DataUnit = 'mV';
            
            rec = Record({E, W});
            rec.testProperties;
            
            testCase.verifyEqual(rec.Length, 1000);
            testCase.verifyThat(rec.MaxTime,...
                IsEqualTo(0.999000000000000, ...
                'Within', RelativeTolerance(2*eps)));
            testCase.verifyThat(rec.Duration,...
                IsEqualTo(0.999000000000000, ...
                'Within', RelativeTolerance(2*eps)));
            testCase.verifyEqual(rec.Start, 0);
            testCase.verifyEqual(rec.SRate, 1000);
            
            %% summaryDataset()
            ds = rec.summaryTable;
            disp(ds);
            testCase.verifyEqual(ds.ChanTitle, {'test Event';'testWF'});
            testCase.verifyEqual(ds.DataUnit, {'';'mV'});
            
            testCase.verifyEqual(ds.Start(1), ds.Start(2));
            testCase.verifyEqual(ds.MaxTime(1), ds.MaxTime(2));
            testCase.verifyEqual(ds.Duration(1), ds.Duration(2));
            testCase.verifyEqual(ds.SRate(1), ds.SRate(2));
            testCase.verifyEqual(ds.Length(1), ds.Length(2));
            
            
            %% addchan()
            rec2 = rec.addchan(E2);
            rec2.plot;
            
            %% removechan()
            rec3 = rec2.removechan('Event2');
            rec3.plot;
            
            rec4 = rec.removechan({'test Event', 'testWF'});
            %OK 2014/06/07 16:51
            
            
            % you can create empty Record
            rec0 = Record
            
            % then add a Chan obj
            rec0.addchan(E)
            
            % you can create empty Record with Name
            rec00 = Record('Name', 'test')
            
            %% save and load
            
            currentdir = pwd;
            cd(fileparts(which('Record.m')));
            save('rec','rec')
            S = load('rec');
            S.rec.testProperties;
            testCase.verifyEqual(rec,S.rec)
            delete('rec.mat')
            cd(currentdir)
            
            %             m= ?Record;
            %             plist = m.PropertyList;
            %             {plist(:).RecordTitle}'
            
        end
        
        function Record_empty(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('Record_empty') ; disp(res);
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            % you can create empty Record
            rec0 = Record;
            
            testCase.verifyEqual(rec0.RecordTitle, '');
            testCase.verifyEqual(rec0.Chans, []);
            testCase.verifyEqual(rec0.Time, []);
            testCase.verifyEqual(rec0.Length, 0);
            testCase.verifyEqual(rec0.SInterval, 1);
            testCase.verifyEqual(rec0.MaxTime, []);
            testCase.verifyEqual(rec0.ChanTitles, {});
            testCase.verifyEqual(rec0.Start, 0);
            testCase.verifyEqual(rec0.Duration, []);
            testCase.verifyEqual(rec0.SRate, 1);
            
            % then add a Chan obj
            sr = 1000;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            testCase.verifyEqual(E.NSpikes, 5);
            testCase.verifyEqual(E.Length, 1000);
            testCase.verifyEqual(E.SRate, 1000);
            
            rec1 = rec0.addchan(E); %TODO
            
            testCase.verifyEqual(rec1.ChanTitles, {'test Event'});
            testCase.verifyEqual(rec1.RecordTitle, '');
            %             testCase.verifyEqual(rec1.Chans{1}, E); % TODO
            testCase.verifyEqual(rec1.Length, 1000);
            testCase.verifyThat(rec1.SInterval, ...
                IsEqualTo(1.000000000000000e-03, ...
                'Within', RelativeTolerance(2*eps)));
            testCase.verifyThat(rec1.MaxTime, ...
                IsEqualTo(0.999000000000000, ...
                'Within', RelativeTolerance(2*eps)));
            testCase.verifyEqual(rec1.Start, 0);
            testCase.verifyEqual(rec1.Duration, rec1.MaxTime);
            testCase.verifyEqual(rec1.SRate, 1000);
            
            % you can create empty Record with Name
            rec0 = Record('Name', 'test');% TODO
            testCase.verifyEqual(rec0.RecordTitle, 'test');
            
        end
        
        function addchan_removechan(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('addchan_removechan') ; disp(res);
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            sr = 1000;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            
            W.DataUnit = 'mV';
            
            rec = Record({E, W});
            
            testCase.verifyEqual(length(rec.Chans), 2);
            testCase.verifyEqual(rec.ChanTitles, {'test Event';'testWF'});
            
            
            
            %% addchan()
            rec2 = rec.addchan(E2);
            testCase.verifyEqual(length(rec2.Chans), 3);
            testCase.verifyEqual(rec2.ChanTitles, {'test Event';'testWF';'Event2'});
            
            
            rec2.plot;
            
            %% removechan()
            rec3 = rec2.removechan('testWF');
            testCase.verifyEqual(length(rec3.Chans), 2);
            testCase.verifyEqual(rec3.ChanTitles, {'test Event';'Event2'});
            
            rec3.plot;
            
            % wrong name for chantitle
            testCase.verifyError(@() rec.removechan({'test Event', 'Event2'}),...
                'K:Record:removechan:chantitle');
            
            % make rec empty
            rec4 = rec.removechan({'test Event', 'testWF'});
            testCase.verifyEqual(length(rec4.Chans), 0);
            testCase.verifyEqual(rec4.ChanTitles, {});
            
            
            %OK 2014/07/08 20:26
            
            
            
        end
        
        
        
        
        function testEmpty(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('testEmpty') ; disp(res);
            %
            % 22 Jan 2015
            % Totals:
            %    1 Passed, 0 Failed, 0 Incomplete.
            %    1.5814 seconds testing time.
            
            import matlab.unittest.TestSuite;
            
            sr = 1000;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            tsE = E.chan2ts;
            tsW = W.chan2ts;
            
            % tsc = tscollection({tsE, tsW});
            rec = Record({E, W});
            rec.testProperties;
            rec.RecordInfo_
            
            rec.summaryTable;
            
            rec2 = rec.addchan(E2);
            rec2.plot;
            
            
            rec3 = rec2.removechan('Event2');
            rec3.plot;
            
            rec4 = rec.removechan({'test Event', 'testWF'});
            %OK 2014/06/07 16:51
            
            
            % you can create empty Record
            rec0 = Record;
            testCase.verifyEmpty(rec0.RecordTitle);
            testCase.verifyEmpty(rec0.Chans);
            testCase.verifyEmpty(rec0.Time);
            testCase.verifyEmpty(rec0.MaxTime);
            testCase.verifyEmpty(rec0.Duration);
            testCase.verifyEmpty(rec0.ChanTitles);
            testCase.verifyEqual(rec0.Length, 0);
            testCase.verifyEqual(rec0.SInterval, 1);
            testCase.verifyEqual(rec0.Start, 0);
            testCase.verifyEqual(rec0.SRate, 1);
            
            
            % then add a Chan obj
            disp(rec0.addchan(E));
            
            % you can create empty Record with Name
            rec00 = Record('Name', 'test');
            testCase.verifyNotEmpty(rec00.RecordTitle);
            testCase.verifyEmpty(rec0.Chans);
            testCase.verifyEmpty(rec0.Time);
            testCase.verifyEmpty(rec0.MaxTime);
            testCase.verifyEmpty(rec0.Duration);
            testCase.verifyEmpty(rec0.ChanTitles);
            testCase.verifyEqual(rec0.Length, 0);
            testCase.verifyEqual(rec0.SInterval, 1);
            testCase.verifyEqual(rec0.Start, 0);
            testCase.verifyEqual(rec0.SRate, 1);
            
            
            
            m= ?Record;
            plist = m.PropertyList;
            disp({plist(:).Name}');
            
            
        end
        
        function testSubsref(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('testSubsref') ; disp(res);
            close all
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            sr = 1000;
            rng('default');
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            rec = Record({E, W});
            
            
            %% subsref for Properties
            
            
            %% Top level properties
            h = rec.plot;
            if verLessThan('matlab','8.4.0') % backward compatibility
                testCase.verifyEqual(h.fig, 1);
            else
                testCase.verifyClass(h.fig, 'matlab.ui.Figure');
            end
            testCase.verifyEqual(size(h.ax), [2, 1]);
            testCase.verifyEqual(size(h.lineh), [2, 1]);
            
            testCase.verifyEqual(rec.Start, 0);
            testCase.verifyEqual(rec.SRate, 1000);
            testCase.verifyEqual(rec.SRate(1), 1000);
            testCase.verifyEqual(rec.Length, 1000);
            testCase.verifyEqual(rec.SInterval,  1.0000e-03);
            testCase.verifyEqual(rec.Time,  (0:1/1000:(1-1/1000))');
            testCase.verifyThat(rec.Duration, ...
                IsEqualTo(0.999, 'Within', RelativeTolerance(2*eps)));
            testCase.verifyEqual(rec.RecordTitle,  '');

            testCase.verifyThat(rec.MaxTime, ...
                IsEqualTo(0.999000000000000, 'Within', RelativeTolerance(2*eps)));
            
            %OK 14/02/2014 16:45
            testCase.verifyThat(rec.MaxTime(1), ...
                IsEqualTo(0.999000000000000, 'Within', RelativeTolerance(2*eps)));
            
            testCase.verifyEqual(rec.Chans,  {E;W});
            testCase.verifyEqual(rec.Chans{1},  E);
            testCase.verifyEqual(rec.Chans{2},  W);

            testCase.verifyEqual(rec.ChanTitles,...
                {'test Event';...
                'testWF'})
            
            testCase.verifyEqual(rec.ChanTitles{1}, 'test Event');
            testCase.verifyEqual(rec.ChanTitles{2}, 'testWF');
            
            
            %% Short-cut Access to Chan obj by ChanTitle
            
            %OK 14/02/2014 16:48
            testCase.verifyEqual(rec.('testWF'), W); %TODO
            
            %OK ... this may have conflicts with prop names 14/02/2014 16:48
            testCase.verifyEqual(rec.testWF, W);

            %OK   14/02/2014 16:56
            testCase.verifyEqual(rec.testWF.ChanTitle, 'testWF');
            
            %OK!!! 14/02/2014 17:02
            testCase.verifyEqual(rec.('testWF').ChanTitle(1), 't');
            
            %OK 14/02/2014 17:02
            testCase.verifyEqual(rec.testWF.ChanTitle(1), 't');

            
            %% Direct access to Chans
            
            %OK 14/02/2014 17:49
            testCase.verifyEqual(rec.Chans, {E; W});
            
            %OK 4/02/2015 19:55
            testCase.verifyClass(rec.Chans{1}, 'EventChan');
            testCase.verifyEqual(rec.Chans{1}.ChanTitle, 'test Event');
            testCase.verifyEqual(rec.Chans{1}.SRate, 1000);

            
            %Known problem      14/02/2014 17:49  %%%%%%%%%%%%%%%%%%%%%%%%
            testCase.verifyError(@()rec.Chans{:} , 'K:Record:subsref:BadSubscript');
            
            % http://www.mathworks.com/matlabcentral/answers/57562-subsref-overload-has-fewer-outputs-than-expected-on-cell-attribute
            
            % Probably this should be kept like this  14/02/2014 17:49
            testCase.verifyError(@() rec.Chans{1:2}, 'K:Record:subsref:BadSubscript2');
            

            
            %% subsref for methods of Chans
            
            h = rec.testWF.plot; %OK 14/02/2014 17:06
            if verLessThan('matlab','8.4.0') % backward compatibility
                testCase.verifyEqual(h.fig, 2);
            else
                testCase.verifyClass(h.fig, 'matlab.ui.Figure');
            end            
            
            %OK!!! 14/02/2014 17:16 resample
            E200 = rec.('test Event').resample(200); %TODO class
            testCase.verifyEqual(E200.Start, 0);
            testCase.verifyEqual(E200.SRate, 200);
            testCase.verifyEqual(E200.Length, 200);
            testCase.verifyEqual(E200.NSpikes, rec.('test Event').NSpikes);
            testCase.verifyEqual(E200.Header, rec.('test Event').Header);
            testCase.verifyEqual(E200.Path, rec.('test Event').Path);
            testCase.verifyEqual(E200.ChanTitle, rec.('test Event').ChanTitle);
            
            
            h = rec.Chans{2}.plot;
            if verLessThan('matlab','8.4.0') % backward compatibility
                testCase.verifyEqual(h.fig, 3);
            else
                testCase.verifyClass(h.fig, 'matlab.ui.Figure');
            end    
            
            E200 = rec.('test Event').resample(200); %TODO class
            testCase.verifyEqual(E200.Start, 0);
            testCase.verifyEqual(E200.SRate, 200);
            testCase.verifyEqual(E200.Length, 200);
            testCase.verifyEqual(E200.NSpikes, rec.('test Event').NSpikes);
            testCase.verifyEqual(E200.Header, rec.('test Event').Header);
            testCase.verifyEqual(E200.Path, rec.('test Event').Path);
            testCase.verifyEqual(E200.ChanTitle, rec.('test Event').ChanTitle);
            
            

            
            %OK 14/02/2014 17:06
            
            Eshort = rec.testWF.extractTime(0, 0.5);
            
            testCase.verifyEqual(Eshort.Start, 0);
            testCase.verifyEqual(Eshort.SRate, rec.testWF.SRate);
            testCase.verifyEqual(Eshort.Length, 501);
            testCase.verifyEqual(Eshort.MaxTime, 0.5);
            testCase.verifyEqual(Eshort.Header, rec.testWF.Header);
            testCase.verifyEqual(Eshort.Path, rec.testWF.Path);
            testCase.verifyEqual(Eshort.ChanTitle, rec.testWF.ChanTitle);
            
            
            
            
        end
        
        
        function testSubsasgn(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('testSubsasgn') ; disp(res);
            %
            
            import matlab.unittest.TestSuite;
            
            sr = 1000;
            e = double(logical(poissrnd(10/sr, 1000, 1)));
            E = EventChan(e, 0, sr, 'test Event'); % 370 byte
            
            e2 = double(logical(poissrnd(50/sr, 1000, 1)));
            E2 = EventChan(e2, 0, sr, 'Event2');
            
            
            w = randn(1000, 1);
            W = WaveformChan(w, 0, sr, 'testWF');
            W.DataUnit = 'mV';
            
            rec = Record({E, W});
            rec.testProperties;
            rec.RecordInfo_
            
            
            %% subsasgn test
            
            clear rec
            rec = Record({E, W});
            rec.testWF.Data(1:100) = ones(100, 1); % OK 14/02/2014 21:35
            testCase.verifyEqual(rec.testWF.Data(1:100),ones(100, 1));
            
            
            clear rec
            rec = Record({E, W});
            rec.testWF.ChanTitle = 'hoge'; % OK 14/02/2014 22:13
            testCase.verifyEqual(rec.hoge.ChanTitle, 'hoge');  %TODO
            
            clear rec
            rec = Record({E, W});
            try
                rec.ChanTitles = [];
            catch exc1
                testCase.verifyError(@() throw(exc1), 'KOUICHI:Record:subsasgn:badsyntax');  % expected ERROR 14/02/2014 22:13
            end
            testCase.verifyEqual(exist('exc1', 'var'), 1);
            
            clear exc1
            
            clear rec
            rec = Record({E, W});
            rec.Start = 20; %OK 14/02/2014 22:43
            testCase.verifyEqual(rec.Start, 20);
            
            
            clear rec
            rec = Record({E, W}, 'Name','hogehogehoge');
            rec.RecordTitle(1) = 'H'; %OK 14/02/2014 22:49
            testCase.verifyEqual(rec.RecordTitle, 'Hogehogehoge');
            
            
            clear rec
            rec = Record({E, W}, 'Name','hogehogehoge');
            rec.RecordTitle(1:4) = 'HOGE'; %OK 14/02/2014 22:43
            testCase.verifyEqual(rec.RecordTitle, 'HOGEhogehoge');
            
            clear rec
            rec = Record({E, W});
            rec.('testWF').ChanTitle = 'hello'; %OK 15/01/2015
            testCase.verifyEqual(rec.hello.ChanTitle, 'hello');
            testCase.verifyEqual(rec.('hello').ChanTitle, 'hello');
            
            
            % Passed on 22 Jan 2015, 17:39
            
            
        end
        
        function testRecord_spike2SON(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('testRecord_spike2SON') ; disp(res);
            %
            % Passed on 2/22015 17:05

            
            %% testCase
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;

            pathstr = fileparts(which('Record.m'));
            load(fullfile(pathstr, 'kjx006a01@200-300.mat'));
            
            sr = 17000;
            
            unite_chan = EventChan(double(unite.values), 0, sr, 'unite'); % 2530 bytes
            onset_chan = EventChan(double(onset.values), 0, sr, 'onset'); % 2530 bytes
            unitw_chan = WaveformChan(unitw.values, 0, sr, 'unitw'); % 2530 bytes
            unitw_chan.DataUnit = 'mV';
            eegw_chan = WaveformChan(eegw.values, 0, sr, 'eegw'); % 2530 bytes
            eegw_chan.DataUnit = 'mV';
            
            LTS_chan = MarkerChan(LTS.values, 0, sr, 0, 'LTSm');
            ts = LTS_chan.TimeStamps;
            codes = repmat([1; 0], length(ts)/2, 1);
            LTS_chan.MarkerCodes = codes;
            LTS_chan = setMarkerName(LTS_chan, 0,1, 'onset');
            LTS_chan = setMarkerName(LTS_chan, 1,1, 'offset');
            LTS_chan.plot;
            
            
            rec = Record({unite_chan, onset_chan, unitw_chan, eegw_chan});
            
            testCase.verifyEqual(rec.ChanTitles, {'unite';'onset';'unitw';'eegw'});
            rec.plot;
            testCase.verifyThat(rec.MaxTime, ...
                IsEqualTo(99.9999, 'Within', RelativeTolerance(0.0001)));
            
        end
        
        
        
        function testRecord_spike2SON_addchan(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('testRecord_spike2SON_addchan') ; disp(res);
            %
            % Passed on 2/22015 17:05
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            pathstr = fileparts(which('Record.m'));
            load(fullfile(pathstr, 'kjx006a01@200-300.mat'));
            
            sr = 17000;
            
            unite_chan = EventChan(double(unite.values), 0, sr, 'unite'); % 2530 bytes
            onset_chan = EventChan(double(onset.values), 0, sr, 'onset'); % 2530 bytes
            unitw_chan = WaveformChan(unitw.values, 0, sr, 'unitw'); % 2530 bytes
            unitw_chan.DataUnit = 'mV';
            eegw_chan = WaveformChan(eegw.values, 0, sr, 'eegw'); % 2530 bytes
            eegw_chan.DataUnit = 'mV';
            
            LTS_chan = MarkerChan(LTS.values, 0, sr, 0, 'LTSm');
            ts = LTS_chan.TimeStamps;
            codes = repmat([1; 0], length(ts)/2, 1);
            LTS_chan.MarkerCodes = codes;
            LTS_chan = setMarkerName(LTS_chan, 0,1, 'onset');
            LTS_chan = setMarkerName(LTS_chan, 1,1, 'offset');
            LTS_chan.plot;
            
            rec = Record({unite_chan, onset_chan, unitw_chan, eegw_chan});
            
            
            %% .addchan
            rec2 = addchan(rec, LTS_chan);
            rec2.plot
            testCase.verifyEqual(rec2.ChanTitles, {'unite';'onset';'unitw';'eegw';'LTSm'});
            
            
        end
        
        function testRecord_spike2SON_vertcat(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('testRecord_spike2SON_vertcat') ; disp(res);
            %
            % Passed on 2/22015 17:05
            
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            
            
            pathstr = fileparts(which('Record.m'));
            load(fullfile(pathstr, 'kjx006a01@200-300.mat'));
            
            sr = 17000;
            
            unite_chan = EventChan(double(unite.values), 0, sr, 'unite'); % 2530 bytes
            onset_chan = EventChan(double(onset.values), 0, sr, 'onset'); % 2530 bytes
            unitw_chan = WaveformChan(unitw.values, 0, sr, 'unitw'); % 2530 bytes
            unitw_chan.DataUnit = 'mV';
            eegw_chan = WaveformChan(eegw.values, 0, sr, 'eegw'); % 2530 bytes
            eegw_chan.DataUnit = 'mV';
            
            LTS_chan = MarkerChan(LTS.values, 0, sr, 0, 'LTSm');
            ts = LTS_chan.TimeStamps;
            codes = repmat([1; 0], length(ts)/2, 1);
            LTS_chan.MarkerCodes = codes;
            LTS_chan = setMarkerName(LTS_chan, 0,1, 'onset');
            LTS_chan = setMarkerName(LTS_chan, 1,1, 'offset');
            LTS_chan.plot;
            
            
            rec = Record({unite_chan, onset_chan, unitw_chan, eegw_chan});
            
            testCase.verifyEqual(rec.ChanTitles, {'unite';'onset';'unitw';'eegw'});
            rec.plot;
            testCase.verifyThat(rec.MaxTime, ...
                IsEqualTo(99.9999, 'Within', RelativeTolerance(0.0001)));
            
            
            %% .addchan
            rec2 = addchan(rec, LTS_chan);
            rec2.plot
            testCase.verifyEqual(rec2.ChanTitles, {'unite';'onset';'unitw';'eegw';'LTSm'});
            
            
            %% .vertcat
            rec4 = rec2.extractTime(0,70);
            rec5 = rec2.extractTime(0,50);
            
            rec6 = vertcat(rec4, rec5);
            rec6.plot;
            testCase.verifyEqual(rec6.ChanTitles, {'unite';'onset';'unitw';'eegw';'LTSm'});
            testCase.verifyThat(rec6.MaxTime, ...
                IsEqualTo(120.0001, 'Within', RelativeTolerance(0.0001)));
            
        end
        
        
        function test_Spike2matfile(testCase)
            % clear;close all; clc; testCase = Record_test; res =testCase.run('test_Spike2matfile') ; disp(res);
            %
            % Passed on 2/2/2015 16:43
            % Totals:
            %    1 Passed, 0 Failed, 0 Incomplete.
            %    0.8114 seconds testing time.
            
            pathstr1 = fileparts(which('WaveformChan.m'));
            
            matname1 = 'kjx127a01@0-20_double.mat';
            
            rec1 = Record(fullfile(pathstr1, matname1));
            testCase.verifyEqual(rec1.chantitles(), {'onset';'LTS';'LTSmk';'probeA07e';'EEG'});
            
            matname2 = 'kjx127a01@0-20_single.mat';
            
            rec2 = Record(fullfile(pathstr1, matname2));
            testCase.verifyEqual(rec2.chantitles(), {'onset';'LTS';'LTSmk';'probeA07e';'EEG'});
            
            matname3 = 'kjx127a01@0-20_int16.mat';
            
            rec3 = Record(fullfile(pathstr1, matname3));
            testCase.verifyEqual(rec3.chantitles(), {'onset';'LTS';'LTSmk';'probeA07e';'EEG'});
            
            
            pathstr2 = fileparts(which('MarkerChan.m'));
            
            matname4 = 'markerchan_demodata.mat';
            
            rec4 = Record(fullfile(pathstr2, matname4));
            testCase.verifyEqual(rec4.chantitles(), {'LTSmarker';'LTSbinned';'LTStextmark'});
            
            matname5 = 'BinFreq0MarkAs1.mat';
            
            testCase.verifyError(@() Record(fullfile(pathstr2, matname5)), ...
                'K:Record:matfileinput:marker:noref'); 
            % You need  extra waveform or event chaneel to create a Chan object.
            

        end
        
        function writesmr(testCase)
            
            Fs = 1000;
            rng('default') % To get reproducible results
            e = double(logical(poissrnd(10/Fs, 1000, 1)));
            
            E = EventChan(e, 0, Fs, 'test1'); % 370 byte
            E.plot;
            
            rec = Record({E},'Name','foo0');
            
            rec.writesmr('foo0.smr')
            
            %%
            Fs = 1000;
            rng('default') % To get reproducible results
            a = randn(1000, 1);
            W = WaveformChan(a, 0, Fs, 'test WF');
            W.plot;
            
            rec = Record({W},'Name','hoge');
            
            rec.writesmr('foo1.smr')
            
            %%
            Fs = 1000;
            rng('default');
            events = double(logical(poissrnd(30/Fs, 1000, 1)));
            
            ind1 = find(events);
            codes = logical(poissrnd(3/10, length(ind1), 1)) ...
                + logical(poissrnd(2/10, length(ind1), 1)) .*2 ...
                + logical(poissrnd(1/10, length(ind1), 1)) .*3;
            
            M = MarkerChan(events, 0, Fs, codes, 'test mark'); % 370 byte
            h = M.plot;
            
            rec = Record({M},'Name','hoge');
            
            rec.writesmr('foo2.smr')
            
            %%
            rec = Record({E,W,M},'Name','hoge');
            rec.plot;
            
            rec.writesmr('foo3.smr')
            
        end
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function local_prepareDemodata()
% local_prepareDemodata()
%
% Prepare and save demo data form Spike2 .smr file

import matlab.unittest.TestSuite;

pathstr = fileparts(which('Record.m'));
path = 'Z:\Work\Spike2 folder\Kouichi for conversion\thalamus\for Cereb Cortex 2012\control BG SWA\';
filename = 'kjx006a01@200-300.smr';
fid = fopen([path filename],'r') ;


chanlist = SONChanList(fid);

list =[{'number', 'title', 'kind'}; ...
    {chanlist(:).number}', {chanlist(:).title}',{chanlist(:).kind}'];
openvar('list');


tf = strcmpi('unite', {chanlist.title});
unitechan= [chanlist(tf).number];
clear tf

tf = strcmpi('IpsiEEG', {chanlist.title});
eegwchan= [chanlist(tf).number];
clear tf

tf = strcmpi('ME1 Unit', {chanlist.title});
unitwchan= [chanlist(tf).number];
clear tf

tf = strcmpi('onset', {chanlist.title});
onsetechan= [chanlist(tf).number];
clear tf


sr = 17000;

[unite, timev]= K_SONAlignAndBin_3(sr, fid, unitechan);

% timev  13600000 bytes =

[eegw]= K_SONAlignAndBin_3(sr, fid, eegwchan);
[unitw]= K_SONAlignAndBin_3(sr, fid, unitwchan);
[onset]= K_SONAlignAndBin_3(sr, fid, onsetechan);
[LTS]= K_SONAlignAndBin_3(sr, fid, 8);


%% compress data
unite.values = sparse(unite.values);
onset.values = sparse(onset.values);
LTS.values = sparse(LTS.values);
save(fullfile(pathstr,'kjx006a01@200-300.mat'), 'eegw', 'unite','unitw','onset','LTS');


end

