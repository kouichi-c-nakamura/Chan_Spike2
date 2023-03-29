%K_PhaseHist_script
clear;close all;clc;

load('Z:\Dropbox\Private_Dropbox\Kouichi MATLAB data\thalamus\S potentials\HF pauser\PC\SWA\kjx021i01_i02_spliced.mat');
srate = 1/unite.interval;

smalle_ts= EventChan(smalle.values, 0, srate, 'smalle');
eegw_ts = WaveformChan(IpsiEEG.values, 0, srate, 'eeg');
unite_ts = EventChan(unite.values, 0, srate, 'unite');
onset_ts = EventChan(onset.values, 0, srate, 'onset');

newRate = 1024;

% make filter
getNF = @(freq, srate) freq/(srate/2);
[b, a] = butter(2, getNF([0.4, 1.6], newRate));

[results] = K_PhaseHist(onset_ts.Data, eegw_ts.Data, srate, newRate, b, a);

[results, handles] = K_PhaseHist(onset_ts.Data, eegw_ts.Data, srate, newRate, b, a,...
    'plotECDF', true);



[results] = K_PhaseHist(onset_ts.Data, eegw_ts.Data, srate, newRate, b, a,...
    'plotLinear', true);

[results] = K_PhaseHist(onset_ts.Data, eegw_ts.Data, srate, newRate, b, a,...
    'plotCirc', true);

u = results.unitrad;

%method plotPhaseHist
[results] = onset_ts.plotPhaseHist(eegw_ts,  'plotECDF', true);

% threshold
[results] = onset_ts.plotPhaseHist(eegw_ts, 'threshold', [0.02, 0.25], 'plotECDF', true);



%% transform [-pi, pi] to [0, 4*pi]
twopi = @(x) circshift(repmat(x, 2, 1), round(size(x, 1)/2));

ang2rad = @(x) x * pi /180;
rad2ang = @(x) x/pi*180;

%% plot linear phase histogram

ax(1) = subplot('Position', [0.13, 0.11, 0.775, 0.75]);
ax(2) = subplot('Position', [0.13, 0.87, 0.775, 0.10]);


x = twopi(u.axrad);
x = round(rad2ang(unwrap([x(end);x;x(1)]))); % 2 cylces + alpha
y = twopi(u.histnorm*100);
y = [y(end); y; y(1)]; % 2 cylces + alpha

lh1= plot(ax(1), x, y, 'LineWidth', 2);
xtic = cellfun(@(x) [num2str(x), 'º'], num2cell(0:90:720), 'UniformOutput', false);
set(ax(1), 'TickDir', 'out', 'Box', 'off',...
    'XTick', 0:90:720, 'XTickLabel', xtic,...
    'XLim', [0, 720]);

hold(ax(1)) % doesn't work
lh2= plot(ax(1),[90:90:720;90:90:720], ylim(ax(1))', 'Color', [0.5 0.5 0.5]);
uistack (lh2, 'bottom');
xlabel(ax(1),'Phase');
ylabel(ax(1), 'Firing Probabiliy per 10º [%]');

%% subplot for cosine curve

x2 = linspace(0, 720, 1440);
y2 = cos(ang2rad(x2));
plot(ax(2), x2, y2, 'Color' , 'k', 'LineWidth', 2);
set(ax(2), 'Visible', 'off', 'XLim', [0, 720], 'YLim', [-1.1, 1.1]);



%% plot linear phase histogram
h = K_plotLinearPhaseHist(u.unitrad, 72);





%% plot circular phase histogram
h = CircularPlotSingle_KCN(cmean, veclen, radians, color1, axh, omitcircles, zero_pos, direction)

h = K_circularPlot_oneCell(u.unitrad);
h = K_circularPlot_oneCell(u.unitrad, 'Color', 'g',...
    'zeropos', 'bottom', 'dir', 'anti');
h = K_circularPlot_oneCell(gca, u.unitrad);


h = K_circularPlot_oneCell(u.unitrad, 'Histbin', 36);
h = K_circularPlot_oneCell(u.unitrad, 'Histbin', 36, 'HistLimPercent', 12);
h = K_circularPlot_oneCell(u.unitrad, 'Histbin', 36, 'HistLimPercent', 0);


%% built-in plots
rose(u.unitrad)

pol = polar(u.unitrad,ones(size(u.unitrad)));
set(pol, 'LineStyle', 'none', 'Marker', 'o')

circ_plot(u.unitrad, 'pretty');
circ_plot(u.unitrad, 'hist');
circ_plot(u.unitrad, 'density');

%% 
datacell = [fieldnames(results)';...
     struct2cell(results)'];
data = cell2dataset(datacell, 'ObsName', {'kjx021i'})
openvar('data');

datacell(2, 11)


