function [uniqPairs, dupPairs] = getPairsPerRecord(chanSpec, varargin)
% getPairsPerRecord returns chanSpecifier objects for the lists of
% all the pairs of single units in .mat files in a specified folder.
%
% SYNTAXES
% [uniqPairs, dupPairs] = getPairsPerRecord(chanSpec)
%
% All the channels are to be processed.
%
%
% [uniqPairs, dupPairs] = getPairsPerRecord(chanSpec, expr_chantitle)
%
% This syntax allows you to narrow down the children of chanSpec only to
% the channels whose title match the regular expression expr_chantitle.
%
%   expr_chantitle     
%              Regular expression for channel title.
%
%              For single unit activity (events) with probe ('probeSUA')
%              expr_chantitle = '^probe[AB][01][0-9][eE]$'; % include large E
%
%              For single unit activity (events) with juxta ('juxtaSUA')
%              expr_chantitle = '^(unite|smalle)$';
%
%              For LFPs (waveform) with juxta ('probeLFP')
%              expr_chantitle = '^probe[AB][01][0-9][h]{0,1}$';
%
%
% [uniqPairs, dupPairs] = getPairsPerRecord(chanSpec, 'preset', type)
%
% This syntax allows you to use predefined regular expressions, as shown
% above.
%
%   type         'probeSUA', 'juxtaSUA', 'probeLFP'
%
%
% OUTPUT ARGUMENTS
% uniqPairs, dupPairs
%              N x 1 structure whose field names identifies animal and
%              recording site and whose fields hold ChanSpecifier objects
%              for the unique pairs of channels in the same file
%              (uniqPairs) and the duplicated pairs that are found in
%              multiple files for the same animal and recording site
%              (dupPairs). 
%
%              If no pair was found for an animal and recording
%              site, the corresponding field of uniqPairs or dupPairs is
%              excluded. Thus if no pair is in uniqPairs or dupPairs, then
%              uniqPairs or dupPairs is 1x0 (empty) structure with no field.
%              
%              uniqPairs.XXX.List(:).channels and dupPairs.XXX.List(:).channels
%              all have the length of two (pairs).
%
% Use this method when you want to carry out pair-wise analyses such as
% crosscorrelograms between channels that are recorded simultaneously.
% First, you should prepare chanSpec that is specific to a set of analyses,
% for example chanSpec for all the recordings from thalamic VPM nucleus.
% Then, use this method to get the pairs of channels that are unique in the
% dataset (uniqPairs), or that appear in multiple records (files) in the
% dataset (dupPairs). For pairs in dupPairs, 
%
%
% See also
% ChanSpecifider, validateMatFiles_test.validateEventChanUniqueness


%% Parse

narginchk(1,3);

p = inputParser;

switch nargin
    case 3
        
        vftype = @(x) ischar(x) && isrow(x) && ismember(lower(x), {'probesua','juxtasua','probelfp'});
        p.addParameter('preset', 'probesua', vftype);
        
        p.parse(varargin{:});
        preset = p.Results.preset;
        
        switch lower(preset)
            case 'probesua'
                expr_chantitle = '^probe[AB][01][0-9][eE]$'; % include large E
            case 'juxtasua'
                expr_chantitle = '^(unite|smalle)$';
            case 'probelfp'
                expr_chantitle = '^probe[AB][01][0-9][h]{0,1}$';
        end
        
    case 2
        
        vfexpr = @(x) ischar(x) && isrow(x);
        p.addRequired('expr_chantitle', vfexpr);
        
        p.parse(varargin{:});
        expr_chantitle = p.Results.expr_chantitle;
        
    case 1
        expr_chantitle = '.*'; % accept anything as it is
end


%TODO
    % matdir = '/Users/kouichi/Work/Spike2 folder/Kouichi MATLAB/thalamus/probe/SUA/act/mat';
    % chanSpec = ChanSpecifier(matdir);


%TODO
% ChanSpecifier_dir = fileparts(which('ChanSpecifier.m'));
% parts = strsplit(ChanSpecifier_dir, filesep);
% S = load(fullfile(strjoin(parts(1:end-1), filesep), 'getSUA_pairsInFile_Mat_demodata.mat'));
% chanSpec = ChanSpecifier;
% chanSpec.List = S.list;
% chanSpec.getPairsPerRecord;

%% Job

TFsua = chanSpec.ischantitlematched(expr_chantitle);
chanSpecE = chanSpec.choose(TFsua);
clear TFsua

