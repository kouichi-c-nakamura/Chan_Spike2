classdef BUAparameters
    %
    % As long as you know where those parameter file is, you can repeat the process many times
    %
    % For threshold of findpeaks, you can set the coefficient that is used
    % by multiplied with SD of high-pass filtered data.
    %
    % For spike removal window, I found that the optimal or minimum window
    % size can vary from neuron to neuron. This class allows you to set
    % spike removal window one-by-one, and save the parameters into a table
    % format in .mat file. You can also overdraw average waveforms as many
    % as you want to see validate the choice quickly.
    %
    %
    % See also
    % getBUA_params_test, getBUA, ChanSpecifier
    
    
    properties
        Tparams      % table
        chanSpec     % ChanSpecifier object
        tf = [];
        basedir = '' % Full path to "Where Private_Dropbox"
        paramdirpath % path to the folder to locate/save the table data for parameters
        paramfile = 'BUAparameters.mat' % file name
        SpikeWindefault = [1.5,2.5]

    end
    
    properties (Hidden)
        orderdefault = 3
        SDxdefault = 3
    end
    
    properties (Dependent = true)
        SDx % double; The threshold ... how many times of standard deviation?
        % If Tparams does not exist, SDx = 3 is used
        % If Tparams is already available, use the value stored in it
        order % see orderdefault property
    end
    
