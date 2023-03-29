function [TFchan, names, TFmat] = ismatvalid(chanSpec, varargin)
% ismatvalid returns TFchan, logical index of channels for mat files whose field 
% 'matpropname' satisfies condition 'func', names, which corresponds to the index, and 
% TFmat logical index for the mat files.
%
% [TFchan, names, TFmat] = ismatvalid(chanSpec)
% [TFchan, names, TFmat] = ismatvalid(chanSpec, matpropname, func)
% [TFchan, names, TFmat] = ismatvalid(chanSpec, index)
% [TFchan, names, TFmat] = ismatvalid(chanSpec, 'gui')
% [TFchan, names, TFmat] = ismatvalid(chanSpec, 'guimat')
% [TFchan, names, TFmat] = ismatvalid(chanSpec, TFin) 
% 
% INPUT ARGUMETS
% chanSpec      a ChanSpecifier object
%
% index         A vector of positive integers that specifies mat files in
%               chanSpec
%
% OUTPUT ATGUMENTS
% TFchan        vertical vector of logical 
%               logical values for channels included in each .mat file in
%               order. The length of TFchan is the same as sum(chanSpec.ChanNum).
% 
% names         So that you can tell which value is which, this cell array
%               of strings has the same size as TFchan. It contains name of
%               each .mat files and title of each channel that
%               corresponds to the TFchan. names(TFchan) gives you the file names
%               and chan titles of the selection.
%
% TFmat         Logical vector whose length equals to chanSpec.MatNum.
%
%
% SYNTAXES and OTHER INPUT ARGUMENTS
% [TFchan, names, TFmat] = ismatvalid(chanSpec)
%    TFchan is all true
%
%
% [TFchan, names, TFmat] = ismatvalid(chanSpec, matpropname, func)
%
%    matpropname    String (char type). The field name of structure at the top 
%               level in a mat file chanSpec.List.('matpropname') that is to be
%               evaluated
% 
%    func       function handle of a function or anonymous function that
%               returns true or false (or 1 or 0).
%
% EXAMPLES
%      [TFchan, names, TFmat] = ismatvalid(chanSpec, 'name', @(x) ismatchedany(x, '^kjx127b'))
%      [TFchan, names, TFmat] = chanSpec.ismatvalid('name', @(x) ismatchedany(x, '^kjx127b'))
%
%
% [TFchan, names, TFmat] = ismatvalid(chanSpec, TFin)
%
%    TFin       A vertical vector of logical. 
%               The TFchan output of ismatvalid or ischanvalid methods of
%               ChanSpecifier can be used as an input argument to obtain TFchan
%               for the parent .mat files. This is useful when you want to
%               identify the parent .mat files.
%
%               %TODO how about prepare a method allind2tf?
%               % difficult to fix exisiting code though
%
%
% [TFchan, names, TFmat] = ismatvalid(chanSpec, 'gui')
%    'gui'  Call listdlg for GUI input to select files and channels.
%
% [TFchan, names, TFmat] = ismatvalid(chanSpec, 'guimat')
%    'guimat'  Call listdlg for GUI input to select mat files.
%
% See also
% ChanSpecifier.ischanvalid, ChanSpecifier.choose, ismatchedany
%
% 30 Jan 2015
% Written by Dr Kouichi C. Nakamura
% kouichi.c.nakamura@gmail.com


%% parse
narginchk(1,3);


switch nargin
    case 2
        
        if ischar(varargin{1})
            assert(ismember(varargin{1}, {'gui', 'guimat'}), ...
                eid('gui:argininvalid'),...
                'The second input argument is not valid. ''gui'' or ''guitmat'' is expected.');
        elseif isnumeric(varargin{1})
            index = varargin{1};
            assert(isvector(index) && all(index > 0 & fix(index) == index), ...
                eid('index:argininvalid'),...
                'The second input argument is not valid. index must be numeric vector of positive integers.');
            
            if isrow(index)
                index = index';
            end
            
        elseif islogical(varargin{1})
            TFin = varargin{1};
            assert(iscolumn(TFin), ...
                eid('TFin:argininvalid'),...
                'The second input argument is not valid. TFin must be a column vector of logical');
          
            assert(length(TFin) == sum(chanSpec.ChanNum), ...
                eid('TFin:invalidlength'),...
                'The second input argument is not valid. TFin must be a column vector of logical with the length that eqauls to sum of chanSpec.ChanNum.');          
        else
            error(eid('guiorindex:argininvalid'),...
            'The second input argument is invalid. ');  
            
        end
        
    case 3
   
        matpropname = varargin{1};
        
        assert(ischar(matpropname) && isrow(matpropname),...
            eid('matpropname:argininvalid'),...
            'The second input argument is not valid for a field name.');
        
        func = varargin{2};
        
        assert(isscalar(func) && isa(func, 'function_handle'),...
            eid('func:argininvalid'),...
            'The third input argument is not a valid function handle.');

