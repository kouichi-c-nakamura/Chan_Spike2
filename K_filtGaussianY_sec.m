function yy = K_filtGaussianY_sec(y, sizesec, sigmasec, Fs, varargin)
% yy = K_filtGaussianY_sec(y, sizesec, sigmasec, Fs, doplot)
%
% input variables
% y          real vector
% sizesec    positive real number that specifies the width of the Gaussian
%            filter in sec
% sigmasec   positive real number that specifies the standard deviation of the
%            Gaussian PDF in sec
% Fs         sampling frequency [Hz] or points/sec
% doplot     1 or 0 (true or false) ... default is false


%% parse

narginchk(4,5);

p = inputParser;

vf_y = @(x) isvector(x) && all(isnumeric(x)) && all(isreal(x));
vf_size = @(x) isscalar(x) && x > 0 ; % width in sec
vf_sigma = @(x) isscalar(x) && x > 0 ; % SD in sec
vf_Fs =  @(x) isscalar(x) && x > 0 ; % Hz
vf_doplot = @(x) isscalar(x) && islogical(x) || x == 0 || x ==1; 

addRequired(p, 'y', vf_y);
addRequired(p, 'sizesec', vf_size);
addRequired(p, 'sigmasec', vf_sigma);
addRequired(p, 'Fs', vf_Fs);
addOptional(p, 'doplot', false, vf_doplot);

parse(p, y, sizesec, sigmasec, Fs, varargin{:});

doplot = p.Results.doplot;


%% job

size = sizesec*Fs; % in points
sigma = sigmasec*Fs; % in points

X = fix(-size/2):fix(size/2);

if doplot
    gaussFilter = normpdf(X, 0, sigma);
    figure;plot(X/Fs, gaussFilter);
    xlabel('[sec]');
    ylabel('Probability');
    set(gca, 'Box', 'off', 'TickDir', 'out');
end

yy = conv(y, gaussFilter, 'same');


end



