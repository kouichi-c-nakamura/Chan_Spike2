function recout = addchan(rec, newchans, newchantitles)
% Append Chan objects to a RecordA object rec.
% 
% recout = addchan(rec, newchans)
% recout = addchan(rec, newchans, newchantitles)
%
% INPUT ARGUMENTS
% rec         A RecordA object
%
% newchans    a Chan object | cell vector of Chan objects
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'newchantitles'
%             cell array of strings
%             In order to overwrite the 'title' of each new channels %TODO
%
% OUTPUT ARGUMENTS
% recout      A RecordA object including newchans
%
% See also
% Record
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 17-Nov-2016 10:52:56

arguments
    
    rec RecordA
    newchans {vf_newchans(newchans)}
    newchantitles string {vf_newchantitles(newchantitles)}= ""
     
end

% narginchk(2,3);


% p1 = inputParser;
isChan = @(x) isa(x, 'Chan');

% vf1 = @(x) ~isempty(x) && ...
%     ( isChan(x) && isscalar(x) ) || ...
%     ( iscell(x) && isvector(x) &&...
%     all(cellfun(isChan, x)) );
% 
% p1.addRequired('newchans', vf1);
% p1.parse(newchans);

if isChan(newchans) && isscalar(newchans)
    newchans = {newchans};
end

if iscolumn(newchans)
    newchans = newchans';
end


if nargin == 3
    
    %% parse newchantitles
%     p2 = inputParser;
%     vf2 = @(x) ~isempty(x) &&...
%         ( ischar(x) && isrow(x) ) ||...
%         ( iscellstr(x) && isrow(x) );
%     
%     addRequired(p2, 'newchantitles', vf2);
%     parse(p2, newchantitles);
    
    if ischar(newchantitles) && isrow(newchantitles)
        newchantitles = {newchantitles};
    elseif isstring(newchantitles)
        newchantitles = cellstr(newchantitles);
    end
    
    % uniqueness/confilcts check
    
    thisnames = rec.ChanTitles;%TODO
    if length(unique([newchantitles, thisnames])) ~= length([newchantitles, thisnames])
        error('K:Record:addchan:newchantitles:notunique',...
            'All elements of newchantitles must be unique and must not conflict with newchantitles of Chan objects.');
    end
    
else
     clear newchantitles
end


%% time identity check
list.ChanTitle = cell(size(newchans))';
% list.Start = NaN(size(newchans))';
% list.SRate = NaN(size(newchans))';
% list.Length = NaN(size(newchans))';
for i = 1:length(newchans)
    list.ChanTitle{i} = newchans{i}.ChanTitle;
%     list.Start(i) = newchans{i}.Start;
%     list.SRate(i) = newchans{i}.SRate;
%     list.Length(i) = newchans{i}.Length;
end

if ~isempty(rec.Chans)
    i = length(newchans); 
    j = length(rec.Chans);
    list.ChanTitle(i+1:i+j) = rec.ChanTitles;
%     list.Start(i+1) = rec.Start;
%     list.SRate(i+1) = rec.SRate;
%     list.Length(i+1) = rec.Length;
else % if 'rec.Chans' is empty
    %OK
end
    
% unique name check
assert(length(unique(list.ChanTitle)) == length(list.ChanTitle),...
    'K:Record:init:ChanTitle', ...
    'ChanTitle must be unique among objects.');


% time identity
% assert(all(list.Start(1) == list.Start) && ...
%     all(list.SRate(1) == list.SRate) && ...
%     all(list.Length(1) == list.Length),...
%     'K:Record:init:Time', ...
%     'Time is not identical between objects.');

% summary1 = struct2dataset(list); % requires Statistics TOOLBOX
% if ~isempty(rec.Chans)
%     
%     summary2 = mat2dataset([rec.Summary.ChanTitle, rec.Summary.Start, ...
%         rec.Summary.SRate, rec.Summary.Length],...
%         'VarName', {'ChanTitle', 'Start', 'SRate', 'Length'}); %TODO test ChanTitle
%     
%     summary = vertcat(summary1, summary2);
% else % if 'rec' is empty
%     summary = summary1;
% end



% % unique name check
% assert(length(unique(summary.ChanTitle)) == length(summary.ChanTitle),...
%     'K:Record:init:ChanTitle', ...
%     'ChanTitle must be unique among objects.');

% time identity
% assert(all(summary.Start(1) == summary.Start) && ...
%     all(summary.SRate(1) == summary.SRate) && ...
%     all(summary.Length(1) == summary.Length),...
%     'K:Record:init:Time', ...
%     'Time is not identical between objects.');


%% set newchantitles
if exist('newchantitles', 'var') && ~isempty(newchantitles)
    
    for i = 1:length(newchantitles)
        newchans{i}.ChanTitle = newchantitles{i};
    end
end

%% add Chan objects

recout = RecordA;
recout.RecordTitle = rec.RecordTitle;
recout.Chans = [rec.Chans; newchans'];

end


function vf_newchans(x)
isChan = @(x) isa(x, 'Chan');

assert(~isempty(x) && ...
    ( isChan(x) && isscalar(x) ) || ...
    ( iscell(x) && isvector(x) &&...
    all(cellfun(isChan, x)) ))

end


function vf_newchantitles(x)

assert(~isempty(x) &&...
        ( ischar(x) && isrow(x) ) ||...
        ( (iscellstr(x) || isstring(x)) && isrow(x) ))
end