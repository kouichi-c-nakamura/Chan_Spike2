function [selected,TF,indOnset,indOffset,loc] = findEpochsByEnvelope(...
    filtered,Fs,varargin)
% findEpochsByEnvelope will return subset of data filtered whose envelope
% satisfies criteria by minPeakHeight, minPeakWidthSec and percentile.
% Particularly useful when you want to select epochs with strong spindle
% activities (prepare filtered by using butter and filtfilt).
%
%
% [selected,TF,indOnset,indOffset,loc] = findEpochsByEnvelope(filtered,Fs)
% [selected,TF,indOnset,indOffset,loc] = findEpochsByEnvelope(____,'Param',value,...)
%
% ALGORHYTHM
% 1. Detect peaks of envelope of filtered with parameters minPeakHeight and
%    minPeakWidthSec
% 2. Extend the epochs up to the data points at which envelope >= 95
%    percentile
% 3. Further extend the epochs up to data points whose phase is -90°.
%
%
% INPUT ARGUMENTS
%
% filtered    column vector of ECoG Waveform data
%
% Fs          Sampling frequency in Hz
%
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'plot'      false (default) | true
%             (Optional) ture to plot the data
%
% minPeakHeight
%             (default) prctile(abs(hilbert(filtered)),95)
%             Minimal peak height for findpeaks. Default is 95 percentile
%             of the envelope of filtered.
%
% minPeakWidthSec
%             (default) 0.25
%             Minimal peak width in sec for findpeaks
%
%
% OUTPUT ARGUMENTS
% selected    Subset of filtered data selected by 
%             selected = filtered(TF);
%
% TF          logical column vector with the same length with env.
%             True for data points that are to be included in selected
%
% indOnset    Onset indices for detected windows
%
% indOffset   Offset indices for detected windows
%
%
%
% See also
% hilbert, scr2016_07_08_195249_Thresholding_K_PhaseHist, crossthreshold
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 11-Jul-2016 14:18:55

p = inputParser;
p.addRequired('filtered',@(x) iscolumn(x) && isnumeric(x));
p.addRequired('Fs',@(x) isscalar(x) && x > 0);
p.addParameter('minPeakHeight',[],@(x) isscalar(x));
p.addParameter('minPeakWidthSec',0.25,@(x) isscalar(x) && x > 0);
p.addParameter('plot',false,@(x) isscalar(x) && x ==0 || x == 1);
p.addParameter('original',[],@(x) iscolumn(x) && length(x) == length(filtered));

p.parse(filtered,Fs,varargin{:});

doplot          = p.Results.plot;
minPeakHeight   = p.Results.minPeakHeight;
minPeakWidthSec = p.Results.minPeakWidthSec;
orig            = p.Results.original;


env = abs(hilbert(filtered));
rad = angle(hilbert(filtered));


wh = which('findpeaks');
if ~isempty(wh) && isempty(strfind(wh, fullfile('toolbox','signal','signal','findpeaks.m')))
    rmpath(fileparts(wh));
end

if isempty(minPeakHeight)
    minPeakHeight = prctile(env,95);
end


[~,loc]= findpeaks(env,'MinPeakHeight',minPeakHeight,'MinPeakWidth',Fs*minPeakWidthSec);

if ~isempty(wh) && isempty(strfind(wh, fullfile('toolbox','signal','signal','findpeaks.m')))
    addpath(wh)
end

%%
n = length(loc);
w = Fs;
before = zeros(n,w,'single'); % assuming nor peak is wider than 2 sec
after  = zeros(n,w,'single'); % assuming nor peak is wider than 2 sec

