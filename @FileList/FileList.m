classdef FileList
    %FileList
    %   Chan class family FileList can hold RecordInfo objects, that is
    %   it can hold meta information (RecordInfo class) about mutlipe
    %   sets (Record class) of recording data files (Chan class).
    
    properties
        ListName = '';
        List = cell(0); % column vector of cell array scontaining Record objects
        Comment = '';
    end
    
    properties (Dependent = true)
        MemberTitles = {}; % cellstr column for RecordTitle of List elements
    end
    
    methods
        function obj = FileList(varargin)
            % obj = FileList({recInfo1, recInfo2, ...})
            % obj = FileList({rec1, rec2, ...})
            % obj = FileList(____, 'Name', newname)
            %
            % obj = FileList(folderpath)
            % obj = FileList(matfilenames)
            %
            % obj = FileList(xlsxfilepath) %TODO .... not sure
            %
            %
            % obj = FileList({recInfo1, recInfo2, ...})
            % INPUT ARGUMENTS
            % info         A vector of cell array containing ChannlesInfo
            %              onjects. Even when there is only once input
            %              object, it must be handed in a cell array.
            %
            %
            % obj = FileList({rec1, rec2, ...})
            % INPUT ARGUMENTS
            % chans        A vector of cell array containing Channles
            %              onjects. Even when there is only once input
            %              object, it must be handed in a cell array.
            %
            %
            % obj = FileList(____, 'Name', newname)
            % OPTIONAL PARAM/VAL
            % 'Name'       String of name for the output object.
            %              Only effective for the two syntaxes shown above.
            %
            %
            % obj = FileList(folderpath)
            % INPUT ARGUMENTS
            % folderpath    Single input. A valid directory path that
            %               contains .mat files of Spike2 recording data in
            %               structure format.
            %
            % obj = FileList(matfilenames)
            % INPUT ARGUMENTS
            % matfilenames  Single input. A cell array of strings that are
            %               valid file paths of .mat files (including
            %               extentions) of Spike2 recording data in struct
            %               format.
            %

            
            narginchk(0, inf);
            
            
            %% Parameter/Value pairs start here
            
            PNVStart = 0;
            if nargin > 1
                
                ni = nargin; % ni >= 1
                DataInputs = 0;
                while DataInputs<ni && PNVStart==0
                    nextarg = varargin{DataInputs+1};
                    if ischar(nextarg) && isvector(nextarg)
                        PNVStart = DataInputs+1;
                    else
                        DataInputs = DataInputs+1;
                    end
                end
                
                %% Deal with PV set
                % initialize name
                if isempty(obj.ListName)
                    obj.ListName = '';
                end
                if PNVStart>0
                    for i=PNVStart:2:ni
                        % Set each Property Name/Value pair in turn.
                        Property = varargin{i};
                        if i+1>ni
                            error(eid('FileList:pvsetNoValue'), 'no value input for parameter')
                        else
                            Value = varargin{i+1};
                        end
                        % Perform assignment
                        switch lower(Property)
                            case 'name'
                                %% Assign the name
                                if ~isempty(Value) && ischar(Value)
                                    obj.ListName = Value;
                                end
                                
                            otherwise
                                error(eid('FileList:pvsetInvalid'), 'invalid parameter')
                        end % switch
                    end % for
                end
            end
            
            %% Job
            
            if PNVStart >= 2 || ~isempty(varargin) && PNVStart == 0
                
                if iscell( varargin{1}) && all(cellfun(@(x) isa(x, 'RecordInfo'), varargin{1})) ...
                        && isvector(varargin{1})
                    % obj = FileList({recInfo1, recInfo2, ...})
                    
                    newlist = varargin{1};
                    if isrow( newlist )
                        newlist = newlist';
                    end
                    
                    obj.List =newlist; % RecordInfo objects in column
                    
                    
                elseif iscell( varargin{1}) && all(cellfun(@(x) isa(x, 'Record'), varargin{1})) ...
                        && isvector(varargin{1})
                    % obj = FileList({rec1, rec2, ...})
                    
                    newlist = varargin{1};
                    if isrow( newlist )
                        newlist = newlist';
                    end
                    
                    % extract RecordInfo peoperties
                    newlist = cellfun(@(x) x.RecordInfo_, newlist, 'UniformOutput', false);
                    
                    obj.List =newlist; % RecordInfo objects in column
                    
                elseif (length(varargin) == 1 || length(varargin) == 3 )...
                        && iscellstr( varargin{1}) && isvector(varargin{1})
                    % obj = FileList(matfilenames)
                    
                    matfilenames = varargin{1};
                    if iscolumn(matfilenames)
                        matfilenames = matfilenames';
                    end
                    
                    n = length(matfilenames);
                    newlist = cell(n,1);
                    for i = 1:n
                        newlist{i} = RecordInfo(matfilenames{i});
                    end
                    
                    obj.List = newlist; % RecordInfo objects in column
                    
                    
                elseif ischar( varargin{1})
                    % obj = FileList(folderpath)
                    % obj = FileList(xlsxfilepath)
                    str = varargin{1};
                    
                    if regexp(str, '\.xlsx$', 'once');
                        % obj = FileList(xlsxfilepath)
                        
                        %TODO not sure if I need this option
                        warning(eid('FileList:xlsx:notimplemented'),...
                            'not implemented yet');
                        
                        % load the xlsx file
                        % get recInfos from the xlsx
                        
                    elseif isdir(str)
                        % obj = FileList(folderpath)
                        assert(isdir(str), eid('FileList:isdir:false'),...
                            'The input %s is not a directory', str);
                        
                        matlist = dir(fullfile(str, '*.mat'));
                        if ~isempty(matlist)
                            n = length(matlist);
                            newlist = cell(n,1);
                            for i = 1:n
                                newlist{i} = RecordInfo(fullfile(str, matlist(i).name));
                            end
                        else
                            newlist = {};
                        end
                        
                        obj.ListName = str;
                        obj.List = newlist; % RecordInfo objects in column
                        
                    end
                    
                    
                    
                else
                    error(eid('FileList:firstArg'),...
                        'Invalid syntax.')
                end
                
            else% isempty(varargin) || PNVStart == 1
                obj.List =cell(0);
                return;
            end
            
            
        end
        
        %% property get methods
        
        function memberTitles = get.MemberTitles(obj)
            memberTitles = cell(size(obj.List));
            for i = 1:length(obj.List)
                memberTitles{i} = obj.List{i}.RecordTitle;
            end
        end
        
        %% common methods
        
        loadMatFolder()
        
        
        getRecord(obj) % or lordRecord()
        getStructChan(obj)
        
        mat2xlsx(obj)
        xlsx2mat(obj)
        
        
        function tf = testProperties(obj)
            tf = K_testProperties(obj);
        end
        
        function [newobj, rootpath] = fullpath2relpath(obj)
            n = length(obj.List);
            
            for i = 1:n
                m = length(obj.List{i}.ChanTitles);
                for j = 1:m
                    
                    path = obj.List{i}.Chans{j}.Path;
                    
                    if any(regexp(path, filesep)) % full path
                        [rootpath, name, ext] = fileparts(path);
                        newpath = [name, ext];
                        obj.List{i}.Chans{j}.Path = newpath;
                        
                        %TODO what if these files are stored in different
                        %folders? rootpath doesn't work?
                        
                        % it doesn't really suppor relative path!
                        
                    end
                end
            end
            newobj = obj;
            
        end
        
        function newobj = relpath2fullpath(obj, rootpath)
            assert(ischar(rootpath) && isrow(rootpath) && isdir(rootpath), ...
                eid('relpath2fullpath:rootpath:invalid'),...
                'rootpath must be string for a directory path');
            
            n = length(obj.List);
            
            for i = 1:n
                m = length(obj.List{i}.ChanTitles);
                for j = 1:m
                    
                    path = obj.List{i}.Chans{j}.Path;
                    
                    if ~any(regexp(path, filesep)) % relative path
                        obj.List{i}.Chans{j}.Path = fullfile(rootpath, path);
                    end
                end
            end
            newobj = obj;
            
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
        
        
    end
    
    methods (Static)
        thiscol = whichcolumn(thisname, headers)
        
    end
    
end

function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K:
%
%
% input argument
% str (Optional) string in char type (row vector)
%
% output argument
% eid an error id composed of 'K:(functionname):str'

narginchk(0, 1);
p = inputParser;
p.addOptional('str', '', @(x) isempty(x) || ischar(x) && isrow(x));
p.parse(varargin{:});
str = p.Results.str;

if isempty(str)
    str = '';
else
    str = [':', str];
end

[~,m,~] = fileparts(mfilename('fullpath'));

eid = ['K:', m, str];


end

