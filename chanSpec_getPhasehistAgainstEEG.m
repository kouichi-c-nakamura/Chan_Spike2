function result = chanSpec_getPhasehistAgainstEEG(chanSpec, outname, freqpreset, varargin)
% result = chanSpec_getPhasehistAgainstEEG(chanSpec, outname, freqpreset, varargin)
%
% INPUT ARGUMENTS
% chanSpec       a ChanSpecifier obbject.
%                A .mat file or A Record object that is listed in a
%                ChanSpecifier object must contain ONLY one Waveform data
%                and AT LEAST one event/marker data.
%
% outname        a string (char type) for the output file to be
%                saved in "results" folder underneath the
%                chanSpec.ParentDir if they are common. In canse they are
%                not common, you need to specify the destdir.
%
% freqpreset     Preset frequency range for phase histogram generation.
%                Must be either 'slow', 'spindles', 'beta', 'gamma'
%
% destdir        (Optional) The folder path at which the output file is to be saved.
%
% OUTPUT ARGUMENTS
% result         table containing stats of recordings
%
% See also
% ChanSpecifier, Record, EventChan, K_PhaseHist
%
% TODO This could be a method of ChanSpecifier!

%% Parse
narginchk(2,3);

p = inputParser;
vfc = @(x) isa(x, 'ChanSpecifier') && isscalar(x);
p.addRequired('chanSpec', vfc);

vfo = @(x) ischar(x) && isrow(x) && ismatchedany(x, '.mat$');
p.addRequired('outname', vfo);

vff = @(x) ischar(x) && isrow(x) && ismember(x, {'slow', 'spindles', 'beta', 'gamma'});
p.addRequired('freqpreset', vff);

vfd = @(x) isdir(x);
p.addOptional('destdir', '', vfd);

p.parse(chanSpec, outname, freqpreset, varargin{:});

destdir = p.Results.destdir;
clear vfc vfo vff vfd p

%% Job

Cres = cell(chanSpec.MatNum, 1);
n = chanSpec.MatNum;

wb = [];
for i = 1:n
    % waitbar
    filename = chanSpec.MatNames{i};        
    wbmsg = sprintf('In progress: %s (%d/%d)', filename, i, n);
    wb = K_waitbar(i-1, n, wbmsg, wb);
    
    
    rec =  chanSpec.constructRecord(i);
    chantitles = rec.ChanTitles;
    
    eegtitle = local_geteegtitle(chantitles);
    spktitle = local_getspktitle(chantitles, rec);
    m = length(spktitle);
    
    C= cell(m, 1);
    for j = 1:m
        Spk = rec.(spktitle{j});
        [~, C{j}] = Spk.plotPhaseHist(rec.(eegtitle), 'plotECDF', false, 'plotLinear',...
            false, 'plotCirc', false, 'Preset', freqpreset);
        
        C{j}.id = [rec.RecordTitle, '|', spktitle{j}];
        C{j}.location = Spk.Header.location;
        C{j}.dopamine = Spk.Header.dopamine;
        C{j}.animal = Spk.Header.animal;
        C{j}.record = Spk.Header.record;
        C{j}.Fs = Spk.SRate;
        C{j}.duraiton = Spk.MaxTime;
    end

    Cres{i} = [C{:}];
    
end
close(wb);
clear wb wbmsg C


Sres = local_reorderfields([Cres{:}]');
result = struct2table(Sres, 'RowNames', {Sres(:).id});

% Add measurments
result.raylecdf = arrayfun(@(x) x.raylecdf, result.unitrad);
result.vlen = arrayfun(@(x) x.vlen, result.unitrad);
result.cmean = arrayfun(@(x) x.cmean, result.unitrad);

unitrad = result.unitrad; % intermediate variable is required for deep reference
result.nspikes =cellfun(@sum, {unitrad(:).histN})';

%% Save result

pvt_chanSpec_save_result(chanSpec, result, destdir, outname, eid('ParentDir:notidentical'));


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Sout = local_reorderfields(S)

finames = fieldnames(S);
len = length(finames);

[~, a] = ismember('id', finames);
[~, b] = ismember('animal', finames);
[~, c] = ismember('record', finames);
[~, d] = ismember('location', finames);
[~, e] = ismember('dopamine', finames);

order = setdiff(1:len, [a, b, c, d, e]);

Sout = orderfields(S, finames([a, b, c, d, e, order]));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eegtitle = local_geteegtitle(chantitles)

iseeg = @(x) ismatchedany(x, 'EEG|IpsiEEG');
EEGind = iseeg(chantitles);

assert(nnz(iseeg(chantitles)) == 1,...
    'K:chanSpec_getPhaseHist:EEG',...
    'Only one EEG channel must be included in each mat file.');

eegtitle = chantitles{EEGind};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spktitle = local_getspktitle(chantitles, rec)

SPKind = cellfun(@(x) isa(x, 'MetaEventChan'), rec.Chans);

assert(nnz(SPKind) >= 1,...
    'K:chanSpec_getPhaseHist:spike',...
    'At least one event/marker channel must be included in each mat file.');

spktitle = chantitles(SPKind);


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