indStart = zeros(n,1);
indEnd   = zeros(n,1);
indStart2 = zeros(n,1);
indEnd2   = zeros(n,1);
for i = 1:n
    
    indStart(i) = find(env(loc(i)-1:-1:1) <= minPeakHeight,1,'first'); % backwards
    indEnd(i)   = find(env(loc(i)+1:end) <= minPeakHeight,1,'first');
    
    %% Before
    %exntend to -90? or -pi/2
    radbef = rad(loc(i)-indStart(i):-1:1); % backwards from indStart
    radbef(radbef < -pi/2) = radbef(radbef < -pi/2) + pi*2;

    indStart2(i) = indStart(i) + find(diff(radbef) > pi, 1, 'first');  % backwards
    
    before(i,end-indStart2(i)+1:end) = 1;
    before(i,(loc(i)-w:loc(i)-1) <= 0) = NaN;

        
    %% After
    radaft = rad(loc(i)+indEnd(i):end);
    radaft(radaft > -pi/2) = radaft(radaft > -pi/2) - pi*2;

    indEnd2(i) = indEnd(i) + find(diff(radaft) < -pi, 1, 'first');
    
    after(i,1:indEnd2(i)) = 1;
    after(i,(loc(i)+1:loc(i)+w) > length(env)) = NaN;
    
end

%%

TF = false(1,length(env));

for i = 1:n
    TF(loc(i)) = true;
    
    bef = before(i,:);
    bef(isnan(bef)) = []; % get rid of NaNs
    
    ind = loc(i)-length(bef):loc(i)-1;
    TF(ind) = TF(ind) | bef;
    
    aft = after(i,:);
    aft(isnan(aft)) = []; % get rid of NaNs
    
    ind = loc(i)+1:loc(i)+length(aft);
    TF(ind) = TF(ind) | aft;
    
end

TF = TF';

selected = filtered(TF);

[indOnset,indOffset] = local_TF2indOnset_indOffset(TF);

if doplot
    local_plot(env,loc,Fs,filtered,orig,indOnset,indOffset,minPeakHeight);
end


end

%--------------------------------------------------------------------------

function [indOnset,indOffset] = local_TF2indOnset_indOffset(TF)

diffTF = diff(TF);
indOnset = find(diffTF == 1) +1;
if TF(1)
    indOnset = [1,indOnset];
end

indOffset = find(diffTF == -1);
if TF(end)
    indOffset = [indOffset,length(diffTF)];
end


end

%--------------------------------------------------------------------------

function [axh,linh,figh] = local_plot(env,loc,Fs,eegLfilt,orig,indOnset,indOffset,minPeakHeight)


Is = 1/Fs;
t = 0:Is:Is*(length(env) -1);

figh = figure;
axh = plotyygeneral;
hold(axh(1),'on');
linh(1) = plot(axh(1),t,eegLfilt,'Color',defaultPlotColors(1),...
    'DisplayName','Filtered signal');
linh(2) = plot(axh(1),t,env,  'Color',defaultPlotColors(1),...
    'DisplayName','Amplitude Envelope');

xlabel(axh(1),'Time (sec)')
ylabel(axh(1),'Filtered Potential (mV)')

if ~isempty(orig)
    hold(axh(2),'on');
    axh(2).YColor = defaultPlotColors(2);
    linh(3) = plot(axh(2),t,orig,'Color',defaultPlotColors(2),...
        'DisplayName','Instaneous Phase');

    ylabel(axh(2),'Original Potential (mV)');

else
    
    axh(2).Visible = 'off';
    
end


line(t(loc),env(loc),'LineStyle','none','marker','v','Color',defaultPlotColors(1));


linh(4) = line(axh(1),[t(1),t(end)],[minPeakHeight,minPeakHeight],'Color',defaultPlotColors(4));

linkaxes(axh,'x')
xlim(axh(1),'auto')



tOnset = t(indOnset);
tOffset = t(indOffset);

x = [tOnset;tOffset;tOffset;tOnset];
y = repmat([-0.5;-0.5;0.5;0.5],1,length(tOnset));

patch(x,y,[0.5 0.5 0.5],'FaceAlpha',0.2,'EdgeColor',[0.5 0.5 0.5]);
zoom xon; pan xon;
    
end

