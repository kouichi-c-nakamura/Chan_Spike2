classdef ChanSpecifier 
    %%
    % *ChanSpecifier*
    %
    % ChanSpecifier class is an extended format of the output of the
    % builtin 'dir' funciton. ChanSpecifier objects works with Chan
    % family class to go through multiple channels stored as structure
    % objects in *.mat files.
    %
    % ChanSpecifier wokrs best with *.mat files exported from Spike2 and
    % its derivatives with additional fields.
    %
    % ChanSpecifier.MatNames and ChanSpecifier.MatNamesFull are often
    % composed of unique names but NOT nocessarily.
    %
    % In ChanSpecifier.ChanTitles , each cell contains unique chantitles.
    %
    % See also
    % ChanSpecifier_test, ChanSpecifier_demo,
    % ChanSpecifier_methods_demo, ChanSpecifier_thalamus
    
    properties
        List = initlist;  % 0 x 0 empty structure

    end
    
    
    properties (Dependent = false, SetAccess = protected)
        MatNames
        MatNamesFull
        ParentDir
        ChanTitles
        ChanTitlesAll
        ChanTitlesMatNamesAll
        MatNum
        ChanNum
    end
    
    
    methods
        function chanSpec = ChanSpecifier(varargin)
            % chanSpec = ChanSpecifier(folderpath)
            %
            % folderpath    a valid folder path that contains .mat files
            %               containg structures for each channel exported
            %               from Spike2
            %
            % A modified version of the builtin 'dir' function to get
            % metadata chanSpec.List of .mat files in a specfied folder.
            %
            % Except the values field, which holds large data, chanSpec holds all the
            % other fields of channels structure in .mat files. 
            % Plus, channels in chanSpec chanSpec.List(x).channels.(chantitle) have 
            % additional fields:
            %
            % Common to all data type:
            %     chantype        {'waveform', 'event', 'marker'}           
            %     samplingrate    [Hz]
            %     timeunit        'Second'
            %     duration        in second
            %     maxtime         in second
            % 
            % Event or marker channel only
            %     numofevents   
            %     meanfiringrate  events per second            
            %
            % See also 
            % local_chanprop
            %
            % 28 Jan 2015
            % Written by Dr Kouichi C. Nakamura
            % kouichi.c.nakamura@gmail.com

            %% parse
            narginchk(0,1);
            
            p =inputParser;
            vfm = @(x) ~isempty(x) && ischar(x) && isrow(x) && isdir(x);
            p.addOptional('folderpath', '', vfm);
            
            p.parse(varargin{:});
            folderpath = p.Results.folderpath;
            
            if ispc
                sep = '\\';
            elseif ismac || isunix
                sep = '/';
            end
            
            if ~isempty(folderpath) && ~ismatchedany(folderpath, [sep, '$'])
                % if the filesep at the end is missing
                % \ is an escapre letter and filesep for Windows
            
                folderpath = [folderpath, filesep];
            end 
            
            %% job
            if isempty(folderpath)

                chanSpec = setProps(chanSpec);
                
                % return a (virtually) empty object
                %TODO method isempty has not been defined.

                return
                
            end
            
            
            matlist = dir(fullfile(folderpath, '*.mat'));
            
            matnames = {matlist(:).name}';
            n = length(matnames);
            if n == 0
                
                chanSpec = setProps(chanSpec);
               
                return
                
            end
            
            wb = [];
            for i=1:n
                %% waitbar
                wbmsg = sprintf('in progress: %d of %d', i, n);
                % wb = K_waitbar(i, n, wbmsg, wb);
                
                %%job
                
                clear S
                S = load(fullfile(folderpath, matnames{i})); 
                % in case no file found  'MATLAB:load:couldNotReadFile'
                % error

                clear chantitles
                chantitles = fieldnames(S);
                
                clear channels % Required
                for j = 1:length(chantitles)
                    
                    if strcmp(chantitles{j},'file') && ChanInfo.vf_structFile(S.(chantitles{j}))
                        
                        %NOTE ignore file structure (Spike2 version 8)
                        
                    else
                        
                        channels.(chantitles{j}) = local_chanprop(S.(chantitles{j}));
                        
                        channels.(chantitles{j}).parent = matnames{i};
                        channels.(chantitles{j}).parentdir = folderpath;
                    end
                    
                end                
                
                %% For Marker Chan only
                % get some infromation from other reference channel
                
                ismarker = structfun(@(x) strcmp(x.chantype, 'marker'), channels);
                
                if any(ismarker)
                    isevent = structfun(@(x) strcmp(x.chantype, 'event'), channels);
                    iswaveform = structfun(@(x) strcmp(x.chantype, 'waveform'), channels);
                    
                    isEorW = isevent | iswaveform;
                    
                    if any(isEorW)
                        ref = channels.(chantitles{find(isEorW, 1, 'first')});
                        
                        for j = find(ismarker')
                            channels.(chantitles{j}).interval = 1/ref.interval;
                            channels.(chantitles{j}).samplingrate = 1/ref.interval;
                            channels.(chantitles{j}).duration = (ref.length - 1)*ref.interval;
                            channels.(chantitles{j}).maxtime = ref.start + ref.duration;
                            
                            channels.(chantitles{j}).meanfiringrate = ...
                                channels.(chantitles{j}).numofevents/channels.(chantitles{j}).duration;
                            
                        end
                    else
                        warning('K:ChanSpecifier:markertype:noref',...
                            'Marker channel %s doesn''t have a reference event or waveform channel in the same mat file %s',...
                            chantitles{j}, matnames{i});
                    end
                end
                
                %% 
                
                
                matlist(i).channels = channels;
                
                matlist(i).parentdir = folderpath;
                
                
            end
            close(wb)
            
            chanSpec.List = matlist;

			chanSpec = setProps(chanSpec);
            
        end
        
        %% property set methods
        
        function chanSpec = set.List(chanSpec, newstruct)
            %
            % chanSpec = set.List(chanSpec, newstruct)
            %
            % Note: Frequently updating the List property invokes repetitive calls for
            % local function setProps and slow down. 
            % In such case, you should take out the List property as a simple structure
            %
            %    list = chanSpec.List;
            %
            % and then update the values in list. After the multiple changes, you can reflect
            % the changes by the following: 
            %            
            %   chanSpec.List = list;
            
            p = inputParser;
            vfns = @(x) isstruct(x) && ...
                (isempty(x) || ...
                isvector(x) &&  all(isfield(x, ...
                {'name','date','bytes','isdir', 'datenum', 'channels', 'parentdir'})));
            
            p.addRequired('newstruct', vfns);
            p.parse(newstruct);
            
            if isrow(newstruct)
                newstruct = newstruct';
            end
            
            chanSpec.List = newstruct; % this way keep the original class/subclass
            
			chanSpec = setProps(chanSpec);
            
        end

        
        %% Common methods
        
        function parentdir = get.ParentDir(chanSpec)

            if ~isempty(chanSpec.List)
                parentdir = {chanSpec.List(:).parentdir}';
            else
                parentdir =  '';
            end
            
        end
        
        function filelist = constructFileList(chanSpec, varargin)
            
            filelist = FileList(chanSpec.MatNamesFull, varargin{:});
                      
        end
        
        [chanSpecout, TF, names] = choose(chanSpec, TF)
        
        matind = matnamesfull2matind(chanSpec, matnamesfull)
        
        [chanind, matind] = chantitles2chanind(chanSpec, matnamesfull, chantitles)        
        
        
        %% Overwride bulitin functions
        function newchanSpec = horzcat(varargin)

            warning off backtrace
            warning('K:ChanSpecifier:horzcat',...
                'Horzcat operation is converted to vertcat instead.')
            warning on backtrace
            
            newchanSpec = vertcat(varargin{:});

        end
        
        function newchanSpec = vertcat(varargin)
            
            list = cellfun(@(x) x.List, varargin,'UniformOutput',false );
            newstruct = vertcat(list{:});
            
            newchanSpec = ChanSpecifier;
            newchanSpec.List = newstruct;
        end
        
        function eqstate = eq(obj1, obj2)
            
            if ~strcmp(class(obj1), class(obj2)) % different class
                eqstate = false;
            else
                
                propnames = properties(obj1);
                eqstate = true;
                
                for i = 1:length(propnames)
                    if  ~isequaln(obj1.(propnames{i}), obj2.(propnames{i}))
                        eqstate = false;
                        
                        %disp(propnames{i});
                        break
                    end
                end
            end
            
        end
        
        function S = saveobj(chanSpec)   
			% save as simple structure format for safety
			
			S = chanSpec.List;
        
        end
        
        
    end
    
    methods (Static)
         function chanSpec = loadobj(S)
			if isstruct(S)

				chanSpec.List = S;
         
			else
				chanSpec = S;
			end
         end
	end  
    
    methods (Access = private)
    
		%TODO need to be tested
		function pvt_chanSpec_save_result(chanSpec, result, destdir, outname, errorid)
		% pvt_chanSpec_save_result saves variable result into .mat file in destdir,
		% if specified, or a subfolder 'results' of chanSpec.ParentDir.
		%
		% pvt_chanSpec_save_result(chanSpec, result, destdir, outname, errorid)
		%
		%
		% INPUT ARGUMENTS
		%
		% chanSpec       A ChanSpecifier object. Only ParentDir property is needed.
		%
		% result         Variable of any type.
		%
		% destdir        Target directory. If empty '', then a subfolder 'results' of
		%                chanSpec.ParentDir will be used.
		%
		% outname        A specified file name for saving.
		%
		% errorid        Error id string in the format 'blah:blah' or  'blah:blah:blah:....:blah'
		%
		% See also
		% ChanSpecifier, chanSpec_getPowerSpectra, chanSpec_getPhasehistAgainstEEG, ChanSpecifer.getstats
		% K_savevar
		
		%TODO could be integrated into K_savevar?

		if isempty(result)
			warning('K:pvt_chanSpec_save_result:result:empty',...
			'result %s is empty for %s.', inputname(1), outname);

			save(fullfile(destdir, outname), 'result');
			disp(fullfile(destdir, outname));
			return
		end


		if isempty(destdir) && all(strcmp(chanSpec.ParentDir{1}, chanSpec.ParentDir))

			matdir = chanSpec.ParentDir{1};
			destdir = fullfile(matdir, 'results');

			if ~isdir(destdir)
				mkdir(destdir);
			end
		elseif isempty(destdir) && ~all(strcmp(chanSpec.ParentDir{1}, chanSpec.ParentDir))
			error(errorid, 'ParentDir values are not identical. You need to specify destdir input argument.');
		end
		save(fullfile(destdir, outname), 'result');
		disp(fullfile(destdir, outname));

		end		    
    
    end

    
end

%--------------------------------------------------------------------------

function [prop] = local_chanprop(chan, varargin)
% [prop] = local_chanprop(chan, varargin)
% 
% get information about the channel, except the bulky actual data
%
% chan             struct
%                  Structure generated by Spike2 export containing
%                  recording data in waveform, event or marker channels.
%
% prop             struct
%                  Copy of 'chan' struct except the 'values' field that
%                  contains large data but with a few additional fields.
%                  prop contains metadata of the channel without the actual
%                  data in the 'values' field.
%                  
% See also K_matfilelist
%
% 28 Jan 2015
% Written by Dr Kouichi C. Nakamura
% kouichi.c.nakamura@gmail.com

%% parse

narginchk(1,2);

p =inputParser;
vfchan = @(x) ~isempty(x) && isstruct(x) && isscalar(x);
p.addRequired('chan', vfchan);

p.parse(chan, varargin{:});



%% job

[finamesW, finamesE, finamesNotE, finamesM] = local_fieldnames();


prop = chan;
if isfield(prop, 'values')
    prop = rmfield(prop, 'values');
end

if all(isfield(chan, finamesW))
    chantype = 'waveform';
elseif all(isfield(chan, finamesE)) && all(~isfield(chan, finamesNotE))
    chantype = 'event';
elseif all(isfield(chan, finamesM))
    chantype = 'marker';
else
    chantype = 'others';
end

prop.chantype = chantype;

prop.timeunit = 'Second';
        
switch chantype
    case 'waveform'
        prop.samplingrate = 1/chan.interval;
        prop.duration = (chan.length - 1)*chan.interval;
        prop.maxtime = chan.start + prop.duration;

        
    case 'event'
        
        prop.samplingrate = 1/chan.interval;
        prop.duration = (chan.length - 1)*chan.interval;
        prop.maxtime = chan.start + prop.duration;
        
        prop.numofevents = nnz(chan.values);
        prop.meanfiringrate = prop.numofevents/prop.duration;
        
    case 'marker'
        %samplingrate duration maxtime must be handled separetely because of the lack of chan.interval

        prop.numofevents = chan.length;

    case 'others'
        %TODO
        warning('Other data types are not implemented');
end



end

%--------------------------------------------------------------------------

function [finamesW, finamesE, finamesNotE, finamesM]= local_fieldnames()

finamesW ={ 'title',...
    'comment',...
    'interval',...
    'scale',...
    'offset',...
    'units',...
    'start',...
    'length',...
    'values'};

finamesE ={ 'title',...
    'comment',...
    'interval',...
    'start',...
    'length',...
    'values'};

finamesNotE ={'scale',...
    'offset',...
    'units',...
    'codes',...
    'resolution'};

finamesM ={'title',...
    'comment',...
    'resolution',...
    'length',...
    'times',...
    'codes'};
end

%--------------------------------------------------------------------------

function chanSpec = setProps(chanSpec)
% chanSpec = setProps(chanSpec)
%
% For the sake of speed, although the following properties are essentially
% dependent properties, they are set up during construction and on other
% occations only. Computing each value at runtime takes much more time.
%
% MatNames
% MatNamesFull
% ChanTitles (see %NOTE below)
% MatNum
% ChanNum
% ChanTitlesAll
% ChanTitlesMatNamesAll

%% MatNames

list = chanSpec.List;
chanSpec.MatNames = {list(:).name}';

%% MatNamesFull

if ~isempty(list)

	matnames = {list(:).name}';

	dirpaths = {list(:).parentdir}';

	matnamesfull = cellfun(@(x,y) fullfile(x,y), dirpaths, matnames, 'UniformOutput', false);
else
	matnamesfull = {};

end

chanSpec.MatNamesFull = matnamesfull;


%% ChanTitles

n = length(list);
chantitles = cell(n,1);
for i = 1:n
	chantitles{i} = fieldnames(list(i).channels);
end

chanSpec.ChanTitles = chantitles; 

%NOTE they are field names of structure. So illegal characters like a space
%has been escaped by _. Not to be confused with the "title" field of each
%channel structure in *.mat file

%% MatNum            

chanSpec.MatNum = length(chanSpec.List);

%% ChanNum
chantitles = chanSpec.ChanTitles;
chanSpec.ChanNum = cellfun(@(x) length(x), chantitles);

%% ChanTitlesAll

chanSpec.ChanTitlesAll = vertcat(chanSpec.ChanTitles{:});

%% ChanTitlesMatNamesAll

channum = chanSpec.ChanNum;

titles = cell(sum(channum), 4);            
matnames = chanSpec.MatNames;

k = 1;
for i = 1:chanSpec.MatNum

	titles(k:k+channum(i)-1, 1) = num2cell(ones(channum(i), 1).*i);

	buffer = cell(channum(i), 1);
	buffer(:) = matnames(i);
	titles(k:k+channum(i)-1, 2) = buffer;
	
	titles(k:k+channum(i)-1, 3) = num2cell((1:channum(i))');

	k = k+channum(i);

end

titles(:,4) = vertcat(chanSpec.ChanTitles{:});

chanSpec.ChanTitlesMatNamesAll = titles;

end

%--------------------------------------------------------------------------

function list = initlist()
%NOTE R2016b introduced new 'folder' field
% this change in builtin dir function causes version-dependence in
% the behaviour of ChanSpecifier

if verLessThan('matlab','9.1')
    
    list = struct('name', {}, 'date',{}, 'bytes',{}, 'isdir', {}, ...
        'datenum', {}, 'channels', {}, 'parentdir', {});
else
    list = struct('name', {},'folder',{}, 'date',{}, 'bytes',{}, 'isdir', {}, ...
        'datenum', {}, 'channels', {}, 'parentdir', {});
    %R2016b (9.1) uses new 'folder' field for dir output  
end
end



