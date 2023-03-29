function [result] = chanSpec_getPowerSpectra(chanSpec, outname, freqpreset, varargin)
% [result] = chanSpec_getPowerSpectra(chanSpec, outname, freqpreset)
% [result] = chanSpec_getPowerSpectra(chanSpec, outname, freqpreset, destdir)
%
% INPUT ARGUMENTS
% chanSpec       a ChanSpecifier obbject.
%                A .mat file or A Record object that is listed in a
%                ChanSpecifier object must contain ONLY one Waveform data.                
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
% result  
%                Structure.
%                result.high and result.low are table containing power
%                spectra of WaveformChan objects in Record. reshigh is for
%                higher frequency range, reslow is for lower frequency
%                range
%
% See also
% ChanSpecifier, Record, WaveformChan, chanSpec_getPhasehistAgainstEEG
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

Creshigh = cell(chanSpec.MatNum, 1);
Creslow = cell(chanSpec.MatNum, 1);
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

    EEG = rec.(eegtitle);
    
    if EEG.SRate < 1024
        warning off backtrace
        warning(eid('SRate:toolow'),...
            'Sampling frequency of %s//%s is %.0f Hz and lower than 1024 Hz', rec.RecordTitle, eegtitle, EEG.SRate)
        warning on backtrace
    end
    
    newRate = 1024;
    
    window = newRate*4;
    noverlap = newRate*2;
    nfft = newRate*4;
    
    clear Shigh
    Shigh = local_plotPowerSpectrum(rec, newRate, window, nfft, noverlap, eegtitle, EEG);

    window = newRate*10;
    noverlap = newRate*5;
    nfft = newRate*10; % frequency resolution 0.1 Hz

    clear Slow
    Slow = local_plotPowerSpectrum(rec, newRate, window, nfft, noverlap, eegtitle, EEG);
    
    Creshigh{i, 1} = Shigh; 
    Creslow{i, 2} = Slow;
    
end
close(wb);
clear wb wbmsg Shigh Slow


Creshigh = local_reorderfields([Creshigh{:}]');
reshigh = struct2table(Creshigh, 'RowNames', {Creshigh(:).id});

Creslow = local_reorderfields([Creslow{:}]');
reslow = struct2table(Creslow, 'RowNames', {Creslow(:).id});

result.high = reshigh;
result.low = reslow;

%% Save result

pvt_chanSpec_save_result(chanSpec, result, destdir, outname, eid('ParentDir:notidentical'));


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function S = local_plotPowerSpectrum(rec, newRate, window, nfft, noverlap, eegtitle, EEG)

[~, S] = EEG.plotPowerSpectrum(newRate, window, nfft, 'plottype', 'none', 'noverlap', noverlap);

S.id = [rec.RecordTitle, '|', eegtitle];
S.location = EEG.Header.location; 
S.dopamine = EEG.Header.dopamine;
S.animal = EEG.Header.animal;
S.record = EEG.Header.record;
S.Fs = EEG.SRate;
S.duraiton = EEG.MaxTime;

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