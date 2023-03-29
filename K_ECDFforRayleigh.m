function [pval,z,h] = K_ECDFforRayleigh(eegrad,event,Fs,varargin)
% K_ECDFforRayleigh test for Rayleigh's uniformity test after correction
% with ECDF. See Siapas et al. (2005)
%
% Siapas AG, Lubenov EV, Wilson MA (2005) Prefrontal phase locking to
% hippocampal theta oscillations. Neuron 46:141-151.
% 
%  [pval,z,h] = K_ECDFforRayleigh(eegrad,event,Fs)
%  [pval,z,h] = K_ECDFforRayleigh(eegrad,event,Fs,eeg,eegf,eegenv,mask)
%  [pval,z,h] = K_ECDFforRayleigh(_______, 'ParameterName, ParameterValue)
%
% REQUIREMENTS
% CircStat toolbox, in particular circ_rtest
%
% INPUT ARGUMENTS
%
% eggrad    A vector of instataneous phase values in radiands
%
% event     A vector of 0 or 1 for spike events
%
% Fs        Sampling frequency in Hz
% 
% OPTIONAL
% These options will be ignored if 'plotECDF' is false (default)
%
% eeg       EEG for plot
%
% eegf      Bandpass-filtered EEG signal for plot
%
% eegenv    Envelope of eeg for plot
%
% mask      A logical vector with the same size as event
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'plotECDF'  false (default) | true
%           If true, it requires eeg, eegf, eegenv,and mask.
%
% OUTPUT ARGUMENTS
% pval      P value for Rayleigh's Uniformity test with correction (see circ_rtest.m)
%
% z         value of the z-statistic (see circ_rtest.m)
%
% h         Structure of handles
%
% See also
% K_PhaseHist, circ_rtest
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
% 05-May-2017 09:32:34



narginchk(3,inf);

p = inputParser;
p.addRequired('eegrad',@(x) isvector(x) && isreal(x));
p.addRequired('event',@(x) isvector(x));% && all(x == 0 | x == 1));
p.addRequired('Fs',@(x) isscalar(x) && isreal(x) && x > 0);
p.addOptional('eeg',[],@(x) isvector(x) && isreal(x));
p.addOptional('eegf',[],@(x) isvector(x) && isreal(x));
p.addOptional('eegenv',[],@(x) isvector(x) && isreal(x));
p.addOptional('mask',[],@(x) isempty(x) || isvector(x) && all(x == 0 | x ==1));
p.addParameter('plotECDF',false,@(x) isscalar(x) && all(x == 0 | x ==1));
p.parse(eegrad,event,Fs,varargin{:});

eeg = p.Results.eeg;
eegf = p.Results.eegf;
eegenv = p.Results.eegenv;
mask = p.Results.mask;
plotECDF = p.Results.plotECDF;

%%

[cdf, cdfx]=ecdf(eegrad);
cdfphase = 2*pi*cdf-pi; % turn cdf into uniformly distributed phase values
cdfangle = cdfphase*360/(2*pi);

[~, sorting] = sort(eegrad);
% eeg(sorting) == eegsort == cdfx(2:end))

spkInCdfx = find(event(sorting)) +1; %cdfphase(1) is empty

cdfphaseSpkrad = cdfphase(spkInCdfx);
cdfphaseSpkang = cdfphaseSpkrad*360/(2*pi);

[pval, z] =circ_rtest(cdfphaseSpkrad);

h = [];

if ~plotECDF
    return
end
    
    
%% EEG, filtered EEG, Hilbert, spike, 
fig1 = figure;
figure(fig1);
hold on;
x = 1:length(eeg);
x = x/Fs;
[AX, H1, H2] = plotyy(x, eeg, x, eegrad*360/(2*pi));
h.fig1.h =fig1;
h.fig1.AX = AX;
h.fig1.H1 = H1;
h.fig1.H2 = H2;

set(H1,'Tag','EEG');
set(H2,'Tag','EEG Instantaneous Phase');

set(H2, 'Color', 'r');
set(AX(2), 'YColor' , 'r');
set(AX(1), 'Box', 'off', 'TickDir', 'out','Tag','Amplitude');
set(AX(2), 'Box', 'off', 'TickDir', 'out','Tag','Instantaneous Phase');
axes(AX(1));
H3 = line(x, eegf, 'Color', [0, 0.5, 0]);    
if ~isempty(eegenv)
   H4 =  plot(AX(1), x, eegenv, 'Color','k','Tag','EEG Envelope');