[list, animal, animal_start, animal_end] = local_getanimals(chanSpecE);


%% go through animals
uniqPairs = struct;
uniqPairs(1) = [];
dupPairs = struct;
dupPairs(1) = [];

%TODO
% chanSpecE.List(9:end) = [];
% chanSpecE.List(9) = chanSpecE.List(7);
% chanSpecE.List(9).channels.probeA10e = chanSpecE.List(8).channels.probeA10e;
% chanSpecE.List(9).name = 'kjx127z03@0-100_madeup_m.mat';


for animal_ind = 1:length(animal)
    
    thisanimal = list(animal_start(animal_ind):animal_end(animal_ind));
    
    siteID_unique = unique({thisanimal(:).siteID}');

    
    %% gothrough siteID
    for site_ind = 1:length(siteID_unique)
        
        TFsite = chanSpecE.ismatnamematched(['^',animal{animal_ind}, siteID_unique{site_ind}]);
        thisSite = chanSpecE.choose(TFsite);
        
        chantitlesThisSite = thisSite.ChanTitles;
        
        uniquePairs_thisSite = ChanSpecifier;
        dupPairs_thisSite = ChanSpecifier;
        
        for rec_ind = 1:length(chantitlesThisSite)
            
            chantitles = chantitlesThisSite{rec_ind};
            
            C = combnk(1:length(chantitles),2);
            
            for k = 1:size(C, 1)
                expr_pairs = [chantitles{C(k,1)},'|', chantitles{C(k,2)}];
                uniqPairTitles = uniquePairs_thisSite.ChanTitles;
                
                TFchan = thisSite.ischantitlematched(expr_pairs);
                TFmat = thisSite.ismatvalid(rec_ind);
                thispair = thisSite.choose(TFmat & TFchan);
                
                if uniquePairs_thisSite.MatNum == 0
                    uniquePairs_thisSite = [uniquePairs_thisSite; ...
                        thispair];
                    
                else
                    isdup = false;
                    
                    for n = 1:uniquePairs_thisSite.MatNum
                        
                        if ismember(chantitles{C(k, 1)}, uniqPairTitles{n}) ...
                                && ismember(chantitles{C(k, 2)}, uniqPairTitles{n})
                            % not unique
                            
                            dupPairs_thisSite.List(end + 1) = uniquePairs_thisSite.List(n); % append                            
                            
                            uniquePairs_thisSite.List(n) = []; % delete from the list

                            dupPairs_thisSite = [dupPairs_thisSite; ...
                                thispair];

                            isdup = true;
                            break;
                        end
                    end
                    
                    % so far unique
                    if ~isdup
                        uniquePairs_thisSite = [uniquePairs_thisSite; ...
                            thispair];
                        
                    end
                    
                end % if
            end % for k
            
            animalsite = [animal{animal_ind}, siteID_unique{site_ind}];
            
            if sum(uniquePairs_thisSite.ChanNum) > 0
                uniqPairs(1).(animalsite) = uniquePairs_thisSite;
            end
            
            if sum(dupPairs_thisSite.ChanNum) > 0
                dupPairs(1).(animalsite) = dupPairs_thisSite;
            end
        end % for rec_-ind
        
    end
    
end



end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [list, animal, animal_start, animal_end] = local_getanimals(chanSpec)
list = chanSpec.getstructNby1('title');
if isempty(list)
    
    animal = [];
    animal_start = [];
    animal_end = [];
    return
end

try
    siteID = cellfun(@(x) x{1}, regexp({list(:).record}', '^[a-zA-Z]{1,2}', 'match'), 'UniformOutput', false);
catch ME1
    if strcmp(ME1.identifier, 'MATLAB:nonExistentField')
     error('K:ChanSpecifider:getPairsPerRecord:local_getanimals:norecord',...
         'It appears that the mat files do not contain "record" field.')   
    else
        throw(ME1);
    end
end 

[list(:).siteID] = siteID{:};

animal_all = {list(:).animal}';

[animal , animal_start ]= unique(animal_all); % must be always in order (by dir)

if length(animal_start) > 1
    animal_end = [animal_start(2:end) - 1; length(animal_all)];
else
    animal_end = length(animal_all);
end

end



% Compare the animal names across brain state
% then compare the record letters '[a-zA-Z]' across brain state
% Go through the files for the same record letter '[a-zA-Z]' and create the list of SUA event channels.
% Output should be act and swa, both of which are ChanSpecifier objects with the same number of mat files and channels, i.e. paired.