classdef validateMatFiles_test < matlab.unittest.TestCase & validateSpike2dataFiles_test
    % validateMatFiles_test validates format of .mat files 
    %
    % USAGE
    %   clear;close all;clc; testCase = validateMatFiles_test; res = testCase.run;disp(res);
    %
    % See also
    % ChanSpecifier, ismatched, validateSmrFiles_test, 
    % validateSpike2dataFiles_test

    properties (Dependent)
        
        dataformat
        
    end
    
    methods
        function dataformat = get.dataformat(testCase)
            
            dataformat = testCase.formats.mat;
            
        end
    end
    
    methods (Test, ParameterCombination = 'exhaustive')
        function validateMatFilenames(testCase, type, brainstate)
            % test if mat file names are valid
            %
            % clear;close all;clc; testCase = validateMatFiles_test; testCase.run('validateMatFilenames')
            
            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 

            
            list = dir(fullfile(type, brainstate, testCase.dataformat, '*.mat')); % *.mat files
            filenames = {list(:).name}';
                        
            expr = [testCase.expr.filenames, '_m\.mat$']; % regular expression

            
            TF = ismatched(filenames, expr);
            
            testCase.verifyTrue(all(TF),...
                sprintf('%s\n', filenames{~TF}));
                        
        end
        
        
        function validateDurationInFileName(testCase, type, brainstate)
            % test if duration is ~100 sec
            %
            % clear;close all;clc; testCase = validateMatFiles_test; testCase.run('validateDurationInFileName')
            
            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            thisdir = fullfile(type, brainstate, testCase.dataformat);
            
            list = dir(fullfile(thisdir, '*_m.mat')); % *_m.mat files
            filenames = {list(:).name}';
            
            expr = testCase.expr.durationInFilenames; % regular expression
            
            out = regexp(filenames, expr, 'tokens');
            
            for i = 1:length(out)
                [~,n] = size(out{i});
                
                if n == 0
                   % no match
                   testCase.verifyFalse(n == 0,...
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
                    end
                    testCase.verifyEqual(sum(dur), 100,...
                        sprintf('%s: %.2f sec\n', filenames{i}, sum(dur)));
                    
                end
            end
        end
        
        
        function validateChanTitles(testCase, type, brainstate)
            % test if chantitles are valid
            %
            % clear;close all;clc; testCase = validateMatFiles_test; testCase.run('validateChanTitles')

            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            warning off backtrace
            chanSpec = ChanSpecifier(fullfile(type, brainstate, testCase.dataformat));
            warning on backtrace
            
            if strfind(type, fullfile('probe','SUA'))

                expr = testCase.expr.chantitles_probe_mat.SUA; % regular expression
                expr_wf = testCase.expr.chantitles_probe_mat.SUA_wf; % regular expression
                expr_ev = testCase.expr.chantitles_probe_mat.SUA_ev; % regular expression


            elseif strfind(type, fullfile('probe','LFP'))
                
                expr = testCase.expr.chantitles_probe_mat.LFP; % regular expression
                expr_wf = testCase.expr.chantitles_probe_mat.LFP_wf; % regular expression
                expr_ev = testCase.expr.chantitles_probe_mat.LFP_ev; % regular expression
                
            elseif strfind(type, fullfile('juxta SUA'))
                
                expr = testCase.expr.chantitles_juxta_mat.SUA; % regular expression
                expr_wf = testCase.expr.chantitles_juxta_mat.SUA_wf; % regular expression
                expr_ev = testCase.expr.chantitles_juxta_mat.SUA_ev; % regular expression

            end
            
            TF = chanSpec.ischantitlematched(expr); %TODO does not work for 'ME1_LFP' or '^ME1_LFP$'!!!
            
            matnameschantitles = chanSpec.ChanTitlesMatNamesAll;
            
            invalidnames = reshape(matnameschantitles(~TF, [2,4])', 2, nnz(~TF)); 
            
            testCase.verifyTrue(all(TF),...
                sprintf('%s: %s\n', invalidnames{:})); %TODO not adjusted for juxta data
            
            
            %% test if there is only one EEG chennels per file
            if strfind(type, 'probe')
                expr2 = testCase.expr.chantitles_probe_mat.EEG; % regular expression
            elseif strfind(type, 'juxta')
                expr2 = testCase.expr.chantitles_juxta_mat.EEG; % regular expression
               
            end
            
            TF = chanSpec.ischantitlematched(expr2);
            testCase.verifyEqual(nnz(TF), chanSpec.MatNum, ...
                sprintf('Number of mat files containg EEG channels in the dataset (%d) does not match the number of mat files (%d).', ...
                nnz(TF), chanSpec.MatNum));
            
            EEGs = chanSpec.choose(TF);
            testCase.verifyEqual(EEGs.MatNum, chanSpec.MatNum,...
                'Not every mat file contains one EEG channel'); 
            testCase.verifyEqual(sum(EEGs.ChanNum), chanSpec.MatNum,...
                sprintf('Number of EEG channels in the dataset (%d) does not match the number of mat files (%d).', ...
                sum(EEGs.ChanNum), chanSpec.MatNum));
            
            for i = 1:chanSpec.MatNum
                thisEEG = chanSpec.choose(chanSpec.ismatvalid(i) & ...
                    chanSpec.ischantitlematched(expr2));
                
                testCase.verifyEqual(sum(thisEEG.ChanNum), 1,...
                    sprintf('%s contains %d EEG channel(s).',...
                    thisEEG.MatNames{1}, sum(thisEEG.ChanNum)));
            end
            
            %% check chantype
                        
            list = chanSpec.getstructNby1;
            
            testCase.assertTrue(isfield(list, 'chantype'),...
                'field chantype does not exist in the all the channels');
            
            chantype = {list(:).chantype}';
            chantitles = {list(:).title}';
            matfilenames = {list(:).parent}';
            
            for i = 1:length(list)
                if ismatched(chantitles{i}, expr_wf)
                    testCase.verifyTrue(ismatched(chantype{i}, 'waveform'),...
                        sprintf('%s: %s (%s)', matfilenames{i}, chantitles{i}, chantype{i}));
                    
                elseif ismatched(chantitles{i}, expr_ev)
                    testCase.verifyTrue( ismatched(chantype{i}, 'event|marker|textmark'),...
                        sprintf('%s: %s (%s)', matfilenames{i}, chantitles{i}, chantype{i}));
                end
            end

        end
        
        function validateEventChanUniqueness(testCase, type, brainstate)
            % test if chantitles are unique in the dataset (folder)
            %TODO need more help
            %
            % clear;close all;clc; testCase = validateMatFiles_test; testCase.run('validateEventChanUniqueness')
            
            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            chanSpec = ChanSpecifier(fullfile(type, brainstate, testCase.dataformat));
            
            if strfind(type, fullfile('probe','SUA'))
                
                expr_ev = testCase.expr.chantitles_probe_mat.SUA_ev_unique; % regular expression                
                
            elseif strfind(type, 'juxta_SUA')
                
                return %TODO not sure ?
                
            elseif strfind(type, fullfile('probe','LFP'))
                
                return
                
            end
            
            TF = chanSpec.ischanvalid('title', @(x) ismatchedany(x, expr_ev));
            
            eventChan = chanSpec.choose(TF);
            
            
            list = eventChan.getstructNby1('title');
            
            %% extract siteID
            
            if isempty(list)
                return
            end
                
            siteID = cellfun(@(x) x{1}, regexp({list(:).record}', ...
                '^[a-zA-Z]{1,2}', 'match'), 'UniformOutput', false); 
            %TODO Reference to non-existent field 'record'.
            
            [list(:).siteID] = siteID{:};
    
            animal_all = {list(:).animal}';
            [animal , animal_start ]= unique(animal_all); % must be always in order (by dir)
            
            if length(animal_start) > 1
                animal_end = [animal_start(2:end) - 1; length(animal_all)];
            else
                animal_end = length(animal_all);
            end
            
            for animal_ind = 1:length(animal)
                thisanimal = list(animal_start(animal_ind):animal_end(animal_ind));
                
                siteID_thisanimal = {thisanimal(:).siteID}';
                [siteID_unique , siteID_start ]= unique(siteID_thisanimal); % must be always in order (by dir)
                
                if length(thisanimal) > 1
                    siteID_end = [siteID_start(2:end) - 1; length(siteID_thisanimal)];
                else
                    siteID_end = length(siteID_thisanimal);
                end
                
                
                for site_ind = 1:length(siteID_unique)
                    
                    uniquechan = {};
                    
                    for k = siteID_start(site_ind):siteID_end(site_ind)
                        
                        testCase.verifyFalse(ismember(thisanimal(k).title, uniquechan),...
                            sprintf('%s (chan %d) in %s is not unique single unit (event) among %s%s\n', ...
                            thisanimal(k).title, thisanimal(k).channumber, thisanimal(k).parent, thisanimal(k).animal, thisanimal(k).siteID));
                        
                        if ~ismember(thisanimal(k).title, uniquechan)
                            uniquechan = [uniquechan; ...
                                thisanimal(k).title];
                        end
                        
                    end
                    
                end
            end
            
                    
        end
        
        function validateSamplingRate(testCase, type, brainstate)
            % test if sampling frequency is 17,000 Hz
            %
            % clear;close all;clc; testCase = validateMatFiles_test; testCase.run('validateSamplingRate')

            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            chanSpec = ChanSpecifier(fullfile(type, brainstate, testCase.dataformat));
                                    
            list = chanSpec.getstructNby1('interval');
            
            if ~isempty(list)
                sRate = 1./[list(:).interval]';

                for i =  1:length(sRate)
                    testCase.verifyEqual(sRate(i), 17000, 'AbsTol', 0.1,...
                        sprintf('Bad Sampling rate in %s: %s (%.1f)\n', ...
                        list(i).parent, [list(i).animal, list(i).record], sRate(i)));
                    %TODO Reference to non-existent field 'animal'.

                end
            end

        end
        
        
        function validateDuration(testCase, type, brainstate)
            % test if duration is ~100 sec
            %
            % clear;close all;clc; testCase = validateMatFiles_test; testCase.run('validateDuration')

            if ~isempty(strfind(type, ':')) && ~ispc; return; end;
            if isempty(strfind(type, ':')) && ispc; return; end;
            
            chanSpec = ChanSpecifier(fullfile(type, brainstate, testCase.dataformat));

            dur = chanSpec.getstructNby1('duration');
            
            if ~isempty(dur)
                duration = [dur(:).duration]';
                
                
                nottooshort = duration > 99.999;
                
                list = [{dur(:).parent}', strcat({dur(:).animal}', ...
                    {dur(:).record}'), {dur(:).duration}']';
                %TODO Reference to non-existent field 'animal'.
                
                testCase.verifyTrue(all(nottooshort), ...
                    [sprintf('%d out of %d channels were too short\n',...
                    nnz(~nottooshort), length(nottooshort)),...
                    sprintf('%s: %s (%.2f sec)\n',...
                    list{:, ~nottooshort})]...
                    );
                
                nottoolong = duration <= 100.0;
                
                testCase.verifyTrue(all(nottoolong),...
                    [sprintf('%d out of %d channels were too long\n', ...
                    nnz(~nottoolong), length(nottoolong)),...
                    sprintf('%s: %s (%.2f sec)\n',...
                    list{:, ~nottoolong})]...
                    );
                
                
                TF = nottooshort & nottoolong;
                
                testCase.verifyTrue(all(TF));
                
            end
        end
        
        function validatePower(testCase, type, brainstate)
            % Make sure the power of slow oscillations (0.4-1.6 Hz) is
            % above or below the specified limit for respective brain
            % state.
            %
            % clear;close all;clc; testCase = validateMatFiles_test; testCase.run('validatePower')

            if ~isempty(strfind(type, ':')) && ~ispc; return; end; 
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            chanSpec = ChanSpecifier(fullfile(type, brainstate, testCase.dataformat));
            
            if strfind(type, 'probe')
                expr = testCase.expr.chantitles_probe_mat.EEG; % regular expression
            elseif strfind(type, 'juxta')
                expr = testCase.expr.chantitles_juxta_mat.EEG; % regular expression
            end
            TF = chanSpec.ischanvalid('title', @(x) ismatchedany(x, expr));           
            chanSpec_EEGs = chanSpec.choose(TF);
            
            testCase.verifyEqual(nnz(TF), chanSpec.MatNum);           
            testCase.verifyEqual(chanSpec_EEGs.MatNum, chanSpec.MatNum);
            testCase.verifyEqual(sum(chanSpec_EEGs.ChanNum), chanSpec.MatNum);
            
            
            ratio = zeros(chanSpec_EEGs.MatNum,1);
          
            wb = [];
            for i = 1:chanSpec_EEGs.MatNum
                wbmsg = sprintf('Calculating power %d of %d', i, chanSpec_EEGs.MatNum);
                wb = K_waitbar(i, chanSpec_EEGs.MatNum, wbmsg, wb);
                
                thisfile = chanSpec_EEGs.constructRecord(i);
                thisEEG = thisfile.Chans{1}; % assume there's only one EEG files
                ratio(i) = thisEEG.powerRatio('Preset', 'slow');
            end
            close(wb);

            matnames = chanSpec.MatNames;

            if strfind(brainstate, 'act')
                upperlimit = 0.3;
                
                list = [matnames(ratio >= upperlimit), num2cell(ratio(ratio >= upperlimit).*100)]';
                testCase.verifyTrue(all(ratio < upperlimit),...
                    sprintf('%s (%.3f %%)\n', list{:})); 

            elseif strfind(brainstate, 'swa')
                lowerlimit = 0.4;
                
                list = [matnames(ratio <= lowerlimit), num2cell(ratio(ratio <= lowerlimit).*100)]';


                testCase.verifyTrue(all(ratio > lowerlimit),...
                    sprintf('%s (%.3f %%)\n', list{:})); 

            end
        
        end
        
        function validateEventChan(testCase, type, brainstate)
            % clear;close all;clc; testCase = validateMatFiles_test; testCase.run('validateEventChan')

            if ~isempty(strfind(type, ':')) && ~ispc; return; end;
            if isempty(strfind(type, ':')) && ispc; return; end; 
            
            chanSpec = ChanSpecifier(fullfile(type, brainstate, testCase.dataformat));
            
            TF = chanSpec.ischanvalid('chantype', @(x) ismatchedany(x, 'event'));           
            chanSpec_events = chanSpec.choose(TF);
            
            tooshort = {};
            nospike = {};
            
            
            for i = 1:sum(chanSpec_events.MatNum)
                
                thismat = chanSpec_events.choose(chanSpec_events.ismatvalid(i));
                thisrec = thismat.constructRecord;
               
                for j = 1:length(thisrec.Chans)
                   
                    thischan = thisrec.Chans{j};
                    
                    if min(thischan.ISI) < 0.001 
                        tooshort = [tooshort; ...
                            {sprintf('%f msec in %s %s.', min(thischan.ISI), ...
                            thisrec.RecordTitle, thischan.ChanTitle)}];
                        
                    end
                    
                    if thischan.NSpikes == 0
                        nospike = [nospike; ...
                            {sprintf('%s %s.', ...
                            thisrec.RecordTitle, thischan.ChanTitle)}];
                        
                    end

                end
                
            end
            
            testCase.verifyTrue(isempty(tooshort),...
                sprintf('%s\n', tooshort{:}));
            
            testCase.verifyTrue(isempty(nospike),...
                sprintf('%s\n', nospike{:}));
                
           
        end
        
       
    end
    
end


