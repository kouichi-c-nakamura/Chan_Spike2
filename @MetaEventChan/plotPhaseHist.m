function [ handles, results ] = plotPhaseHist( obj, waveform, varargin)
% plotPhaseHist is a wrapper of K_PhaseHist
%
% [ handles, results ] = plotPhaseHist( obj, waveform, band)
% [ handles, results ] = plotPhaseHist( obj, waveform, newRate, b, a)
% [ handles, results ] = plotPhaseHist( -----, 'Param', Value)
%
%
% GENGERAL INPUT ARGUMENTS
% obj          A MetaEventChan object
%
% waveform     A WaveformChan object
%
%
%
% [ handles, results ] = plotPhaseHist( obj, waveform, band)
%
%
% SYNTAX-SPECIFIC INPUT ARGUMENTS
%
% band        'slow', 'spindles', 'beta', 'gamma'
%
%
%
% [ handles, results ] = plotPhaseHist( obj, waveform, newRate, b, a)
%
% SYNTAX-SPECIFIC INPUT ARGUMENTS
% newRate      the new sampling rate [Hz] after resample
%              In many cases, 1024 is good.
% b, a         b and a as coefficients of a filter transfer function
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
% 'Preset'        'slow', 'spindles', 'beta', 'gamma'
%
% 'plotECDF'      true or {false} 'plotLinear'    {true} or false
% 'plotCirc'      {true} or false 
%
% 'threshold'    [amp sec] (default [])
% 'color'         'ColorSpec  ' (default, 'b') 
%                 or cell array of ColorSpec  s for group data
%
% OUTPUT ARGUMENTS
% handles         graphic handles
%
% results         structure of results see K_PhaseHist for more details

%TODO threshold eegenv with wblabeln or else


%% parse waveform

narginchk(3, inf);

[waveform, sRate, newRate, b, a, plotECDF, plotLinear, plotCirc, ...
     histbin, ColorSpec, threshold_amp, threshold_sec, histtype, preset] = ...
     local_parse(obj, waveform, varargin{:});


%% job

% newRate, b, a, versus preset
if ~isempty(preset)
    switch preset
        case 'slow'
            newRate = 1024;
            [b, a] = butter(2, [0.4, 1.6]/512);
        case 'spindle'
            newRate = 1024;
            [b, a] = butter(3, [7, 12]/512);
        case 'beta'
            newRate = 1024;
            [b, a] = butter(3, [15, 30]/512);
        case 'gamma'
            newRate = 1024;
            [b, a] = butter(3, [30, 60]/512);
    end
end


% [results, handles] = K_PhaseHist(obj.Data, waveform.Data, sRate, newRate, b, a,...
%     'plotECDF', plotECDF, 'plotCirc', plotCirc, 'plotLinear', plotLinear, ...
%     'Histbin', histbin, 'Color', ColorSpec, 'threshold', [threshold_amp, threshold_sec],...
%     'histType',histtype);

[results, handles] = K_PhaseHist(obj.Data, waveform.Data, sRate, newRate, b, a,...
    'plotECDF', plotECDF, 'plotCirc', plotCirc, 'plotLinear', plotLinear, ...
    'Histbin', histbin, 'Color', ColorSpec, 'histType',histtype);


end

%--------------------------------------------------------------------------
 function [waveform, sRate, newRate, b, a, plotECDF, plotLinear, plotCirc, ...
     histbin, ColorSpec, threshold_amp, threshold_sec, histtype, preset] = ...
    local_parse(obj, waveform, varargin)
%
% See also
% K_PhaseHist/loca_parse

% narginchk(3,inf)

b = [];
a = [];
newRate = 1024;
preset = [];

p = inputParser;

p.addRequired('obj');
p.addRequired('waveform', @(x) ~isempty(x) && isa(x, 'WaveformChan') &&...
    isscalar(x));

vfnumrow = @(x) isnumeric(x) && isrow(x);

C = cell(0,0);
if ~isempty(varargin)
    if  ~isempty(varargin) && isnumeric(varargin{1})
        synt = 'newRateba';
        
        C = varargin(1:3);
        p.addRequired('newRate',1024,@(x) ~isempty(x) && isnumeric(x) && isscalar(x) && x > 0);
        p.addRequired('b',vfnumrow);
        p.addRequired('a',vfnumrow);
        
        varargin = varargin(4:end);
    elseif  ~isempty(varargin) && ismember(lower(varargin{1}),...
            {'slow', 'spindle', 'beta', 'gamma'})
        synt = 'preset';

        C = varargin(1);
        varargin = varargin(2:end);
        
        p.addRequired('preset',@(x) ismember(x,{'slow', 'spindle', 'beta', 'gamma'}))
        
    else
        synt = 'else';
    end
else
    synt = 'else';
end

p.addParameter('plotECDF', false, @(x) ~isempty(x) && isscalar(x) && ...
    x == 0 || x == 1);
p.addParameter('plotLinear', true, @(x) ~isempty(x) && isscalar(x) && ...
    x == 0 || x == 1);
p.addParameter('plotCirc', true, @(x) ~isempty(x) && isscalar(x) && ...
    x == 0 || x == 1);
p.addParameter('histBin', 36, @(x) isscalar(x) && isnumeric(x) && ...
    x > 0 && fix(x) == x);
p.addParameter('Color', 'b', @(x) iscolorspec(x));
p.addParameter('Threshold', [0 0], @(x) ~isempty(x) && ...
    isnumeric(x) && isrow(x) && length(x) ==2);
p.addParameter('histType', 'bar', @(x) ~isempty(x) && ischar(x) && isrow(x) &&...
            ismember(lower(x),{'line','bar'}));

p.parse(obj, waveform, C{:}, varargin{:});

switch synt
    case 'newRateba'
        newRate = p.Results.newRate;
        b       = p.Results.b;
        a       = p.Results.a;
    case 'preset'
        preset = lower(p.Results.preset);

end
 
if ~isempty(b) && ~isempty(a)
    if ~isstable(b, a) %TODO
        %if ~K_isstable(b, a) % using fvtool
        warning(eid('filter:notstable'), ...
            'Filter is not stable. Reconsider the parameters.');
    else
        preset = [];
        
    end
end

sRate = obj.SRate;

plotECDF   = logical(p.Results.plotECDF);
plotLinear = logical(p.Results.plotLinear);
plotCirc   = logical(p.Results.plotCirc);
histbin    = p.Results.histBin;
ColorSpec  = p.Results.Color;
Threshold  = p.Results.Threshold;
threshold_amp = Threshold(1);
threshold_sec = Threshold(2);

histtype   = lower(p.Results.histType);

if threshold_amp == 0
    threshold_amp = [];
end
if threshold_sec == 0
    threshold_sec = [];
end



                
end


