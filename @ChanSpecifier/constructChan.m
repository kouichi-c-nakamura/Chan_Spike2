function [chan, TF, names] = constructChan(chanSpec, varargin)
% The method constructChan construct Chan objects out of specififed .mat files listed in chanSpec.
%
% chan = constructChan(chanSpec)
% chan = constructChan(chanSpec, matindex)
% chan = constructChan(chanSpec, matindex, chanindex)
% chan = constructChan(chanSpec, matnamesfull)
% chan = constructChan(chanSpec, matnamesfull, chantitles)
% [chan, TF, names] = constructChan(chanSpec, 'gui')
%
%
% INPUT ARGUMENTS
%
% The syntax constructChan(chanSpec) is equivalent to constructChan(chanSpec, 1:chanSpec.MatNum)
%
% matindex  A vector of positive integers that specify .mat files in chanSpec.List in order
%
% chanindex A vector of positive integers that specify channels in a *.mat 
%           file when matindex is scalar or matnamesfull contains just one
%           name.
%           Otherwise, a cell column vector contains vectors of postive
%           integers. In this case, the length of the chanindex must be
%           equal to the length of matindex.
% 
% matnamesfull
%           Cell vector of .mat file names. File names must be absolute
%           paths (full path), but they don't have to be unique.
%
% chantitles
%           A cell vector of chantitles. when matindex is scalar or matnamesfull
%           contains just one name.
%           Otherwise, a cell vector containing cell vectors of chantitles.
%
% 'gui'     This option shows a file/channel chooser dialog for interactive
%           choice. You can choose specific files and chan with
%           ChanSpeficier.ischanvalid method and
%           ChanSpeficier.choose method alternatively.
%
%
% OUTPUT ARGUMENTS
% chan      a Chan object when output is only one object, or cell vector of Chan 
%           objects. For example, if chanindex specifies 5 channels across
%           multiple .mat files, then chan is a 5x1 cell array each of which 
%           contains a Chan object.
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
% EXAMPLES
% chan = constructChan(chanSpec, 3, 1)
% chan = constructChan(chanSpec, 3, 1:3)
% chan = constructChan(chanSpec, 1:3, {1:3, 2, [2,4]})
%
% chan = constructChan(chanSpec, 3, 'IpsiEEG')
% chan = constructChan(chanSpec, 3, {'IpsiEEG','unite'})
%
% chan = constructChan(chanSpec, chanSpec.MatNamesFull([1,3,5]), ...
%    {{'IpsiEEG','unite'},{'IpsiEEG, 'onset'}, {'onset'});
%
% chan = constructChan(chanSpec, fullfile(thisdir, 'kjx127a01@0-20_single.mat'), {'IpsiEEG','unite'})
%
% See Also
% ChanSpecifier.constructFileList, ChanSpecifier.constructRecord. Chan.constructChan

%% Parse
narginchk(1,3);

vfmati = @(x) isvector(x) && ...
    (   isnumeric(x) && all(x > 0) && all(fix(x) == x)  )...
    || ( iscellstr(x) && ismatchedany(x, '\.mat$')) ...
    || (ischar(x) && isrow(x) && strcmpi(x, 'gui') );

switch nargin
    case 1
        matindex = 1:chanSpec.MatNum;
        
        chanindex = defalut_chanindex(chanSpec);
        
    case 2
        p = inputParser;
        
        p.addRequired('matindex', vfmati);
        p.parse(varargin{1});

        matindex = p.Results.matindex;

        chanindex = defalut_chanindex(chanSpec);
    
    case 3
        
        vfchani = @(x) isvector(x) && ...
            (   isnumeric(x) && all(x > 0) && all(fix(x) == x) )...
            || iscell(x) || ischar(x) && isrow(x); 

        p = inputParser;
        
        p.addRequired('matindex', vfmati);
        p.addRequired('chanindex', vfchani);

        p.parse(varargin{:});
        
        matindex = p.Results.matindex;
        chanindex = p.Results.chanindex;
        

end

%% Job

matindex = local_getindex(chanSpec, matindex);
chanindex = local_getchanindex(chanSpec, matindex, chanindex);


chantypeall = chanSpec.getchanprop('chantype');


TFwave  = chanSpec.ischanvalid('chantype',@(x) strcmpi(x,'waveform'));
TFevent = chanSpec.ischanvalid('chantype',@(x) strcmpi(x,'event'));



if ischar(matindex) % gui
    str = chanSpec.ChanTitlesMatNamesAll;
    str = cellfun(@(x,y) horzcat(x, '|', y), str(:,2), str(:,4), 'UniformOutput', false);
    
    [selection, OK ] = listdlg('PromptString','Select files/channels:',...
        'SelectionMode','multiple',...
        'ListString', str, 'ListSize', [300, 300], 'InitialValue', 1:length(str));
    
    if OK == 0
        return
    end
    
    [matnamesfull, matindex] = local_selection2namesindex(chanSpec, selection);
    
else
    matnamesfull = chanSpec.MatNamesFull(matindex); 

end


C = cell(length(matindex) , 1);
for i = 1:length(matindex) 
    m = matindex(i);
    
    C{i} = cell(length(chanindex{1}) , 1);

    chantitleschosen = fieldnames(chanSpec.List(m).channels);
    try
        S = load(matnamesfull{i}, chantitleschosen{chanindex{i}});
    
    catch mexc1
        if strcmp(mexc1.identifier, 'MATLAB:load:couldNotReadFile')
           warning(['If you have loaded ChanSpecifier object from a saved file, ',...
               'then double check if you have also deployed changepathplatform() properly.\n'],...
               matnamesfull{i});
        end
                   
        throw(mexc1);
       
    end
        
    
    if any(strcmpi(...
            chantypeall(arrayfun(@(x)chanSpec.matindchanind2allind(m,x),chanindex{i})),...
            'marker'))
        
        TFmat = chanSpec.matind2tf(m);
        allind_ref = find(TFmat & (TFwave | TFevent), 1,'first');
        
        if isempty(allind_ref)
            warning('Could not find reference channel (wavefiorm or event) for marker channel')
            S2 = [];
            refchantitle = '';
        else
            [~,chanind_ref] = chanSpec.allind2matindchanind(allind_ref);
            
            refchantitle = chanSpec.ChanTitles{m}{chanind_ref};
            S2 = load(matnamesfull{i}, refchantitle);
        end
    end
    
    
    for j = 1:length(chanindex{i})
               
        if strcmpi(chantypeall(chanSpec.matindchanind2tf(m,chanindex{i}(j))),'marker')
            
            C{i}{j, 1} = Chan.constructChan(S.(chantitleschosen{chanindex{i}(j)}),...
                'ref', S2.(refchantitle));            
            
        else 
            C{i}{j, 1} = Chan.constructChan(S.(chantitleschosen{chanindex{i}(j)}));
        end
    end
        
end

chan = vertcat(C{:});

if isscalar(chan)
    chan = chan{1};
end

%% get TF and names
TF = false(sum(chanSpec.ChanNum), 1);
channum = chanSpec.ChanNum;

for i = 1:length(matindex)
    m = matindex(i);
    
    startN = sum(channum(1:(m - 1))) + 1;

    endN = startN +  channum (m) - 1;
  
    thismat = startN:endN;
    
    ind = thismat(chanindex{i});
    
    TF(ind) = true(size(ind));

end

if nargout <= 2
    [~, TF] = chanSpec.choose(TF);
elseif nargout > 2
    [~, TF, names] = chanSpec.choose(TF);
end
    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function matindex = local_getindex(chanSpec, matindex)

if isnumeric(matindex)
    % chan = constructChan(chanSpec, matindex)

    assert(all(matindex <= chanSpec.MatNum),...
        eid('matindex:numeric:exceed'),...
        'Value(s) %s in matindex exceeds the length %d of %s.List(%d).channels', ...
        regexprep(num2str(matindex(matindex > chanSpec.MatNum), '%d, '), ',$', ''), ...
        chanSpec.MatNum, inputname(1),...
        matindex(matindex > chanSpec.MatNum));
    
    
elseif iscellstr(matindex)
    % chan = constructChan(chanSpec, matnamesfull)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function chanindex = local_getchanindex(chanSpec, matindex, chanindex)
% chanindex = local_getchanindex(chanSpec, matindex, chanindex)
%
% INPUT ARGUMENTS
% chanSpec    A ChanSpecifier object
%
% matindex    A vector of positive integers that specify .mat files in 
%             chanSpec.List in order
%
% chanindex   A vector of positive integers that specify channels in a *.mat 
%             file when matindex is scalar or matnamesfull contains just
%             one name. Otherwise, a cell column vector contains vectors of
%             postive integers. In this case, the length of the chanindex
%             must be equal to the length of matindex.
%
% OUTPUT ARGUMENTS
% chanindex   ?
%
%



if isnumeric(chanindex)
    % chan = constructChan(chanSpec, 2, 3:5)

    assert(isscalar(matindex), eid('chanindex:numeric:invalid'),...
        'When chanindex is numeric, matindex must be scalar');
    
    assert(all(chanindex <= chanSpec.ChanNum(matindex)),...
        eid('chanindex:numeric:exceed'),...
        'Value(s) %s in chanindex exceeds the number of channels %d in %s.List(%d).channels', ...
        regexprep(num2str(chanindex(chanindex > chanSpec.ChanNum(matindex)), '%d, '), ',$', ''), ...
        chanSpec.ChanNum(matindex), inputname(1),...
        matindex);
    
    chanindex = {chanindex};
    
elseif iscell(chanindex) && ~iscellstr(chanindex)
    % chan = constructChan(chanSpec, [2,4], {[1:3],[2,5]})
    % the typical syntax
    
    assert(length(matindex) == length(chanindex), ...
        eid('chanindex:cell:mismatch'),...
        'When chanindex is cell, matindex (%d) and chanindex (%d) must have the same size.',...
        length(matindex), length(chanindex));   
    
    if all(cellfun(@(x) isnumeric(x), chanindex))
        
        for i = 1:length(matindex)
            m = matindex(i);
        
            assert(all(all(chanSpec.ChanNum(m) >= chanindex{i})),...
                eid('chanindex:cell:exceed'),...
                'When chanindex is cell, chanindex value must not exceed corresponding ChanNum.');
        
        end
        
    elseif all(cellfun(@(x) iscellstr(x), chanindex))
        % chan = constructChan(chanSpec, 3:4, {{'IpsiEEG','unite'},{'onset'}})

        for j = 1:length(matindex)
            for i = 1:length(chanindex)
                
                assert(any(ismember(chanindex{i}, chanSpec.ChanTitles{matindex(j)})), ...
                    eid('chanindex:cellstr:mismatch'),...
                    'Value of chanindex %s must be valid ChanTitle of the corresponding mat file that is specified by matindex %d',...
                    chanindex{i}, matindex(j));
                
            end
        end
                
        chanindex = chanSpec.chantitles2chanind(matindex, chanindex);

    end
elseif iscellstr(chanindex) || ischar(chanindex)
    % chan = constructChan(chanSpec, 3, {'IpsiEEG','unite'})
    % chan = constructChan(chanSpec, 3, 'IpsiEEG')
    
    if ischar(chanindex)
        chanindex = {chanindex};
    end
    
    assert(isscalar(matindex), ...
        eid('chanindex:cellstr:notscalar'),...
        'When chanindex is cellstr, matindex must be scalar.');
    
    matnamesfull = chanSpec.MatNamesFull;
    
    for j = 1:length(matindex)
        for i = 1:length(chanindex)
            
            assert(any(ismember(chanindex{i}, chanSpec.ChanTitles{matindex(j)})), ...
                eid('chanindex:cellstr:mismatch'),...
                'Value of chanindex "%s" must be valid ChanTitle of the corresponding mat file "%s"',...
                chanindex{i}, matnamesfull{matindex(j)});

        end
    end
        
    chanindex = chanSpec.chantitles2chanind(matindex, chanindex);
        
else
    error(eid('chanindex:invalid'),...
        'Value of %s is invalid for the syntax', ...
        inputname(3));
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function chanindex = defalut_chanindex(chanSpec)

chanindex = cell(chanSpec.MatNum, 1);

% chanindex(:,1) = {(1:chanSpec.MatNum)'};
% chanindex = cellfun(@(i) (1:chanSpec.ChanNum(i))', chanindex, 'UniformOutput', false);

for i = 1:chanSpec.MatNum
    
    chanindex{i} = [1:chanSpec.ChanNum(i)]';
    
end


end