function [varargout] = choose(chanSpec, TF)
% [chanSpecout, TF, names] = choose(chanSpec, TF)
% [chanSpecout, TF, names] = choose(chanSpec, TFmat)
% [chanSpecout, TF, names] = choose(chanSpec, 'gui')
%
% INPUT ARGUMETS
% chanSpec      ChanSpec object containing non-scalar structure chanSpec.List.
%
%
% TF            A column vector of logical whose length equals the sum of
%               the number of the all the channels included in those .mat
%               files. This is output of .ismatvalid, ischanvalid etc.
%
% TFmat         A column vector of logical whose length equals the sum of
%               the number of mat files. This is the third output of ismatvalid
%               method.
%
% 'gui'         This option shows a file/channel chooser dialog for
%               interactive choice.
%
% OUTPUT ARGUMENTS
% chanSpecout   ChanSpec onject containing a subset of files and channels 
%               that are specified by true values in TF logical vector.
%
% TF            A column vector of logical whose length equals the sum of
%               the number of mat files and the all the channels included
%               in those .mat files
%
% names         In order to tell which value is which, this cell array
%               column of strings has the same size as TF. It contains name
%               of each .mat files and title of each channel that
%               corresponds to the TF
%
% Examples
% [chanSpecout, TF, names] = chanSpec.choose(TF)
% [chanSpecout, TF, names] = chanSpec.choose('GUI')
%
% See also 
% ChanSpecifier.ismatvalid, ChanSpecifier.ischanvalid,
% ChanSpecifier.ismatnamematched, ChanSpecifier.ischantitlematched, 
% ismatchedany
%
% 30 Jan 2015
% Written by Dr Kouichi C. Nakamura
% kouichi.c.nakamura@gmail.com
%
%



%% parse

narginchk(2,2);

if isempty(chanSpec.List)
    varargout{1} = ChanSpecifier();
    varargout{2} = true(0, 1);
    varargout{3} = cell(0,1);
    return
end


p = inputParser;
vftf = @(x) ~isempty(x) && (iscolumn(x) && islogical(x)) || ...
    ischar(x) && isrow(x) && strcmpi(x, 'gui');
p.addRequired('TF', vftf);

p.parse(TF); %TODO handle if the folder is empty



if ischar(TF)
    
    TF = ischanvalid(chanSpec, 'gui');
    
end



%% job

if isrow(chanSpec)
   chanSpec = chanSpec'; 
end


nums = chanSpec.ChanNum;

if length(TF) == chanSpec.MatNum
    TFmat = TF;
    
    TF = chanSpec.ismatvalid(find(TFmat)); %#ok<FNDSB>
    
end


if length(TF) == sum(nums)
    
    %% convert TF vector to chanSpecout
    
    [indtf_mat, indtf_channel] = local_TF2matchannellogicindices(chanSpec, TF);
    
    finames = fieldnames(chanSpec.List);
    L =length(finames);
    fiandval = cell(1,L*2);
    fiandval(1:2:L*2) = finames;
    fiandval(2:2:L*2) = repmat({{}}, 1, L);
    
    Sout = struct(fiandval{:});
    
    k = 1;
    for i = find(indtf_mat) % must be horizontal vector
        thismat = chanSpec.List(i);
        chantitles = fieldnames(thismat.channels);
        
        Sout(k, 1) = thismat;
        
        clear truechannels % Required
        for j = find(indtf_channel{i}) % must be horizontal vector
            truechannels.(chantitles{j}) = thismat.channels.(chantitles{j});
        end % for j
        Sout(k, 1).channels = truechannels;
        
        k = k + 1;
    end
    
    chanSpecout = ChanSpecifier();
    
    chanSpecout.List = Sout;
    
else

    error(eid('TF:lengthmismatch'),...
    'The length of TF vector %d is invalid (must be %d or %d).',...
    length(TF), sum(nums), chanSpec.MatNum);
    
end
varargout{1} = chanSpecout;
varargout{2} = TF;


%% Names

if nargout > 2
    names = chanSpec.ChanTitlesMatNamesAll;
    
    names = strcat(names(:, 2), repmat({'|'}, size(names, 1), 1), names(:,4)); %strcat is slow
    varargout{3} = names;
    
    % faster than
    % names = cellfun(@(x,y) horzcat(x, '|', y), names(:,2), names(:,4), 'UniformOutput', false);
end

end

%--------------------------------------------------------------------------
function [indtf_mat, indtf_channel] = local_TF2matchannellogicindices(chanSpec, TF)
% [indtf_mat, indtf_channel] = local_TF2matchannellogicindices(chanSpec, indmat)
% Convert TF for 'chanSpec' into logical index for mat files and channels within
%
% INPUT ARGUMENTS
% indmat          a vector of postive integers
%                 index for matnames
%
%
% OUTPUT ATGUMENTS
% indtf_mat           Row vector of logical index of  TF or index for the 
%                     specfifed matfiles where size(indtf_mat) equals to 
%                     [1, chanSpec.MatNum] 
%
% indtf_channel       Column vector of cell array containing row vector of 
%                     logical index of channels in the specfifed matfiles
%                     for TF or index matfiles where size(indtf_channel)
%                     equals to [chanSpec.MatNum, 1] and within each cell there
%                     is a row vector of logicals and 
%                     size(indtf_channel{k}) == [1, (number of channels)]

%% Parse
narginchk(2,2);
p = inputParser;
vfc = @(x) isa(x, 'ChanSpecifier');
p.addRequired('chanSpec', vfc);

vtf = @(x) islogical(x) && iscolumn(x);
p.addRequired('TF', vtf);
p.parse(chanSpec, TF);

%% job
n = chanSpec.MatNum;
nums = chanSpec.ChanNum;

indtf_mat = false(1, n); % horizontal for "for" loop
indtf_channel = cell(n, 1);

for i = 1:n
    
    if nums(i) == 0
        %TODO should it accept empty mat file?
        warning(eid('local_TF2matchannellogicindices:nochannel',...
            'The case in which no channel is included for a .mat file has not yet implemented.'))
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
    
    indtf_channel{i} = buffer;
end


end
%--------------------------------------------------------------------------
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