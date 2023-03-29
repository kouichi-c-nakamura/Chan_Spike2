classdef ChanSpecifier_test < matlab.unittest.TestCase
    %ChanSpecifier_test < matlab.unittest.TestCase
    %
    % clear;close all;clc; testCase = ChanSpecifier_test; res=testCase.run;disp(res);
    %
    % See also
    % ChanSpecifier, Record, MetaEventChan
    %
    % Passed on 4 Jun 2015 12:57
    % Totals:
    %    6 Passed, 0 Failed, 0 Incomplete.
    %    14.4653 seconds testing time.
    
    properties
        dir1 = fileparts(which('WaveformChan.m'));
        dir2 = fileparts(which('MarkerChan.m'));

    end
    
    methods (Test)
        
        
        function test_ChanSpecifier_empty(testCase)
            % clear;close all;clc; testCase = ChanSpecifier_test; disp(testCase.run('test_ChanSpecifier_empty'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            chanSpec = ChanSpecifier();
            testCase.verifyEqual(size(chanSpec.List), [0, 0]);
            testCase.verifyEqual(chanSpec.MatNames,{});
            testCase.verifyEqual(chanSpec.MatNamesFull,{});
            testCase.verifyEqual(chanSpec.ParentDir, '');

            testCase.verifyEqual(chanSpec.MatNum, 0);
            testCase.verifyEqual(chanSpec.ChanNum, zeros(0, 1));
            testCase.verifyEqual(chanSpec.ChanTitles, cell(0, 1));
        end
        
        
                
        function test_ChanSpecifier_emptyfolder(testCase)
            % clear;close all;clc; testCase = ChanSpecifier_test; disp(testCase.run('test_ChanSpecifier_emptyfolder'));
            
            disp('Make sure you turned off Dropbox syncing. It will affect rmdir operation and leads to unstable results.')
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            %% setup
            temp = fullfile(testCase.dir1, 'temp');
            
            if isdir(temp)
               rmdir(temp, 's');
            end
            
            mkdir(temp); % an empty new folder
            
            %% test
            chanSpec = ChanSpecifier(temp);
            
            testCase.verifyEqual(size(chanSpec.List), [0, 0]);
            testCase.verifyEqual(chanSpec.MatNames,{});
            testCase.verifyEqual(chanSpec.MatNamesFull,{});
            testCase.verifyEqual(chanSpec.ParentDir, '');

            testCase.verifyEqual(chanSpec.MatNum, 0);
            testCase.verifyEqual(chanSpec.ChanNum, zeros(0, 1));
            testCase.verifyEqual(chanSpec.ChanTitles, cell(0, 1));
            
            testCase.verifyEqual(chanSpec.ChanTitlesAll, []);
            testCase.verifyEqual(length(fieldnames(chanSpec.getstructNby1)),3); %TODO
            testCase.verifyEqual(chanSpec.ChanTitlesMatNamesAll, cell(0,4));
            
            [TF, names] = chanSpec.ischanvalid;
            testCase.verifyEqual(TF, true(0,1));
            testCase.verifyEqual(names, cell(0,1));
            
            [TF, names] = chanSpec.ismatvalid;
            testCase.verifyEqual(TF, true(0,1));
            testCase.verifyEqual(names, cell(0,1));

            [chanSpec0, TF, names] = chanSpec.choose(true(1,1));
            testCase.verifyEmpty(chanSpec0.List);
            testCase.verifyEmpty(TF);
            testCase.verifyEmpty(names);

            TF = chanSpec.ischanvalid;
            [chanSpec0, TF, names] = chanSpec.choose(TF);
            testCase.verifyEmpty(chanSpec0.List);
            testCase.verifyEmpty(TF);
            testCase.verifyEmpty(names);           
                        
            %% teardown
            if isdir(temp)
               rmdir(temp, 's');
            end
            
        end
        
        
        function test_ChanSpecifier_props(testCase)
            % clear;close all;clc; testCase = ChanSpecifier_test; disp(testCase.run('test_ChanSpecifier_props'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
                        
            chanSpec = ChanSpecifier(testCase.dir1);
            
            testCase.verifyEqual(chanSpec.MatNum, 3);
            testCase.verifyEqual(chanSpec.ChanNum, ones(3,1).*5);
            testCase.verifyEqual(chanSpec.MatNames,...
                {'kjx127a01@0-20_double.mat';
                'kjx127a01@0-20_int16.mat';
                'kjx127a01@0-20_single.mat'});
            testCase.verifyEqual(chanSpec.MatNamesFull,...
                 {fullfile(testCase.dir1,'kjx127a01@0-20_double.mat');...
                 fullfile(testCase.dir1,'kjx127a01@0-20_int16.mat');...
                 fullfile(testCase.dir1,'kjx127a01@0-20_single.mat')});
            % For some reason, the drive letter Z often becomes lower or
            % upper cases alternately. I have not figured out why. Is it
            % MATLAB (since Explorer shows Z (uppercase) when MATLAB shows
            % z (lowercase))?
             
             
            testCase.verifyEqual(chanSpec.ChanTitles{1},...
                {'onset';...
                'LTS';...
                'LTSmk';...
                'probeA07e';...
                'EEG'});
            
            testCase.verifyEqual(chanSpec.List(1).name, 'kjx127a01@0-20_double.mat');
            testCase.verifyEqual(chanSpec.List(1).bytes, 4082840);
            testCase.verifyEqual(chanSpec.List(1).isdir, false);
            testCase.verifyEqual(chanSpec.List(1).parentdir,...
                [testCase.dir1, filesep]);
            
            
            testCase.verifyEqual(chanSpec.List(1).channels.onset.title, 'onset');
            testCase.verifyEqual(chanSpec.List(1).channels.onset.samplingrate, 17000);
            testCase.verifyEqual(chanSpec.List(1).channels.onset.parent, 'kjx127a01@0-20_double.mat');
            testCase.verifyEqual(chanSpec.List(1).channels.onset.parentdir, ...
                [testCase.dir1, filesep]);
            
        end
        
        function test_methods(testCase)
            % clear;close all;clc; testCase = ChanSpecifier_test; disp(testCase.run('test_methods'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            
            chanSpec = ChanSpecifier(testCase.dir1);
                        
            chanSpec2 = testCase.verifyWarning(@() ChanSpecifier(testCase.dir2), 'K:ChanSpecifier:markertype:noref'); %TODO
            % Warning: Marker channel demo_LTSmk doesn't have a reference event or waveform channel in the
            % same mat file BinFreq0MarkAs1.mat

            
            %% chanSpec.ChanTitlesAll
            testCase.verifyEqual(chanSpec.ChanTitlesAll, ...
                repmat({'onset';...
                'LTS';...
                'LTSmk';...
                'probeA07e';...
                'EEG'}, 3, 1))
            
            testCase.verifyEqual(chanSpec2.ChanTitlesAll, ...
                {'demo_LTSmk';...
                'demo_textmk';...
                'demo_LTSmk';...
                'LTSmarker';...
                'LTSbinned';...
                'LTStextmark'});
            
            %% chanSpec.ChanTitlesMatNamesAll
            out = chanSpec.ChanTitlesMatNamesAll;
            testCase.verifyEqual(out(:,1),...
                num2cell(vertcat(ones(5,1)*1, ones(5,1)*2, ones(5,1)*3)));
            
            testCase.verifyEqual(out(:,2),...
                [repmat({'kjx127a01@0-20_double.mat'}, 5, 1); ...
                repmat({'kjx127a01@0-20_int16.mat'}, 5, 1); ...
                repmat({'kjx127a01@0-20_single.mat'}, 5, 1)]);
              
            testCase.verifyEqual(out(:,3),...
                num2cell(repmat((1:5)', 3, 1)));   
            
            testCase.verifyEqual(out(:,4),...
                repmat({'onset';...
                'LTS';...
                'LTSmk';...
                'probeA07e';...
                'EEG'}, 3, 1));

            
            out2 = chanSpec2.ChanTitlesMatNamesAll;
            testCase.verifyEqual(out2(:,1),...
                num2cell(vertcat(1,2, 3,ones(3,1)*4)));
            
            testCase.verifyEqual(out2(:,2),...
                [{'BinFreq0MarkAs1.mat'}; ...
                {'BinFreq0TMarkAs2.mat'}; ...
                {'BinFreq17000MarkAs0.mat'}; ...
                repmat({'markerchan_demodata.mat'}, 3, 1)]);
              
            testCase.verifyEqual(out2(:,3),...
                num2cell([ones(4,1);2;3]));   
            
            testCase.verifyEqual(out2(:,4),...
                {'demo_LTSmk';...
                'demo_textmk';...
                'demo_LTSmk';...
                'LTSmarker';...
                'LTSbinned';...
                'LTStextmark'});           

            
            %% chanSpec.ismatvalid
            [TF, ~, TF2] = chanSpec.ismatvalid('name', @(x) ~isempty(strfind(x, 'kjx127a01')));
            testCase.verifyEqual(TF, true(15, 1));
            testCase.verifyEqual(TF2, true(3, 1));
            
            
            [TF, ~, TF2] = chanSpec.ismatvalid('name', @(x) ~isempty(strfind(x, 'double')));
            testCase.verifyEqual(TF, [true(5, 1); false(10,1)]);
            testCase.verifyEqual(TF2, [true; false(2, 1)]);

            
            [TF, ~, TF2] = chanSpec.ismatvalid('name', @(x) ismatchedany(x, 'single.mat$'));
            testCase.verifyEqual(TF, [false(10, 1); true(5,1)]);
            testCase.verifyEqual(TF2, [false(2, 1); true]);
            
            [TF, names, TF2] = chanSpec.ismatvalid(3);
            testCase.verifyEqual(names(TF), ...
                cellfun(@(y) horzcat(chanSpec.MatNames{3},'|',y), chanSpec.ChanTitles{3}, 'UniformOutput', false));
            testCase.verifyEqual(TF2, [false(2, 1); true]);

            
            [TF, names, TF2] = ismatvalid(chanSpec, 'gui');
            disp(names(TF));
            
            [TF, names, TF2] = ismatvalid(chanSpec, 'guimat');
            disp(names(TF));
            
            %%  chanSpec.ismatnamematched
            
            [TF, ~, TF2] = chanSpec.ismatnamematched('single.mat$');
            testCase.verifyEqual(TF, [false(10,1); true(5, 1); ]);
            testCase.verifyEqual(TF2, [false(2, 1); true]);

            %% chanSpec.ischanvalid
            [TF, names] = chanSpec.ischanvalid('title', @(x) ~isempty(strfind(x, 'LTS'))); %TODO
            testCase.verifyEqual(find(TF'),  [2,3,7,8,12,13]);
            testCase.verifyEqual(names(TF),...
                {'kjx127a01@0-20_double.mat|LTS';...
                'kjx127a01@0-20_double.mat|LTSmk';...
                'kjx127a01@0-20_int16.mat|LTS';...
                'kjx127a01@0-20_int16.mat|LTSmk';...
                'kjx127a01@0-20_single.mat|LTS';...
                'kjx127a01@0-20_single.mat|LTSmk'});
            
            [TF, names] = chanSpec.ischanvalid('gui');
            disp(names(TF));
            

            %%  chanSpec.ischantitlematched
            
            [TF, names] = chanSpec.ischantitlematched('^LTS$');
            testCase.verifyEqual(find(TF'),  [2,7,12]);

            
            %% chanSpec.choose
            
            chanSpec2 = chanSpec.choose(TF);
            ctall = chanSpec.ChanTitlesAll;
            testCase.verifyEqual(chanSpec2.ChanTitlesAll,...
                ctall(TF));
            
            %% matnamesfull2matind
            
            testCase.verifyEqual(chanSpec.matnamesfull2matind(chanSpec.MatNamesFull{1}), 1)
        
            testCase.verifyEqual(chanSpec.matnamesfull2matind(chanSpec.MatNamesFull{2}), 2)

            testCase.verifyEqual(chanSpec.matnamesfull2matind(chanSpec.MatNamesFull(1:2)),{1;2})
            
            
            %% chantitles2chanind
            
            [chanind, matind] = chantitles2chanind(chanSpec, chanSpec.MatNamesFull{1}, {'onset', 'EEG'});
            testCase.verifyEqual(size(matind), [1 1]);
            testCase.verifyEqual(matind{1}, 1);
            testCase.verifyEqual(size(chanind), [1, 1]);
            testCase.verifyEqual(chanind{1}, [1; 5]);
            
            
            [chanind, matind] = chantitles2chanind(chanSpec, chanSpec.MatNamesFull(1), {'onset', 'EEG'});
            testCase.verifyEqual(size(matind), [1 1]);
            testCase.verifyEqual(matind{1}, 1);
            testCase.verifyEqual(size(chanind), [1, 1]);
            testCase.verifyEqual(chanind{1}, [1; 5]);  
            
            
            [chanind, matind] = chantitles2chanind(chanSpec, chanSpec.MatNamesFull([1,3]),...
                [{{'onset', 'EEG'}}, {{'onset', 'LTS'}}]);
            testCase.verifyEqual(size(matind), [2 1]);
            testCase.verifyEqual(matind{1}, 1);
            testCase.verifyEqual(matind{2}, 3);
            testCase.verifyEqual(size(chanind), [2, 1]);
            testCase.verifyEqual(chanind{1}, [1; 5]);
            testCase.verifyEqual(chanind{2}, [1; 2]);
            
            %% getstructNby1
            
            S = chanSpec.getstructNby1();
            testCase.verifyEqual(size(S), [15, 1]);
            testCase.verifyEqual(fieldnames(S),{...
                'allindex';...
                'matindex';...
                'chanindex';...
                'start';...
                'comment';...
                'interval';...
                'samplingrate';...
                'length';...
                'chantype';...
                'scale';...
                'parentdir';...
                'duration';...
                'maxtime';...
                'numofevents';...
                'meanfiringrate';...
                'offset';...
                'parent';...
                'title';...
                'timeunit';...
                'units';...
                });
            
            S = chanSpec.getstructNby1('units');
            testCase.verifyEqual(size(S), [3, 1]);
            
            TF = chanSpec.ischantitlematched('^LTS$');
            S = chanSpec.getstructNby1(TF);
            testCase.verifyEqual(size(S), [3, 1]);
            testCase.verifyEqual({S(:).title},{'LTS','LTS','LTS'});

            
            
            %% gettable
            T = chanSpec.gettable();
            testCase.verifyEqual(size(T), [15, 20]);
            testCase.verifyEqual(T.Properties.VariableNames,{...
                'allindex','matindex','chanindex','start','comment',...
                'interval','samplingrate','length','chantype','scale',...
                'parentdir','duration','maxtime','numofevents','meanfiringrate',...
                'offset','parent','title','timeunit','units'});
            
            T = chanSpec.gettable('units');
            testCase.verifyEqual(size(T), [3, 18]);

            TF = chanSpec.ischantitlematched('^LTS$');
            T = chanSpec.gettable(TF);
            testCase.verifyEqual(size(T), [3, 17]);
            testCase.verifyEqual(T.title,{'LTS';'LTS';'LTS'});

        end
        
        function test_methods_constructObj(testCase)
            % clear;close all;clc; testCase = ChanSpecifier_test; disp(testCase.run('test_methods_constructObj'));

            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            
            chanSpec = ChanSpecifier(testCase.dir1);
                                   
            chanSpec2 = testCase.verifyWarning(@() ChanSpecifier(testCase.dir2), ...
                'K:ChanSpecifier:markertype:noref');
            % Warning: Marker channel demo_LTSmk doesn't have a reference event or waveform channel in the

            
            isLTS = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'LTS')); %TODO
            
            chanSpec1 =chanSpec.choose(isLTS);

            chanSpec3 = testCase.verifyWarning(@() [chanSpec, chanSpec1], ...
                'K:ChanSpecifier:horzcat');
            
            
            %% constructFileList
            filelist = constructFileList(chanSpec);
            testCase.verifyEqual(filelist.ListName, '');
            
            filelist = constructFileList(chanSpec, 'Name', 'test1');
            testCase.verifyEqual(filelist.ListName, 'test1');
            testCase.verifyEqual(size(filelist.List), [3, 1]);
            testCase.verifyEqual(filelist.MemberTitles, ...
                {'kjx127a01@0-20_double.mat';...
                'kjx127a01@0-20_int16.mat';...
                'kjx127a01@0-20_single.mat'});
            
            testCase.verifyError(@() constructFileList(chanSpec2), ...
                  'K:Record:matfileinput:marker:noref');
   
            %% constructRecord
            rec1 = chanSpec.constructRecord({fullfile( testCase.dir1, ...
                'kjx127a01@0-20_single.mat')});
            testCase.verifyEqual(rec1.ChanTitles, {'onset';...
                'LTS';...
                'LTSmk';...
                'probeA07e';...
                'EEG'});
            
            
            chan5 = chanSpec3.constructRecord(5);
            testCase.verifyEqual(chan5.ChanTitles, {'LTS';'LTSmk'});
            
            
            rec3 = chanSpec3.constructRecord([1,5]);
            testCase.verifyEqual(rec3{1}.ChanTitles, {'onset';...
                'LTS';...
                'LTSmk';...
                'probeA07e';...
                'EEG'});
            testCase.verifyEqual(rec3{2}.ChanTitles, {'LTS';...
                'LTSmk';});          

            % because of the contatenation of chanSpec and chanSpec1, each .mat
            % files are twice listed in chanSpec3
            
            rec4 = constructRecord(chanSpec3, ...
                {fullfile( testCase.dir1, 'kjx127a01@0-20_single.mat'),...
                fullfile( testCase.dir1, 'kjx127a01@0-20_double.mat'),...
                });
            
            testCase.verifyEqual(size(rec4), [4,1]);
            
            testCase.verifyEqual(rec4{1}.ChanTitles, {'onset';...
                'LTS';...
                'LTSmk';...
                'probeA07e';...
                'EEG'});
            testCase.verifyEqual(rec4{2}.ChanTitles, {'LTS';...
                'LTSmk';}); 
            testCase.verifyEqual(rec4{3}.ChanTitles, {'onset';...
                'LTS';...
                'LTSmk';...
                'probeA07e';...
                'EEG'});
            testCase.verifyEqual(rec4{4}.ChanTitles, {'LTS';...
                'LTSmk';}); 
            
            [rec5, TF] = chanSpec3.constructRecord('gui');
            selected = chanSpec3.choose(TF);
            if numel(rec5) > 1
                testCase.verifyEqual(cellfun(@(x) sum(length(x.Chans)), rec5), ...
                    selected.ChanNum);
            else
                testCase.verifyEqual(sum(length(rec5.Chans)), ...
                    selected.ChanNum);
            end
            
            
            %% constructChan

     
            % chanindex as single channel index
            [chan1, TF, names] = chanSpec.constructChan({fullfile( testCase.dir1, ...
                'kjx127a01@0-20_single.mat')}, 1);
            testCase.verifyEqual(chan1.ChanTitle, 'onset');
            testCase.verifyEqual(names(TF), {'kjx127a01@0-20_single.mat|onset'});
            
            [chan2, TF, names] = chanSpec.constructChan({fullfile( testCase.dir1, ...
                'kjx127a01@0-20_single.mat')}, 4);
            testCase.verifyEqual(chan2.ChanTitle, 'probeA07e');
            testCase.verifyEqual(names(TF), {'kjx127a01@0-20_single.mat|probeA07e'});
            
            % chanindex as numeric vector of channel indices

            [chan3, TF, names] = chanSpec.constructChan({fullfile( testCase.dir1, ...
                'kjx127a01@0-20_single.mat')}, 1:3);
            testCase.verifyEqual(size(chan3), [3, 1]);
            testCase.verifyEqual(chan3{1}.ChanTitle, 'onset');
            testCase.verifyEqual(chan3{2}.ChanTitle, 'LTS');
            testCase.verifyEqual(chan3{3}.ChanTitle, 'LTSmk');
            testCase.verifyEqual(names(TF), {'kjx127a01@0-20_single.mat|onset';...
                'kjx127a01@0-20_single.mat|LTS';...
                'kjx127a01@0-20_single.mat|LTSmk'});
            
            chan4 = chanSpec.constructChan({fullfile( testCase.dir1, ...
                'kjx127a01@0-20_single.mat')}, (1:3)'); % column vector
            testCase.verifyEqual(size(chan4), [3, 1]);
            testCase.verifyEqual(chan4{1}.ChanTitle, 'onset');
            testCase.verifyEqual(chan4{2}.ChanTitle, 'LTS');
            testCase.verifyEqual(chan4{3}.ChanTitle, 'LTSmk');
            
            
            % chanindex as cell vector of numeric vectors
       
            testCase.verifyError(@() chanSpec3.constructChan([1,5], {1:2,2:3}), ...
                'K:ChanSpecifider:constructChan:chanindex:cell:exceed');
            
            chan5 = chanSpec3.constructChan([1,5], {1:2,1});
            testCase.verifyEqual(size(chan5), [3, 1]);
            testCase.verifyEqual(chan5{1}.ChanTitle, 'onset');
            testCase.verifyEqual(chan5{2}.ChanTitle, 'LTS');
            testCase.verifyEqual(chan5{3}.ChanTitle, 'LTS');
            
            % chanindex as cell vector of cellstr
            chan6 = chanSpec3.constructChan([1,5], {{'onset','LTS'}, {'LTS'}});
            testCase.verifyEqual(chan6{1}.ChanTitle, 'onset');
            testCase.verifyEqual(chan6{2}.ChanTitle, 'LTS');
            testCase.verifyEqual(chan6{3}.ChanTitle, 'LTS');
            
            testCase.verifyError(@() chanSpec3.constructChan([1,5], {{'hoge','LTS'}, {'LTS'}}),...
                'K:ChanSpecifier:chantitles2chanind:chantitles:absent');

            % chanindex as cellstr
            chan7 = chanSpec3.constructChan(1, {'onset','LTS'});
            testCase.verifyEqual(chan7{1}.ChanTitle, 'onset');
            testCase.verifyEqual(chan7{2}.ChanTitle, 'LTS');
            
            testCase.verifyError(@() chanSpec3.constructChan(5, {'hoge'}),...
                'K:ChanSpecifider:constructChan:chanindex:cellstr:mismatch');
            
            % chanindex as char
            chan8 = chanSpec3.constructChan(5, 'LTS');
            testCase.verifyEqual(chan8.ChanTitle, 'LTS');
            
            testCase.verifyError(@() chanSpec3.constructChan(5, 'hoge'),...
                'K:ChanSpecifider:constructChan:chanindex:cellstr:mismatch');
            
            % OK down to here
            
            testCase.verifyError(@() chanSpec3.constructChan(chanSpec.MatNamesFull([1,2]),...
                {{'onset','LTS'}, {'LTS'}}), 'K:ChanSpecifider:constructChan:chanindex:cell:mismatch');
            % because full names are not unique
            
         
            
        end
       
        
        
        %% Overwrite builtin funcitons
        function test_cat(testCase)
            % clear;close all;clc; testCase = ChanSpecifier_test; disp(testCase.run('test_cat'));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            
            chanSpec = ChanSpecifier(testCase.dir1);
            
           
            %% chanSpec.ischanvalid
            [TF2, ~] = chanSpec.ismatvalid('name', @(x) ~isempty(strfind(x, 'single')));
            chanSpec2 = chanSpec.choose(TF2);
            
            [TF3, ~] = chanSpec.ismatvalid('name', @(x) ~isempty(strfind(x, 'double')));
            chanSpec3 = chanSpec.choose(TF3);
            
            %% set.List
            chanSpec0 = ChanSpecifier;
            chanSpec0.List = chanSpec2.List;
             testCase.verifyEqual(chanSpec0.MatNames,...
                {'kjx127a01@0-20_single.mat'});
            testCase.verifyEqual(chanSpec0.MatNum, 1);
            testCase.verifyEqual(chanSpec0.ChanNum, 5);
            
            
            chanSpec00 = ChanSpecifier;
            try
                chanSpec00.List = 5;
            catch mexc1
                
            end
            
            testCase.verifyError(@() throw(mexc1), 'MATLAB:InputParser:ArgumentFailedValidation')

            %% vertcat
            chanSpec4 = [chanSpec2; chanSpec3];
            testCase.verifyEqual(chanSpec4.MatNames,...
                {'kjx127a01@0-20_single.mat';...
                'kjx127a01@0-20_double.mat'});
            testCase.verifyEqual(chanSpec4.MatNum, 2);
            testCase.verifyEqual(chanSpec4.ChanNum, [5;5]);
            
            
            %% horzcat
            chanSpec5 = testCase.verifyWarning(@() [chanSpec2, chanSpec3], ...
                'K:ChanSpecifier:horzcat');
            
            testCase.verifyEqual(chanSpec5.MatNames,...
                {'kjx127a01@0-20_single.mat';...
                'kjx127a01@0-20_double.mat'});
            testCase.verifyEqual(chanSpec5.MatNum, 2);
            testCase.verifyEqual(chanSpec5.ChanNum, [5;5]);

            
        end
        
        
    end
    
end

