function h = textforpwelch(axh, window, noverlap, nfft, newFs, varargin)
%
% textforpwelch(axh, window, noverlap, nfft, newFs)
% textforpwelch(_________,'xy', [X, Y])
% textforpwelch(_________, 'params', paramvals)
% h = textforpwelch(_____________)
%
% 
% INPUT ARGUMENTS
% axh         axes object
%
% window      Length of FFT window in data point counts
%
% noverlap    Length of FFT window overlap in data point counts
%
% nfft        Size of FFT in data point counts
%
% newFs       New sampling frequency
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'params'    Prameter Value pairs stored in a cell array row vector for
%             text function
%
% 'xy'        [xpos, ypos]
%             Position of text object
%
% OUTPUT ARGUMENTS
% h           Text object
%
%
% See also
% textformtspectrum, pwelch, mscohere
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 09-Feb-2017 12:25:50


narginchk(5, inf);

p = inputParser;
p.addRequired('axh', @(x) isscalar(x) && ishandle(x) && strcmp(get(x, 'Type'), 'axes'));
p.addRequired('window', @(x) isscalar(x) && fix(x) == x && x > 0);
p.addRequired('noverlap', @(x) isscalar(x) && fix(x) == x && x > 0);
p.addRequired('nfft', @(x) isscalar(x) && fix(x) == x && x > 0 );
p.addRequired('newFs', @(x) isscalar(x) && x > 0);
p.addParameter('xy', zeros(0, 2), @(x) isrow(x) && numel(x) == 2);
p.addParameter('params', {}, @(x) iscell(x) && isrow(x) && rem(numel(x), 2) == 0);

p.parse(axh, window, noverlap, nfft, newFs, varargin{:});

xy = p.Results.xy;
params = p.Results.params;

if isempty(xy)
   x = 0.95;
   y = 0.95;
else
    x = xy(1);
    y = xy(2);

end


h = text(axh,x, y, ...
    sprintf(['window: %d\n',...
    'noverlap: %d\n',...
    'nfft: %d \n',...
    'newRate: %.1f Hz\n',...
    'frequencyRange: %.1f Hz ~ %.1f Hz\n', ...
    'frequencyResolution: %.1f Hz'],...
    window, ...
    noverlap,...
    nfft, ...
    newFs, ...
    0, newFs/2,...
    newFs/nfft),...
    'HorizontalAlignment', 'right', 'VerticalAlignment','top',...
    'Units', 'normalized',...
    params{:});


end