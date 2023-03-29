function [rec, TF, names] = constructRecord(chanSpec, matindex)
% The method constructRecord construct Record objects out of specififed .mat files listed in chanSpec.
%
% rec = constructRecord(chanSpec)
% rec = constructRecord(chanSpec, matindex)
% rec = constructRecord(chanSpec, matnamesfull)
% [rec, TF, names] = constructRecord(chanSpec, 'gui')
%
%
% INPUT ARGUMENTS
%
% The syntax constructRecord(chanSpec) is equivalent to constructRecord(chanSpec, 1:chanSpec.MatNum)
%
% matindex  A vector of positive integers that specify .mat files in chanSpec.List in order
%
% matnamesfull
%           Cell vector of .mat file names. File names must be absolute
%           paths (full path), but they don't have to be unique.
%
% 'gui'     This option shows a file/channel chooser dialog for interactive
%           choice. You can choose specific files and rec with
%           ChanSpeficier.ischanvalid method and
%           ChanSpeficier.choose method alternatively.
%
%
% OUTPUT ARGUMENTS
% rec       Cell vector of Record objects or a Record object when output is 
%           only one object. If matindex or matnamesfull specifies 5 .mat
%           files, then rec is a 5x1 cell array each of which contains
%           a Record object for each .mat file.
%
% TF        vertical vector of logical
%           a logical for a .mat file is followed by logical values for
%           channels included in that .mat file. %TODO change TF
%           specification TF should only represent channels but not mat
%           files!!! ismatvalid can be a wrapper of this function
%
% names     In order to tell which value is which, this cell array
%           column of strings has the same size as TF. It contains name
%           of each .mat files and title of each channel that
%           corresponds to the TF
%
% See Also
% ChanSpecifier.constructFileList



%% Parse
narginchk(1,2);

if nargin == 1
    matindex = 1:chanSpec.MatNum;
else
    p = inputParser;
    vf = @(x) isvector(x) && ...
        (   isnumeric(x) && all(x > 0) && all(fix(x) == x)  )...
        || ( iscellstr(x) && ismatchedany(x, '\.mat$')) ...
        || (ischar(x) && isrow(x) && strcmpi(x, 'gui') );
    
    p.addRequired('matindex', vf);
    p.parse(matindex);
end

%% Job

matindex = local_getindex(chanSpec, matindex);


if ischar(matindex)
    str = chanSpec.ChanTitlesMatNamesAll;
    str = cellfun(@(x,y) horzcat(x, '   /   ', y), str(:,2), str(:,4), 'UniformOutput', false);
    
    
    [selection, OK ] = listdlg('PromptString','Select files/channels:',...
        'SelectionMode','multiple',...
        'ListString', str, 'ListSize', [300, 300], 'InitialValue', 1:length(str));
    
    if OK == 0
        return
    end
    
    [matnamesfull, matindex] = local_selection2namesindex(chanSpec, selection);
    
else
    matnamesfull = chanSpec.MatNamesFull(matindex); %TODO

end


rec = cell(length(matindex) , 1);
for i = 1:length(matindex) 
    
    thisrec = Record;
    thisrec.RecordTitle = chanSpec.MatNames{matindex(i)};
    
    chantitleschosen = fieldnames(chanSpec.List(matindex(i)).channels);
    S = load(matnamesfull{i}, chantitleschosen{:});
    
    for j = 1:length(chantitleschosen)
        
        chan = Chan.constructChan(S.(chantitleschosen{j}));
        %TODO does not support marker chan
        % see ChanSpecifier.constructChan for more detail
        
        thisrec = thisrec.addchan(chan);
    
    end
    
    rec{i} = thisrec;
    
end

if isscalar(rec)
    rec = rec{1};
end

[TF, names] = chanSpec.ismatvalid(matindex);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function matindex = local_getindex(chanSpec, matindex)

if isnumeric(matindex)
    % rec = constructRecord(chanSpec, matindex)

    assert(all(matindex <= chanSpec.MatNum),...
        eid('matindex:numeric:exceed'),...
        'Value(s) %s in matindex exceeds the length %d of %s.List', ...
        regexprep(num2str(matindex(matindex > chanSpec.MatNum), '%d, '), ',$', ''), ...
        chanSpec.MatNum, inputname(1));
    
    
elseif iscellstr(matindex)
    % rec = constructRecord(chanSpec, matnamesfull)

    [dirpath, ~, ext] = cellfun(@fileparts , matindex, 'UniformOutput', false);
    
    for i = 1:length(matindex)
        
        assert(~isempty(dirpath{i}), eid('matnamesfull:notfullpath'),...
            'Value of matnamesfull must be full path.');
        assert(~isempty(ext{i}), eid('matnamesfull:notfullpath2'),...
            'Value of matnamesfull must be full path, but lacking extention');
        
        assert(any(ismember(matindex{i}, chanSpec.MatNamesFull)), ...
            eid('matnamesfull:notincluded'),...
            'Value of matnamesfull must be full path of mat files that are included in %s',...
            inputname(1));
    end
    
    if iscell(matindex)
        matindexcell = chanSpec.matnamesfull2matind(matindex); % cell output
        
        matindex = vertcat(matindexcell{:});
        
    else
        matindex = chanSpec.matnamesfull2matind(matindex); % cell output

    end
    
    
elseif ischar(matindex) && strcmpi(matindex, 'gui')
    % no change
    
else
    error(eid('matindex:invalid'),...
        'Value of %s is invalid for the syntax', ...
        inputname(2));
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [matnamesfull, matindex] = local_selection2namesindex(chanSpec, selection)

TF = false(sum(chanSpec.ChanNum), 1);
TF(selection) = true;


n = chanSpec.MatNum;
nums = chanSpec.ChanNum;

indtf_mat = false(1, n); % horizontal for "for" loop
% indtf_channel = cell(n, 1);

for i = 1:n
    
    if nums(i) == 0
        %TODO should it accept empty mat file?
        warning(eid('local_TF2matchannellogicindices:nochannel'),...
            'The case in which no channel is included for a .mat file has not yet implemented.')
    else
        if i == 1
            buffer = TF(1: nums(1))'; % horizontal for "for" loop
        else
            k = sum(nums(1:(i-1)));
            buffer = TF(k + 1: k + nums(i) )';% horizontal for "for" loop
        end
        
        if any(buffer)
            
            indtf_mat(i) = true;
            
        end
    end
    
%     indtf_channel{i} = buffer;
end

matindex = find(indtf_mat);

matnamesfull = chanSpec.MatNamesFull(indtf_mat);

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

eid = ['K:ChanSpecifider:', m, str];


end