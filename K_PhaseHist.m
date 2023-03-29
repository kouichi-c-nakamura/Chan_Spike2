function [results, handles] = K_PhaseHist(event,eegwaveform,sourceRate,newRate,b,a,varargin)
% K_PhaseHist resample event and eegwaveform at newRate and further filter
% eegwaveform with filter b and a to perform phase analysis with Hilbert
% transform
%
% [results, handles] = K_PhaseHist(event, eegwaveform, sourceRate, newRate, b, a, varargin)
% based on Andy Sharott's script 2012
%
% INPUT ARGUMENTS
% event       a vector only containing 0 or 1
%
% eeg          a vector with the same length as event
%
% sourceRate   sampling rate [Hz] of the input data event and eeg
%
% newRate      the new sampling rate [Hz] after resample
%              In many cases, 1024 is good.
%
% b, a         b and a as coefficients of a filter transfer function
%              b, a must be calculated for newRate rather than souceRate
%              b for numeraotr, a for denominator. You can get b and a by:
%
%              [b, a] = butter(n, Wn)
%
%              where n is the order of the Butterworth filter (lowpass), or
%              half the order(bandpass). Wn is normalized cuttoff
%              frequency, i.e. [cycles per sec] devided by Niquist
%              frequency [newRate/2].
%
%              Wn = frequencyHerz/(samplingrateHerz/2)
%
%              The following command can check the stablity of the filter
%              fvtool(b,a,'FrequencyScale','log', 'Analysis','info');
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'PlotECDF'     true | false (default)
%                true will produce plots for the effects ofECDF-based correction 
%                of non-sinusoidal nature of oscillations
%
% 'PlotLinear'   true | false (default)
%                true will produce linear phase histogram
%
% 'PlotCirc'     true | false (default)
%                true will produce circular plot for phase coupling
%
% 'Histbin'      Scalar positive number 
%                The number of histogram bins  (default = 36)
%
% 'HistType'     'line' | 'bar' (default)
%                Histogram format
%
% 'DoSpectral'   true (default) | false
%                true will include spectral analyses of power with pwelch and 
%                coherence with sp2a_m1 of NeuroSpec 2 in results. 
%                false will leave relevant fields of results empty.
%
% OUTPUT ARGUMENTS
% results       Structure conttaining following fields
%
%     unitrad       unit phase histogram
%         'axang'
%         'axrad'
%         'histN'
%         'histnorm'
%         'unitrad'
%         'stats'
%         'cmean'
%         'rayl'
%         'raylecdf'
%         'vlen'
%         'cvar'
%         'cstd'
%     eegrad        EEG phase histogram
%         'axang'
%         'axrad'
%         'histN'
%         'histnorm'
%         'rayl'
%         'raylecdf'
%         'cmean'
%         'vlen'
%     eegpwelch     pwelch, EEG, frequency resolution 0.25 Hz
%         'pow'
%         'powax'
%         'Fs'
%         'nfft'
%         'noverlap'
%         'window'
%         'frequencyRes'
%     eegpwelchLow  pwelch, EEG, frequency resolution 0.1 Hz
%         'pow'
%         'powax'
%         'Fs'
%         'nfft'
%         'noverlap'
%         'window'
%         'frequencyRes'
%     ue_lres       Neurospec2.0 sp2a_m1 output, unit vs EEG, 1 Hz Frequency resolution
%         'specax'
%         'upow'
%         'epow'
%         'uecoh'
%         'uepha'
%         'timeax'
%         'uesta'
%         'uecoh95'
%     ue_hres       Neurospec2.0 sp2a_m1() output, unit vs EEG, 0.25 Hz Frequency resolution
%         'specax'
%         'upow'
%         'epow'
%         'uecoh'
%         'uepha'
%         'timeax'
%         'uesta'
%         'uecoh95'
%
% handles        Structure of graphic handles
%
% See also
% K_plotLinearPhaseHist 
% K_plotLinearPhaseHist_S  (to directly use output of K_PhaseHist as an input argument)
% K_PhaseHist_histlabel    (add summary text to the plots made by K_PhaseHist)
% K_plotCircPhaseHist_one, K_plotCircPhaseHist_group (for circular plots)
% K_plotColorPhaseHist     (heatmap representation of phase coupling)
% K_ECDFforRayleigh        (ECDF-based correction for Rayleigh's uniformity test)
% K_PhaseHist_test         (UnitTest)
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 05-May-2017 09:24:37


%% parse inputs

narginchk(4, inf);

[event, eegwaveform, sourceRate, newRate, b, a, plotECDF, plotLinear, ...
    plotCirc, histbin, ColorSpec, histtype, dospectral] = ...
    local_parse(event, eegwaveform, sourceRate, newRate, b, a, varargin{:});

%% resampling
eeg = resample(eegwaveform, newRate, sourceRate); % resampled eeg waveform
clear eegwaveform

unit = zeros(size(eeg,1),1);
unit(round(((find(event))*newRate/sourceRate)))= 1; % spike event binary vector resampled at newRate
%TODO how to avoid the error below? Accept non-binary vector. Isn't it
%histc?

if length(find(unit)) ~= length(find(event))
    warning(eid('NewRate'),...
        'After resample %d spikes were lost. newRate seems too low.', ...
         length(find(event)) - length(find(unit)));
end
clear event


%% core computation for Hilbert transform
eegf = filtfilt(b, a, eeg); % filtering without phase shift
eegrad = angle(hilbert(eegf)); % instantaneous phase value in radians
eegenv = abs(hilbert(eegf)); % amplitude envelope

    
%% unit phase histograms

unitrad = eegrad(logical(unit)); %instantaneous phase values for spike event in radians

edges = (-pi:(2*pi)/36:pi)'; % 10 degree bin in radians
rad2ang =@(x) x/pi*180;
ang2rad = @(x) x * pi /180;

axang = round(rad2ang(edges(1:end-1))+5); % x axis, converted from radian to angle, +5 to point the center of each bin
axrad = edges(1:end-1) + ang2rad(5);

na = histc(unitrad,edges);
if isrow(na) % when unitrad is scalar na is in row
    na = na';
end
unitradN = [na(1:end-2);...
    na(end-1) + na(end)];% histc of unitrad
% na(end) doesn't have bin width, so merge it with the previous bin
clear na


results.unitrad.axang = axang;
results.unitrad.axrad = axrad;
results.unitrad.histN = unitradN;
results.unitrad.histnorm = unitradN./sum(unitradN);
results.unitrad.unitrad = unitrad;

%% circular statistics of unitrad
if ~isempty(unitrad)
    stats = circ_stats(unitrad);
    
    results.unitrad.stats = stats;
    results.unitrad.cmean = stats.mean;
    
    results.unitrad.rayl =  circ_rtest(unitrad); % Rayleigh test
    [pval1,~,hunitecdf] = K_ECDFforRayleigh(eegrad,unit,newRate,eeg,eegf,eegenv,'plotECDF',plotECDF);
    
    results.unitrad.raylecdf = pval1;
    
    results.unitrad.vlen = circ_r(unitrad); % vector length
    results.unitrad.cvar = circ_var(unitrad);
    results.unitrad.cstd = circ_std(unitrad);
else
    results.unitrad.stats = [];
    results.unitrad.cmean = NaN;
    
    results.unitrad.rayl =  NaN; % Rayleigh test
    hunitecdf = [];
    
    results.unitrad.raylecdf = NaN;
    
    results.unitrad.vlen = NaN; % vector length
    results.unitrad.cvar = NaN;
    results.unitrad.cstd = NaN;
    
end


%% eeg phasehistgram

nb = histc(eegrad,edges);
eegradN = [nb(1:end-2);...
    nb(end-1) + nb(end)];

results.eegrad.axang = axang;
results.eegrad.axrad = axrad;
results.eegrad.histN = eegradN;
results.eegrad.histnorm = eegradN./sum(eegradN);
results.eegrad.rayl = circ_rtest(eegrad); % Rayleigh's test
[pval2,~,heegecdf] = K_ECDFforRayleigh(eegrad,eegrad,newRate,eeg,eegf,eegenv,'plotECDF',false);

results.eegrad.raylecdf = pval2;

results.eegrad.cmean = circ_mean(eegrad); 
results.eegrad.vlen = circ_r(eegrad);
% results.eegrad.eegenv =eegenv; % heavy
% results.eegrad.eegrad =eegrad; % heavy

if dospectral

    %% Power sepctra
    window = newRate*4;
    noverlap = newRate*2;
    nfft = newRate*4;
    
    results.eegpwelch = local_pwelch(eeg,window,noverlap,nfft,newRate);
    %
    % [Pxx,Pxw] = pwelch(eeg,window,noverlap,nfft,newRate); %TODO
    %
    % results.eegpwelch.pow = Pxx;
    % results.eegpwelch.powax = Pxw;
    % results.eegpwelch.Fs = newRate;
    % results.eegpwelch.nfft = nfft;
    % results.eegpwelch.noverlap = noverlap;
    % results.eegpwelch.window = window;
    % results.eegpwelch.frequencyRes = newRate/nfft;
    
    
    %% Power sepctra for lower freq
    windowL = newRate*10;
    noverlapL = newRate*5;
    nfftL = newRate*10; % frequency resolution 0.1 Hz
    
    results.eegpwelchLow = local_pwelch(eeg, windowL,noverlapL,nfftL,newRate);    
    
    %% unit vs EEG Low Res
    
    samp_rate = newRate;
    seg_pwr1 = 10; %Segment length (2^10 = 1024) ... frequency resolution is 1 Hz
    sp1 = find(unit);
    
    %TODO handle the case with no spike
    if isempty(sp1)
        results.ue_lres.specax = [];
        results.ue_lres.upow = [];
        results.ue_lres.epow = [];
        results.ue_lres.uecoh = [];
        results.ue_lres.uepha = [];
        results.ue_lres.timeax = [];
        results.ue_lres.uesta = [];
        results.ue_lres.uecoh95 = [];
    else
        [f,t,cl,~] =  sp2a_m1(0,sp1,eeg,samp_rate,seg_pwr1,'h');
        % psp2(f,t,cl,100,1000,500,1)
        
        results.ue_lres.specax = f(:,1);
        results.ue_lres.upow = f(:,2);
        results.ue_lres.epow = f(:,3);
        results.ue_lres.uecoh = f(:,4);
        results.ue_lres.uepha = f(:,5);
        results.ue_lres.timeax = t(:,1);
        results.ue_lres.uesta = t(:,2);
        results.ue_lres.uecoh95 = cl.ch_c95;
    end
    
    
    
    %% unit vs EEG High Res
    
    if isempty(sp1)
        results.ue_hres.specax = [];
        results.ue_hres.upow = [];
        results.ue_hres.epow = [];
        results.ue_hres.uecoh = [];
        results.ue_hres.uepha = [];
        results.ue_hres.timeax = [];
        results.ue_hres.uesta = [];
        results.ue_hres.uecoh95 = [];
    else
        seg_pwr2 = 12;%Segment length (2^12 =4096 ) ... frequency resolution is 0.25 Hz
        [fb,tb,clb,~] =  sp2a_m1(0,sp1,eeg,samp_rate,seg_pwr2,'h');
        % psp2(fb,tb,clb,100,1000,500,1)
        
        results.ue_hres.specax = fb(:,1);
        results.ue_hres.upow = fb(:,2);
        results.ue_hres.epow = fb(:,3);
        results.ue_hres.uecoh = fb(:,4);
        results.ue_hres.uepha =  fb(:,5);
        results.ue_hres.timeax = tb(:,1);
        results.ue_hres.uesta = tb(:,2);
        results.ue_hres.uecoh95 = clb.ch_c95;
        
    end

else
    results.eegpwelch = [];
    results.eegpwelchLow = [];
    results.ue_lres = [];
    results.ue_hres = [];
    
end


if plotLinear
    hlin = K_plotLinearPhaseHist(results.unitrad.unitrad, histbin, ...
        'color', ColorSpec,'plottype',histtype,...
        'rayleighECDF',results.unitrad.raylecdf);
    
else
    hlin = [];
end

if plotCirc
    hcirc = K_plotCircPhaseHist_one(results.unitrad.unitrad, histbin, ...
        'color', ColorSpec,'rayleighECDF',results.unitrad.raylecdf);

else
    hcirc = [];
end


handles.hunitecdf = hunitecdf;
handles.heegecdf = heegecdf;
handles.hlin = hlin;
handles.hcirc =hcirc;

% K_PhaseHist_histlabel(results, handles, 'Linear Phase Histogram', ...
%     'Circular Phase Histogram')


end

%--------------------------------------------------------------------------
function S = local_pwelch(eeg,window,noverlap,nfft,newRate)

[Pxx,Pxw] = pwelch(eeg,window,noverlap,nfft,newRate);

S.pow = Pxx;
S.powax = Pxw;
S.Fs = newRate;
S.nfft = nfft;
S.noverlap = noverlap;
S.window = window;
S.frequencyRes = newRate/nfft;

end

%--------------------------------------------------------------------------

function [event, eegwaveform, sourceRate, newRate, b, a, plotECDF, plotLinear, ...
    plotCirc, histbin, ColorSpec, histtype, dospectral] = ...
    local_parse(event, eegwaveform, sourceRate, newRate, b, a, varargin)

p = inputParser;

p.addRequired('event', @(x) (isnumeric(x) || islogical(x)) && ...
    iscolumn(x) && all(x(x ~= 0) == 1));

p.addRequired('eeg', @(x) isnumeric(x) && iscolumn(x) && ...
    length(x) == length(event));

vfscnumpos = @(x) isnumeric(x) && isscalar(x) && x > 0;

p.addRequired('sourceRate', vfscnumpos);
p.addRequired('newRate', vfscnumpos);

vfnumrow = @(x) isnumeric(x) && isrow(x);

p.addRequired('b', vfnumrow);
p.addRequired('a', vfnumrow);

p.addParameter('plotECDF', false, @(x) ~isempty(x) && isscalar(x) && ...
    x == 0 || x == 1);
p.addParameter('plotLinear', false, @(x) ~isempty(x) && isscalar(x) && ...
    x == 0 || x == 1);
p.addParameter('plotCirc', false, @(x) ~isempty(x) && isscalar(x) && ...
    x == 0 || x == 1);
p.addParameter('histBin', 36, @(x) isscalar(x) && isnumeric(x) && ...
    x > 0 && fix(x) == x);
p.addParameter('Color', 'b', @(x) iscolorspec(x));
p.addParameter('histType', 'bar', @(x) ~isempty(x) && ischar(x) && isrow(x) &&...
            ismember(lower(x),{'line','bar'}));
p.addParameter('DoSpectral', false, @(x) ~isempty(x) && isscalar(x) && ...
    x == 0 || x == 1);

p.parse(event, eegwaveform, sourceRate, newRate, b, a,varargin{:});

if ~isstable(b, a)
    %if ~K_isstable(b, a) % using fvtool
    warning(eid('filter:notstable'), ...
        'Filter is not stable. Reconsider the parameters.');
end

plotECDF   = logical(p.Results.plotECDF);
plotLinear = logical(p.Results.plotLinear);
plotCirc   = logical(p.Results.plotCirc);
histbin    = p.Results.histBin;
ColorSpec  = p.Results.Color;
histtype   = lower(p.Results.histType);
dospectral   = logical(p.Results.DoSpectral);

          
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


