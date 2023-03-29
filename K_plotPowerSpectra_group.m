function  [h, N] = K_plotPowerSpectra_group(Freq, Power, xrange, varargin)
% [h, N]  = K_plotPowerSpectra_group(Freq, Power, xrange)
% [h, N]  = K_plotPowerSpectra_group(_____, 'Parameter', Value)
%
% INPUT ARGUMENTS
% Freq         Column vector of Freq axis. length(X) == size(Power, 1)
%
% Power        Spectral power density obtained by pwelch etc. Freq (row) X samples (col)
%
% xrange       Such as [0 80]
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'yrange'     Such as [0 0.5]. Default is 'auto'. To be used for ylim.
%
% 'ylabel'     String. To be used for ylabel
%
% 'title'      String. To be used for title
%
% 'error'      String. Either 'sem' (default), 'std', or 'none'
%
% OUTPUT ARGUMENTS
%
% h            Graphic handles
%
% N            Sample number
%
%
% See also
% WaveformChan.plotPowerSpectrum

%% Parse

narginchk(3, 11);

%TODO more validation doable
p = inputParser;
p.addRequired('Power');
p.addRequired('Freq');

vfxr = @(x) isreal(x) && isrow(x) && length(x) == 2 && x(2) > x(1);
p.addRequired('xrange', vfxr);

vfyr = @(x) (ischar(x) && strcmpi(x, 'auto'))...
    || isreal(x) && isrow(x) && length(x) == 2 && x(2) > x(1);

p.addParamValue('yrange','auto', vfyr); % string input requires validation function

vfyl = @(x) ischar(x) && isrow(x);

p.addParamValue('ylabel','auto', vfyl); 

vfti = @(x) ischar(x) && isrow(x);
p.addParamValue('title','', vfti); 

vferr = @(x) ~isempty(x) && ischar(x) && isrow(x) && ismember(x, {'sem','std','none'});
p.addParamValue('error','sem', vferr);


p.parse(Power, Freq, xrange, varargin{:});

yrange = p.Results.yrange;
ylabeltext = p.Results.ylabel;
titletext = p.Results.title;
errormode = p.Results.error;

%% Job

N = size(Power, 2);
pow_mean = mean(Power, 2);
pow_std = std(Power, 1, 2);
pow_sem = pow_std/sqrt(N);

Freq = Freq(:,1)'; % vector for X axis
themean = pow_mean'; % vector for mean value

switch errormode
    case 'sem'
        errorrange = pow_sem'; % vector for STD or SEM
    case 'std'
        errorrange = pow_std';
    case 'none'
        errorrange = [];
end
% X, mean, and error must have the same length.

colorspec = 'g';

h.fig = figure;
hold on;
opengl software; % to prevent the bug described below

if ~isempty(errorrange)
    h.patch = fill([Freq, fliplr(Freq)], ...
        [themean+errorrange, fliplr(themean-errorrange)], ...
        colorspec, 'FaceAlpha', 0.5, 'linestyle', 'none'); %TODO dows not work at all
else
    h.patch = [];
end

h.line = plot(Freq, themean, 'Color', colorspec);
xlim(xrange);
if exist('yrange', 'var')
    ylim(yrange);
end
if exist('titletext', 'var')
    if~isempty(titletext)
        title(titletext);
    end
end

set(gca,'TickDir', 'out');
xlabel('Frequency [Hz]');

if exist('ylabeltext', 'var')
    if ~isempty(ylabeltext)
        ylabel(ylabeltext);
    end
end

h.axh = gca;

end