end  
axes(AX(2));
spk = find(event)*1/Fs;
H5 = line(spk, zeros(size(spk))+150, 'Marker','+', 'Color','k', ...
    'MarkerSize',10,'Tag','Spike Events');
H6 = line([x(1), x(end)], zeros(1,2)+150,'Color','k', ...
    'LineStyle', '-','Tag','Horizontal Line');
if ~isempty(mask)
    H7 = line(x(mask), zeros(nnz(mask), 1)+170, 'Marker', '.', 'Color','k', ...
        'LineStyle','none','MarkerSize',5,'Tag','Unmasked');
    H8 = line(x(~mask), zeros(nnz(~mask), 1)+175, 'Marker', '.', 'Color','k',...
        'LineStyle','none','MarkerSize',5,'Tag','Masked');
end

h.fig1.H3 = H3;
h.fig1.H4 = H4;
h.fig1.H5 = H5;
h.fig1.H6 = H6;
if ~isempty(mask)  
    h.fig1.H7 = H7;
    h.fig1.H8 = H8;
else
    h.fig1.H7 = [];
    h.fig1.H8 = [];      
end

ylim(AX(2), [-180, 180]);
zoom xon; pan xon;
set(get(AX(1),'Ylabel'),'String','Amplitude (mV)');
set(get(AX(2),'Ylabel'),'String',sprintf('Instantaneous Phase (%s)',char(176)));
yticklabeltidy(AX(2), [-180, -90, 0, 90, 180], 0);
xlabel('Time [sec]');
title('Butterworth filter and instataneous phase valuse obtained by Hilbert transform');
linkaxes(AX, 'x');
xlim([0 10]);


%% ECDF
h.fig1 = figure;

plot(cdfx*360/(2*pi), cdfangle);
ylim([-180 180]);
xlim([-180 180]);
yticklabeltidy(gca,[-180, -90, 0, 90, 180], 0);
xticklabeltidy(gca,[-180, -90, 0, 90, 180], 0);
ylabel(sprintf('Corrected instantaneous phase value (%s)',char(176)));
xlabel(sprintf('Instaneous phase values (%s)',char(176)));
title('Transformation by Empirical Cumulative Distribution Function');
hold on;
plot(cdfx(spkInCdfx)*360/(2*pi),cdfphaseSpkang,...
    'Color','r','LineStyle', 'none', 'Marker', 'o');
plot([180,180],[-180,180],':g');
legend({'Whole Data Points','Spike Events','Ideally Uniform Distribution'},...
    'Location','SouthEast','Box','off');

%% circular plots for BEFORE and AFTER

h.fig3 = figure;

subplot(2,2,1);
h.fig3p1 = local_rose2patch(eegrad,100,...
    {'Instantaneous phase values'; 'of all data points'},'BEFORE');

subplot(2,2,2);
h.fig3p2 = local_rose2patch(cdfphase,100,...
    'Uniformly redistributed by ecdf','AFTER');

subplot(2,2,3);
h.fig3p3 = local_rose2patch(spkInCdfx,50,...
    {'Instantaneous phase values';'of spike unit'},'BEFORE');

subplot(2,2,4);
h.fig3p4 = local_rose2patch(spkInCdfx,50,...
    {'Spike unit after'; 'uniform redistribution'},'AFTER');
    
end

%--------------------------------------------------------------------------

function h = local_rose2patch(data,N,titlestr,xlabelstr)
hrose = rose(data, N); % completely uniformly distributed
title(titlestr);
xlabel(xlabelstr);
XData = get(hrose, 'XData');
YData = get(hrose, 'YData');
assert(rem(length(XData), 4) == 0);
h = zeros(length(XData)/4,1);
for i = 1:length(XData)/4
    h(i) = patch(XData(i*4-3:i*4), YData(i*4-3:i*4), [0.7 0.7 0.7],'Tag','Petal');
end
hg = hggroup('Tag','Rose Petals');
set(h,'Parent',hg);
view(90, -90);
delete(hrose);

end
