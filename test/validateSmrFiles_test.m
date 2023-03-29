classdef validateSmrFiles_test < matlab.unittest.TestCase & validateSpike2dataFiles_test
    %Validate format of .smr files
    %
    % USAGE
    %   clear;close all;clc; testCase = validateSmrFiles_test; res = testCase.run;disp(res);
    %
    % See also
    % ChanSpecifier, ismatched, validateMatFiles_test, validateSpike2dataFiles_test
    %
    % probe/SUA and probe/LFP (act, actdelta, swa)
    %
    % 7/24/2015 14:19
    % Totals:
    %    60 Passed, 0 Failed, 0 Incomplete.
    %    1326.5603 seconds testing time.
    
    
    properties (Dependent)
        
        dataformat
        
    end
    
    methods
        function dataformat = get.dataformat(testCase)
            
            dataformat = testCase.formats.smr;
            
        end
    end
    
    
    methods (Test, ParameterCombination = 'exhaustive')
        function validateSmrFilenames(testCase, type, brainstate)
            % test if mat file names are valid
            %
            % clear;close all;clc; testCase = validateSmrFiles_test; testCase.run('validateSmrFilenames')
            
            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            list = dir(fullfile(type, brainstate, testCase.dataformat, '*.smr')); % *.smr files
            filenames = {list(:).name}';
            
            expr = [testCase.expr.filenames, '\.smr$']; % regular expression
            
            TF = ismatched(filenames, expr);
            
            testCase.verifyTrue(all(TF),...
                sprintf('%s\n', filenames{~TF}));
            
        end
        
        function validateChanTitles(testCase, type, brainstate)
            % test if chantitles are valid
            %
            % clear;close all;clc; testCase = validateSmrFiles_test; testCase.run('validateChanTitles')
            
            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            thisdir = fullfile(type, brainstate, testCase.dataformat);
            
            list = dir(fullfile(thisdir, '*.smr')); % *.smr files
            filenames = {list(:).name}';
            
            if strfind(type, 'SUA')
                
                expr = testCase.expr.chantitles_smr.SUA; % regulear expression
                expr_wf = testCase.expr.chantitles_smr.SUA_wf;
                expr_ev = testCase.expr.chantitles_smr.SUA_ev;
                
                
            elseif strfind(type, 'LFP')
                expr = testCase.expr.chantitles_smr.LFP; % regulear expression
                expr_wf = testCase.expr.chantitles_smr.LFP_wf;
                expr_ev = testCase.expr.chantitles_smr.LFP_ev;
            end
            
            expr_EEG = testCase.expr.chantitles_smr.EEG; % regulear expression
            
            for i = 1:length(filenames)
                
                fid = fopen(fullfile(thisdir, filenames{i}));
                chanList = SONChanList(fid);
                chantitles = {chanList(:).title}';
                chankinds = [chanList(:).kind]';
                
                
                TF = ismatched(chantitles, expr);
                testCase.verifyTrue(all(TF), ...
                    sprintf('%s: %s', filenames{i}, strjoin(chantitles(~TF)'), ','));
                
                TF_wf = ismatched(chantitles, expr_wf);
                chant = chantitles(TF_wf)';
                testCase.verifyEqual(chankinds(TF_wf), ones(nnz(TF_wf), 1).*1,...
                    sprintf('%s: %s', filenames{i}, strjoin(chant(chankinds(TF_wf) ~= 1)), ','));
                
                TF_ev = ismatched(chantitles, expr_ev);
                chant = chantitles(TF_ev)';
                testCase.verifyTrue(all(chankinds(TF_ev) == 3 | chankinds(TF_ev) == 2 | chankinds(TF_ev) == 8 ),...
                    sprintf('%s: %s', filenames{i}, strjoin(chant(chankinds(TF_ev) ~= 3)), ','));
                
                %% check if EEG channel is unique
                TF2 = ismatched(chantitles, expr_EEG);
                testCase.verifyEqual(nnz(TF2), 1, ...
                    sprintf('EEG is not unique in %s\n', filenames{i}));
                
                
                fclose(fid);
                clear fid chanList
            end
        end
        
        function validateSamplingRate(testCase, type, brainstate)
            % test if ideal sampling rate frequency is 17,857 Hz
            %
            % clear;close all;clc; testCase = validateSmrFiles_test; testCase.run('validateSamplingRate')
            
            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            thisdir = fullfile(type, brainstate, testCase.dataformat);
            
            list = dir(fullfile(thisdir, '*.smr')); % *.smr files
            filenames = {list(:).name}';
            
            for i = 1:length(filenames)
                
                fid = fopen(fullfile(thisdir, filenames{i}));
                chanList = SONChanList(fid);
                chantitles = {chanList(:).title}';
                channum = [chanList(:).number]';
                
                
                if strfind(type, 'SUA')
                    % exclude Event Channels
                    
                    expr = testCase.expr.chantitles_smr.SUA_wf; % regular expression
                    TF = ismatched(chantitles, expr);
                    
                    chantitles = chantitles(TF);
                    channum = channum(TF);
                    
                end
                
                
                for j = 1:length(channum)
                    
                    TChannel = SONChannelInfo(fid, channum(j));
                    testCase.verifyEqual(TChannel.idealRate, 17857,...
                        'AbsTol', 0.2, ...% most of files are 17857 but some are 17857.142578125
                        sprintf('Bad Sampling rate in %s: %s\n', filenames{i}, chantitles{j}));
                    
                end
                
                fclose(fid);
                clear fid chanList TChannel
            end
        end
        
        
        function validateDurationInFileName(testCase, type, brainstate)
            % test if duration is ~100 sec
            %
            % clear;close all;clc; testCase = validateSmrFiles_test; testCase.run('validateDurationInFileName')
            
            
            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            thisdir = fullfile(type, brainstate, testCase.dataformat);
            
            list = dir(fullfile(thisdir, '*.smr')); % *.smr files
            filenames = {list(:).name}';
            
            expr = testCase.expr.durationInFilenames; % regular expression
            
            out = regexp(filenames, expr, 'tokens');
            
            for i = 1:length(out)
                [~,n] = size(out{i});
                
                if n == 0
                    % no match
                    testCase.verifyFalse(n == 0, ...
                        sprintf('Ireggular file name in %s\n', filenames{i}));
                    
                elseif n > 0
                    % n matches
                    dur = zeros(n, 1);
                    for j = 1:n
                        from = str2double(out{i}{j}{1});
                        to = str2double(out{i}{j}{2});
                        
                        testCase.verifyGreaterThan(to, from,...
                            sprintf('from >= to in %s: from %.2f to %.2f sec\n', filenames{i}, from, to));
                        dur(j) = to - from;
                        clear to from
                    end
                    testCase.verifyEqual(sum(dur), 100, ...
                        sprintf('%s: %.2f sec\n', filenames{i}, sum(dur)));
                    
                end
            end
            
        end
        
        function validateEventChanUniqueness(testCase, type, brainstate)
            % clear;close all;clc; testCase = validateSmrFiles_test; testCase.run('validateEventChanUniqueness')
            
            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            if strfind(type, 'LFP')
                return
            end
            
            thisdir = fullfile(type, brainstate, testCase.dataformat);
            
            list = dir(fullfile(thisdir, '*.smr')); % *.smr files
            filenames = {list(:).name}';
            
            
            animal_all = cellfun(@(x) x{1}, regexp(filenames, '^kjx\d{3}', 'match'), ...
                'UniformOutput', false);
            
            [animal , animal_ind ]= unique(animal_all); % must be always in order (by dir)
            
            if length(animal_ind) > 1
                animal_N = [animal_ind(2:end) - 1; length(animal_all)];
            else
                animal_N = length(animal_all);
            end
            
            for i = 1:length(animal)
                
                filenames_thisanimal = filenames(animal_ind(i):animal_N(i));
                
                siteID_thisanimal =  cellfun(@(x) x{1}{1}, ...
                    regexp(filenames_thisanimal, '^kjx\d{3}([a-zA-Z]{1,2})\d{1,2}', 'tokens'), ...
                    'UniformOutput', false);
                
                [siteID_unique , siteID_ind ]= unique(siteID_thisanimal); % must be always in order (by dir)
                
                if length(filenames_thisanimal) > 1
                    siteID_N = [siteID_ind(2:end) - 1; length(siteID_thisanimal)];
                else
                    siteID_N = length(siteID_thisanimal);
                end
                
                
                for j = 1:length(siteID_unique)
                    
                    uniquechan = {};
                    
                    for k = siteID_ind(j):siteID_N(j)
                        
                        fid = fopen(fullfile(thisdir, filenames_thisanimal{k}));
                        chanList = SONChanList(fid);
                        chantitles = {chanList(:).title}';
                        
                        fclose(fid);
                        
                        for l = 1:length(chantitles)
                            if ~isempty(regexp(chantitles{l}, testCase.expr.chantitles_mat.SUA_ev_unique, 'ONCE'))
                                
                                testCase.verifyFalse(ismember(chantitles(l), uniquechan),...
                                    sprintf('%s (chan %d) in %s is not unique single unit (event) among %s%s\n', ...
                                    chantitles{l}, chanList(l).number, filenames_thisanimal{k}, animal{i}, siteID_unique{j}));
                                
                                if ~ismember(chantitles(l), uniquechan)
                                    uniquechan = [uniquechan; ...
                                        chantitles(l)];
                                end
                            end
                        end
                        clear fid chanList

                        
                    end
                end
                
            end
            
        end
    end
    
end  
    
    
