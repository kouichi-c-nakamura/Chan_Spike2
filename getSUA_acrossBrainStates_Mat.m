function [act, swa] = getSUA_acrossBrainStates_Mat(actdir, swadir, varargin)
% getSUA_acrossBrainStates_Mat returns chanSpecifier objects for the lists of
% .mat files whose single units are paired across two brain states.
%

%% Parse

narginchk(2,3);

p = inputParser;

vfdir = @(x) ischar(x) && isrow(x) && isdir(x);
p.addRequired('actdir', vfdir);
p.addRequired('swadir', vfdir);

vftype = @(x) ischar(x) && isrow(x) && ismember(x, {'probe','juxta'});
p.addOptional('type', 'probe', vftype);

p.parse(actdir, swadir, varargin{:});

type = p.Results.type;


%% Job


% 
% type = 'probe'
% 
% actdir = '/Users/kouichi/Work/Spike2 folder/Kouichi MATLAB/thalamus/probe/SUA/act/mat';
% swadir = '/Users/kouichi/Work/Spike2 folder/Kouichi MATLAB/thalamus/probe/SUA/swa/mat';

switch lower(type)
    case 'probe'
        expr_SUA = 'probe[AB][01][0-9][eE]'; % regular expression for SUA channels
    case 'juxta'
        expr_SUA = 'unite|smalle'; % regular expression for SUA channels
end

chanSpecAct = ChanSpecifier(actdir);
chanSpecSwa = ChanSpecifier(swadir);
TFact = chanSpecAct.ischantitlematched(expr_SUA);
TFswa = chanSpecSwa.ischantitlematched(expr_SUA);

chanSpecActE = chanSpecAct.choose(TFact);
chanSpecSwaE = chanSpecSwa.choose(TFswa);

getAnimals = @(X) cellfun(@(x) x{1}, regexp(X, '^[a-zA-Z_]{3}\d{1,3}', 'match'),...
    'UniformOutput', false);

animalNamesAct = getAnimals(chanSpecActE.MatNames);
animalNamesSwa = getAnimals(chanSpecSwaE.MatNames);

getRecords = @(X)  cellfun(@(x) x{1}, regexp(X, '^[a-zA-Z_]{3}\d{1,3}([a-zA-Z]{1,2})\d{1,2}', ...
    'tokens', 'once'), 'UniformOutput', false);

recordLettersAct = getRecords(chanSpecActE.MatNames);
recordLettersSwa = getRecords(chanSpecSwaE.MatNames);


%% %%%%

[list.act, animal.act, animal_ind.act, animal_N.act] = local_getanimals(chanSpecActE);
[list.swa, animal.swa, animal_ind.swa, animal_N.swa] = local_getanimals(chanSpecSwaE);


act = ChanSpecifier;
swa = ChanSpecifier;


for i = 1:length(animal.act)
    thisanimal.act = list.act(animal_ind.act(i):animal_N.act(i)); %TODO
    
    for j = 1:length(animal.swa)
        if strcmp(animal.act{i}, animal.swa{j}) % same animal
            thisanimal.swa = list.swa(animal_ind.swa(j):animal_N.swa(j));
            
            [siteID_thisanimal.act, siteID_unique.act, siteID_ind.act, siteID_N.act] ...
                = local_getrecordIDs(thisanimal.act);
            [siteID_thisanimal.swa, siteID_unique.swa, siteID_ind.swa, siteID_N.swa] ...
                = local_getrecordIDs(thisanimal.swa);
            
            uniquechan.act = local_validateifchanunique(siteID_unique.act,...
                siteID_ind.act, siteID_N.act, thisanimal.act);
            uniquechan.swa = local_validateifchanunique(siteID_unique.swa, ...
                siteID_ind.swa, siteID_N.swa, thisanimal.swa);
            
            for k = 1:length(siteID_unique.act)
                for l = 1:length(siteID_unique.swa)
                   if strcmp(siteID_unique.act{k}, siteID_unique.swa{l})
                       pairedChan = intersect( uniquechan.act{k},  uniquechan.swa{l});
                       
                       if ~isempty(pairedChan)
                           %TODO what happens is channel is not unique?
                           
                           act = local_intersect2chanSpec(chanSpecActE, act, animal.act{i}, siteID_unique.act{l}, pairedChan);
                           
                           swa = local_intersect2chanSpec(chanSpecSwaE, swa, animal.swa{i}, siteID_unique.swa{l}, pairedChan);
                       end
                       
                   end
                end
            end            
        end
    end
    
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [list, animal, animal_ind, animal_N] = local_getanimals(chanSpec)
list = chanSpec.getstructNby1('title');
if isempty(list)
    return
end

siteID = cellfun(@(x) x{1}, regexp({list(:).record}', '^[a-zA-Z]{1,2}', 'match'), 'UniformOutput', false);

[list(:).siteID] = siteID{:};

animal_all = {list(:).animal}';

[animal , animal_ind ]= unique(animal_all); % must be always in order (by dir)

if length(animal_ind) > 1
    animal_N = [animal_ind(2:end) - 1; length(animal_all)];
else
    animal_N = length(animal_all);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [siteID_thisanimal, siteID_unique, siteID_ind, siteID_N] = local_getrecordIDs(thisanimal)
siteID_thisanimal = {thisanimal(:).siteID}';
[siteID_unique, siteID_ind ]= unique(siteID_thisanimal); % must be always in order (by dir)

if length(thisanimal) > 1
    siteID_N = [siteID_ind(2:end) - 1; length(siteID_thisanimal)];
else
    siteID_N = length(siteID_thisanimal);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function uniquechan = local_validateifchanunique(siteID_unique, siteID_ind, siteID_N, thisanimal)

warning off backtrace


uniquechan = cell(length(siteID_unique), 1);

for i = 1:length(siteID_unique)
    
    uniquechan_this = {};
    
    for j = siteID_ind(i):siteID_N(i)
        
        if ismember(thisanimal(j).title, uniquechan_this)
            warning('getSUA_acrossBrainStates_Mat:local_validateifchanunique:notunique',...
                '%s (chan %d) in %s is not unique single unit (event) among %s%s\n', ...
                thisanimal(j).title, thisanimal(j).channumber, thisanimal(j).parent,...
                thisanimal(j).animal, thisanimal(j).siteID);
        end
        
        if ~ismember(thisanimal(j).title, uniquechan_this)
            uniquechan_this = [uniquechan_this; ...
                thisanimal(j).title];
        end
        
    end
    
    uniquechan{i} = uniquechan_this;
    
end

warning on backtrace



end


function chanSpecOut = local_intersect2chanSpec(chanSpecIn, chanSpecOut, animalname, siteID, pairedChan)
% 
% TFmat.swa = chanSpecSwaE.ismatfilenamematched(['^',animal.swa{i}, siteID_unique.swa{l}]);
% TFchan.swa = chanSpecSwaE.ischantitlematched(pairedChan);
% swa = [swa; chanSpecSwaE.choose(TFmat.swa  & TFchan.swa)];

TFmat = chanSpecIn.ismatfilenamematched(['^',animalname, siteID]);
TFchan = chanSpecIn.ischantitlematched(pairedChan);
chanSpecOut = [chanSpecOut; chanSpecIn.choose(TFmat  & TFchan)];

end


% Compare the animal names across brain state
% then compare the record letters '[a-zA-Z]' across brain state
% Go through the files for the same record letter '[a-zA-Z]' and create the list of SUA event channels.
% Output should be act and swa, both of which are ChanSpecifier objects with the same number of mat files and channels, i.e. paired.