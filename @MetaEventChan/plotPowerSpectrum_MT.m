function [h,out] = plotPowerSpectrum_MT(obj,varargin)
% 
% plotPowerSpectrum_MT draws multi-taper power spectrum with mtspectrumpb
% of Chronux toolbox 2.10.
%
% plotPowerSpectrum_MT(obj,varargin)
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'PlotType'  'line'   (Default) line drawing
%             'none'   no plot produced and only returns out and empty h.
%
% 'Fs'        (default) 1024
%             (Optional) new sampling rate
%
% 'fpass'     (default) [0.1 500]
%             (Optional) frequency range to be calculated
%
% 'pad'       (default) 0
%             (Optional) -1 corresponds to no padding, 0 corresponds to
%             padding to the next highest power of 2 etc.
%
% 'err'       (default) [2, 0.05]
%             (Optional) [1 p] - Theoretical error bars 
%             [2 p] - Jackknife error bars
%             [0 p] or 0 - no error bars 
%             Default 0.
%
% 'tapers'    (default) [3, 5]
%
%             (Optional) in Hz. Specifies params.tapers = [T, W, p] or [NW,
%             K] for mtspectrumpb.
%             
%             In two parameters form, 
%
%             NW is time-bandwidth product, where W defines the frequency
%             range that you can accept as the maximum spectral leakage (in
%             inverse of data points or possibly in Hz), and N as the
%             number of datapoints for window functions.
% 
%             K is the number of tapers to be used. 2*NW - k == 1 must be met. 
%
%
%             In three parameters form,
%
%             T is the width of window functions (in second).
%
%             W defines the frequency range that you can accept as the
%             maximum spectral leakage (in Hz)
%         
%             p is a positive integer. K = 2*TW -p defines the number of
%             tapers and must be a positive integer.
%
%
% 'refRange'  (default) [0.25, 100]
%             (Optional) frequency range to be used as the reference in
%             normalization
%
% 'smoothHz'  (default) 1 | positive number | 0
%             Uses Y = smooth(y,span) where span is a datapoints
%             corresponding to frequency range smoothHz (by round)
%             0 is for no smoothing. 1 (Hz) is recommended.
%
%
% OUTPUT ARGUMENTS
% h           handle for line objects
%
% out          A strucut with power spectram data
%                     out.params   Parameters
%                     out.mtS      Multitaper power spectra
%                     out.mtf      Frequency axis
%                     out.span     Smoothing window
%                     out.Y        Normalized, smoothed power spectra
%
%
%
% See also
% WaveformChan.plotPowerSpectrum, mtspectrumpb, normalizepower

narginchk(1,inf)
p = inputParser;
vf1x2 = @(x) isrow(x) && all(x >= 0) && numel(x) == 2;
vf1x1 = @(x) isscalar(x) && x > 0;


p.addRequired('obj')
p.addOptional('axh',[],@(x) ishandle(x) && strcmpi(x.Type,'axes'));
p.addParameter('Fs',1024, @(x) isempty(x) || isscalar(x) && x > 0);
p.addParameter('fpass',[0.1 500], vf1x2);
p.addParameter('pad',0);
p.addParameter('err',[2,0.05],vf1x2);
p.addParameter('trialave',0);
p.addParameter('tapers',[3, 5],@vftapers);
p.addParameter('refRange',[0.25, 100],vf1x2);
p.addParameter('smoothHz',1,@(x) isscalar(x) && x >= 0);
p.addParameter('PlotType','line',@(x) ismember(x,{'line','none'}));


p.parse(obj,varargin{:});

%% Job
axh = p.Results.axh;

params.Fs       = p.Results.Fs;
if isempty(params.Fs)
    params.Fs = obj.SRate;
    obj2 = obj;
else
    obj2 = obj.resample(params.Fs,'ignore');
end

params.fpass    = p.Results.fpass;
params.pad      = p.Results.pad;
params.err      = p.Results.err;
params.trialave = p.Results.trialave;
refRange        = p.Results.refRange;
params.tapers   = p.Results.tapers; % default [50, 1, 1]
smoothHz        = p.Results.smoothHz;

plotType        = lower(p.Results.PlotType);

%%
[mtS, mtf] = mtspectrumpb(obj2.Data, params);

Y = normalizepower(mtS,mtf,refRange(1),refRange(2))*100;

if smoothHz > 0
    
   span = round(length(Y)/max(mtf)*smoothHz); 
   Y = smooth(Y,span);
    
end

out.params = params;
out.mtS    = mtS;
out.mtf    = mtf;
out.span   = span;
out.Y      = Y;

switch plotType
    case 'line'
        if isempty(axh)
            figure
            axh = axes;
        end
        
        h = line(axh,mtf,Y);
        xlabel('Frequency (Hz)')
        ylabel('Relative power (%)')
        title(sprintf('%s: tapers = [%s]',...
            obj.ChanTitle,num2str(params.tapers)));
        a = gca;
        a.TickDir = 'out';
        a.Box = 'off';
        xlim([0 100]);
    case 'none'
        h = [];
end

end

function tf = vftapers(x)

tf = false;

if isempty(x)
    return
end

if isrow(x)
    switch numel(x)
        case 2
            assert(x(2) == x(1)*2-1);
            assert(fix(x(2)) == x(2),'[NW, K] must satisfy that K = 2*NW -1 where K is a positive integer.');
            assert(x(2) > 0);
            
            tf = true;
        case 3
            assert(x(1) > 0 );
            assert(x(2) > 0 );            
            assert(fix(x(3)) == x(3));
            
            K = 2*x(1)*x(2) -p;
            assert(fix(K) == K,'[W, T, p] must satisfy that K = 2*TW -p where K is a positive integer.');
            
            tf = true;
        otherwise
            
    end
end



end