%     properties (Dependent = true, Hidden)
%         chanSpec_
%     end
    
    properties (SetAccess = private, Hidden)
        headers =  {'parentdir','matname','chantitle','SpikeWin1','SpikeWin2'};
    end
    
    methods
        function obj = BUAparameters(chanSpec,paramdirpath,basedir)
            % obj = BUAparameters(chanSpec,paramdirpath,basedir)
            %
            % chanSpec        a ChanSpecifier object
            % 
            % paramdirpath    table data will be saved in paramdirpath
            %
            % basedir         basedir is used to make full paths adapt to 
            %                 environment (reletive to the top Dropbox folder)
            %
            % See also
            % BUAparameters.averagewaveformSome, ChanSpecifier
            
            
            assert(isa(chanSpec,'ChanSpecifier'));
            
            obj.chanSpec = chanSpec;
            
            fullmat = fullfile(paramdirpath,obj.paramfile);
            
            assert(isdir(basedir))
            
            obj.basedir = basedir;
            obj.paramdirpath = paramdirpath;

            
            if exist(fullmat,'file') == 2
                % load table data from .mat file
                S = load(fullmat); % Tparams
                
                assert(isequal(S.Tparams.Properties.VariableNames,...
                    obj.headers))
                
                obj.Tparams = S.Tparams;
                clear S
                

                % get the stored value
                obj.SDx = obj.Tparams.Properties.UserData.SDx;
                obj.order = obj.Tparams.Properties.UserData.order;
                
                obj = changepathplatform(obj); 
                % Needs to update full path to adapt to environment
                

            else
                % create
                
                C = repmat({'','','',[],[]},0,1);
                obj.Tparams = cell2table(C,'VariableNames',obj.headers);
                
                obj.Tparams.Properties.UserData.SDx   = obj.SDxdefault; % store the default value
                obj.Tparams.Properties.UserData.order = obj.orderdefault; % store the default value
            end
        end
        
        %--------------------------------------------------------------------------
        
        function SDx = get.SDx(obj)
            if istable(obj.Tparams)
                SDx = obj.Tparams.Properties.UserData.SDx;
            else
                SDx = obj.SDxdefault;
            end
            
        end
        
        %--------------------------------------------------------------------------
        
        function obj = set.SDx(obj,newSDx)    
            
            obj.Tparams.Properties.UserData.SDx = newSDx;
            
        end
        
        %--------------------------------------------------------------------------
        
        function obj = set.tf(obj,newTF)    
            
            narginchk(2,2)
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('newTF', @(x) iscolumn(x) && all(x == 1 | x == 0));
            p.parse(obj,newTF);
            
            assert(length(newTF) == sum(obj.chanSpec.ChanNum),...
                'Wrong size of vector newTF'); %#ok<MCSUP>

            obj.tf = newTF; 
            
        end
             
        %--------------------------------------------------------------------------
        
        function tf = get.tf(obj)
            
            if isempty(obj.tf)
                tf = true(sum(obj.chanSpec.ChanNum),1); % fake it
            else
                tf = obj.tf;
            end
        end
        %--------------------------------------------------------------------------

        function SDx = get.order(obj)
            if istable(obj.Tparams)
                SDx = obj.Tparams.Properties.UserData.order;
            else
                SDx = obj.orderdefault;
            end
            
        end
        %--------------------------------------------------------------------------
        
        function obj = set.order(obj,newOrder)
            obj.Tparams.Properties.UserData.order = newOrder;
        end

        %--------------------------------------------------------------------------
        
        status = inspectThresholdOne(obj,m,ch)
        
        %--------------------------------------------------------------------------
        
        inspectThresholdMany(obj,tf)
        
        %--------------------------------------------------------------------------
        
        [objout,spikeWin,width_ms,status,figh] = averagewaveformOne(obj,m,ch,varargin)
        
        %--------------------------------------------------------------------------
        
        obj = averagewaveformMany(obj,tf)
        
        %--------------------------------------------------------------------------
        
        obj = averagewaveformRest(obj)
        
        %--------------------------------------------------------------------------
        function thre = getThre(obj,W)
            % returns thredhold value for WaveformChan object W
            %
            % thre = getThre(obj,W)
            %
            % W      WaveformChan object. W must be included in
            %        ChanSpecifier object that is used to construct obj.
            %
            % thre = std(obj.highpass(W))*obj.SDx; % SD * SDx
            %
            % See also
            % BUAparameters.getSpikeWin
            
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('W',@(x) isa(x,'WaveformChan'));

            p.parse(obj,W); 
           
            thre = std(obj.highpass(W))*obj.SDx; % SD * SDx
            
        end
        
        %--------------------------------------------------------------------------

        function spikeWin = getSpikeWin(obj,m,ch)
            % spikeWin = getSpikeWin(obj,m,ch)
            %
            % INPUT ARGUMENTS
            % obj         BUAparameters object
            %
            % m           A numerical index (integer) of mat file in ChanSpecifier
            %             object that was used to construct obj
            %
            % ch          A numerical index (integer) of a channel in a mat
            %             file specified by m in ChanSpecifier object that
            %             was used to construct obj
            %
            %
            % OUTPUT ARGUMENTS
            % spikeWin    [pre,post]
            %             A two element vector representing spike removal
            %             window for pre-spike and post-spike in millisecond.
            %
            %
            % See also
            % BUAparameters.getThre
            
            vfscintpos = @(x) isscalar(x) && fix(x) == x && x > 0;
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('m',vfscintpos);
            p.addRequired('ch',vfscintpos);
            
            p.parse(obj,m,ch);
            
            row = obj.mch2row(m,ch);
            
            if isempty(row)
                spikeWin = obj.SpikeWindefault;
            else
                spikeWin = [obj.Tparams.SpikeWin1(row),obj.Tparams.SpikeWin2(row)];
            end
        
        end
        
        %--------------------------------------------------------------------------
        
        function Whigh = highpass(obj,W)
            Wn = normalizedfreq(300,W.SRate);
            [b,a] = butter(obj.order,Wn,'high');
            Whigh = W;
            Whigh.Data = filtfilt(b,a,W.Data);
        end
        
        %--------------------------------------------------------------------------
        
        [m,ch] = row2mch(obj,row)
        
        %--------------------------------------------------------------------------
        
        row = mch2row(obj,m,ch)

        %--------------------------------------------------------------------------

        function saveTparams(obj)
            % If you're in debug mode after an error, you can still save
            % the current results by moving to a Work Space where you can
            % access to a BUAparameters object hodling data and run
            % "saveTparams(obj)" in command line ("obj" can be the variable name of
            % the BUAparameters object in the Work Space)
            %
            %
            while 1
                commandwindow
                
                button = questdlg(sprintf('Do you want to save the changes in obj.Tparams to %s?',...
                    obj.paramfile),'Confirmation','OK','Cancel','OK');
                switch button
                    case 'OK'
                        Tparams = obj.Tparams;
                        paramdirpath = obj.paramdirpath; %#ok<*PROP>
                        stem = regexprep(obj.paramfile,'\.mat$',''); % no need for  extention
                        
                        K_savevar(stem,paramdirpath,Tparams);
                        
                        figh = gcf;
                        if ishandle(figh)
                            figure(figh);
                        end
                        break
                    case 'Cancel'
                        disp('Operation cancelled. No change has been saved.');
                        break
                end
            end
        end
    end
    
    
    
    methods (Access = protected)
        function objout = updateT(obj,newT,m,ch)
            
            row = mch2row(obj,m,ch);
            
            assert(isequal(obj.Tparams.Properties.VariableNames,...
                newT.Properties.VariableNames))
            
            if isempty(row) || row > size(obj.Tparams,1)
                objout = appendT(obj,newT);
            else
                objout = overwriteT(obj,newT,row);
            end
            
        end
        %--------------------------------------------------------------------------
        function objout = appendT(obj,newT)
            
            objout = obj;
            try
                objout.Tparams = [obj.Tparams; newT];
            catch Mexc1
               if strcmp(Mexc1.identifier, 'MATLAB:table:vertcat:VertcatMethodFailed')
                   disp('unknown cause');
               end
               throw(Mexc1)
            end
            checkUniquenessOfTparams(obj)
        end
        %--------------------------------------------------------------------------
        function objout = overwriteT(obj,newT,row)
            
            if isempty(obj.Tparams)
                obj.Tparams = [obj.Tparams; newT];
            end
            
            objout = obj;
            objout.Tparams(row,:) = newT;
            
            checkUniquenessOfTparams(obj)
        end
        
        %--------------------------------------------------------------------------
        function newT = prepareNewT(obj,spikeWin,m,ch)
            % See also
            % ChanSpecifier.changepathplatform
            
            p = inputParser;
            p.addRequired('obj');
            p.addRequired('spikeWin',@(x) isrow(x) && numel(x) == 2 && all(x >= 0));
            p.addRequired('m', @(x) isscalar(x) && x > 0 && fix(x) == x);
            p.addRequired('ch',@(x) isscalar(x) && x > 0 && fix(x) == x);

            p.parse(obj,spikeWin,m,ch);
            
            
            chSp = obj.chanSpec;
                        
            strct.parentdir = chSp.ParentDir(m);
            strct.matname   = chSp.MatNames(m);
            strct.chantitle = chSp.ChanTitles{m}(ch); %NOTE must be cellstr of 1 element
            %NOTE S.title is different from the field name of structure in .mat files
            
            strct.SpikeWin1 = spikeWin(1);
            strct.SpikeWin2 = spikeWin(2);
            
            newT = struct2table(strct);
            
        end
        
                %--------------------------------------------------------------------------
        function checkUniquenessOfTparams(obj)
            % See also
            % BUAparameters.Tparams
            
           
            if ~isempty(obj.Tparams)
                
                Tmatchanfull = fullfile(obj.Tparams.parentdir,obj.Tparams.matname,...
                    obj.Tparams.chantitle);
                
                assert(isempty(setdiff(Tmatchanfull,unique(Tmatchanfull))));
                
            end
        end
        
        %--------------------------------------------------------------------------
        
        function objout = changepathplatform(obj)
            % Updates full path information in obj.Tparams based on
            % relative path fronm obj.basedir
            %
            % See also
            % ChanSpecifier.changepathplatform
            
            if isempty(obj.Tparams)
                objout = obj;
                return
                
            else
                esc = @(x) regexptranslate('escape',x);
                
                basedirsp = strsplit(obj.basedir,filesep);
                
                Tparentdir = obj.Tparams.parentdir;
                
                loc = regexp(Tparentdir,basedirsp(end),'end'); % isequal(basedirsp(end),'Private_Dropbox')
                assert(all(cellfun(@(x) isscalar(x) && isnumeric(x) && x > 0 && x == loc{1}, loc)));
                
                oldbasedir = Tparentdir{1}(1:loc{1});
                
                Tnewparentdir = unipath(regexprep(Tparentdir,...
                    ['^',esc(oldbasedir)],esc(obj.basedir)));
                
                objout = obj;
                objout.Tparams.parentdir = Tnewparentdir; % change platform and update full path
            end
            
        end
        
    end
    %--------------------------------------------------------------------------
    methods (Static)
        
    end
end