end


%% job
n = chanSpec.MatNum;
matnames = chanSpec.MatNames;

TFchan = false(sum(chanSpec.ChanNum), 1);
TFmat = false(chanSpec.MatNum, 1);


names = chanSpec.ChanTitlesMatNamesAll;
names = cellfun(@(x,y) horzcat(x, '|', y), names(:,2), names(:,4), 'UniformOutput', false);


switch nargin
    case 1
        TFchan(:) = true;
    case 2 
        if strcmpi(varargin{1}, 'gui')
            % listdlg option
            [answer,OK] = listdlg('PromptString','Select files / channels:',...
                'SelectionMode','multiple',...
                'ListString',matnames, 'ListSize', [300, 300], 'InitialValue', 1:length(matnames));
            
            if ~OK
                error(eid('listdlgcancelled'), ...
                    'Cancelled by User');
            end
            
            [logicind_channel] = local_matindex2channels(chanSpec, answer);
            
            TFchan(logicind_channel) = true;
            
        elseif strcmpi(varargin{1}, 'guimat')
            
            matnames = chanSpec.MatNames;
            
            [answer,OK] = listdlg('PromptString','Select files:',...
                'SelectionMode','multiple',...
                'ListString', matnames, 'ListSize', [300, 300], 'InitialValue', 1:length(matnames));
            
            if ~OK
                error(eid('listdlgcancelled'), ...
                    'Cancelled by User');
            end
            
            for i = 1:length(answer)
                [logicind_channel] = local_matindex2channels(chanSpec, answer(i));
                
                TFchan(logicind_channel) = true; % channel
            end
            
            
        elseif exist('index','var')
            % index input
            for i = 1:length(index)
                [logicind_channel] = local_matindex2channels(chanSpec, index(i));
                
                TFchan(logicind_channel) = true; % channel
            end
        elseif  exist('TFin','var')
            % TFin input
            
            channum = chanSpec.ChanNum;
            
            k = 0;
            for i = 1:n
                
                if any(TFin(k + 1 : k + channum(i)))
                    [logicind_channel] = local_matindex2channels(chanSpec, i);
                    
                    TFchan(logicind_channel) = true; % channel
                end
                
                k = k +  channum(i); % SLOW
            end

            
        else
            error(eid('nargin2:unexpected'),...
            'The second input argument is invalid.');  
        end
        
    case 3

        for i = 1:n

            if isfield(chanSpec.List(i), matpropname)
                res = func(chanSpec.List(i).(matpropname));
                if isscalar(res) && islogical(res) || ...
                        ( isnumeric(res) && ( res == 1 || res == 0 ) )
                    switch res
                        case 1
                            
                            [logicind_channel] = local_matindex2channels(chanSpec, i);
                            
                            TFchan(logicind_channel) = true; % channel
                        case 0
                            % channel: no change
                    end
                else
                    error(eid('func:not1or0'),...
                        'The output of validation fuction func must be either 1 or 0 (numeric or logical)');
                end
            else % field not exist
                
                % channel: no change
            end

        end
end




%% TFmat
channum = chanSpec.ChanNum;

for i = 1:chanSpec.MatNum
    
    TFmat(i) = any(TFchan(sum(channum(1:(i - 1))) + 1:...
        sum(channum(1:(i - 1))) + channum(i)));
    
end
    


    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [logicind_channel] = local_matindex2channels(chanSpec, indmat)
% [logicind_channel] = local_matindex2channels(chanSpec, indmat)
% Convert numerical index for 'matnames' into logical index for 'chanSpec.List' and
% 'names'
%
% INPUT ARGUMENTS
% chanSpec           ChanSpecifier object
%
% indmat             a vector of postive integers
%                    index for matnames
%
% OUTPUT ATGUMENTS
% logicind_channel   corresponding logical index of TFchan or names for channels in the specfifed matfiles 

%% Parse .... slow
% narginchk(2,2);
% p = inputParser;
% vfc = @(x) isa(x, 'ChanSpecifier');
% p.addRequired('chanSpec', vfc);
% 
% vfind = @(x) isnumeric(x) && all(x > 0) && all(fix(x) == x);
% p.addRequired('indmat', vfind);
% p.parse(chanSpec, indmat);

%% job

nums = chanSpec.ChanNum;
    
logicind_channel = false(sum(nums), 1);

for i = indmat
    
    if i == 1
        j = 1; % index for 'TFchan' and 'names'
    else
        j = sum(nums(1:(i-1))) + 1;
    end
    logicind_channel(j:(j +nums(i)-1)) = true;
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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