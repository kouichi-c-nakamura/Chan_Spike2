function [sdf, kernel] = getSDF(event,varargin)
% getSDF returns spike density function (SDF) from spike event
%
% [sdf, kernel] = getSDF(event)
% [sdf, kernel] = getSDF(event,Fs)
% [sdf, kernel] = getSDF(_____, 'Parameter',Value)
%
%
% INPUT ARGUMENTS
% event       MetaEventChan object | column vector of 0 and 1
%             Data holding events (1 for event)
%
%
% Fs          (Optional) Sampling frequency
%             Ignored if event is a MetaEventChan object.
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'sdfSigma'  (default) 0.015 [sec]
%             Sigma of normal distribution for kernel of convolution
%
%             If (sdfSigma*3 + 1/Fs) is shprter than all the ISIs, there
%             won't be any overlap of gaussian bell shapes, and SDF values
%             are virtually pointless.
%
%             For example, if you want to set sdfSigma to have 95% of ISIs
%             overlapped, then you can use
%        
%               sdfSigma = (prctile(ISI,95) - 1/Fs)/3
%
%             where ISI is a vector of all the inter-spike intervals.
%
% 'shape'     'valid' | 'same' (default)
%             shape option for builtin conv function. 'valid' will return
%             sdf with NaNs at a few points at the both ends, whereas
%             'same' will return sdf without NaN but with estimates
%             at the both ends
% 
% OUTPUT ARGUMENTS
% sdf         WavefromChan | column vector of waveform
%             Spike density function (SDF) in the unit of [1/sec]. Data
%             format is dependent on the data format of event. If event is
%             MetaEventChan, then sdf is a WavefromChan object. If event is
%             a column vector, then sdf is the column vector of the same
%             size.
%
%             In the original paper, SDF is defined as a spike is convluted
%             with a Gausian kernal so that the definite integral of a bell
%             shape for a spike equals to 1. 
%
%             sum(kernel)*binsize == 1
%
%             SDF peak values are independent of binsize (sampling
%             interval), but is inversely proportinal to the sdfSigma; the
%             larger the sigma is, the lower SDF peaks become because the
%             probability density is more wide spread. So SDF values are
%             arbitorary, in that it depens on arbitorary parameter of
%             sdfSigma. 
%
%             Thus, it is not easy to directly compare standard
%             firing rates (spikes/second), which also are dependent on an
%             aribitorary parameter of bin size (time window).
%
%             For more details about SDF, see Szucs A (1998) Applications
%             of the spike density function in analysis of neuronal firing
%             patterns. J Neurosci Methods 81:159-167.
%             http://www.ncbi.nlm.nih.gov/pubmed/9696321
%             doi:10.1016/S0165-0270(98)00033-8
%
%             Wallisch P, Lusignan ME, Benayoun MD, Baker TI, Dickey AS,
%             Hatsopoulos NG (2013) MATLAB for Neuroscientists: An
%             Introduction to Scientific Computing in MATLAB, 2nd ed.
%             Academic Press. pp. 319-320
%
% kernel      rowvector
%             The Gaussian kernel for SDF spanning from -3*sdfSigma to
%             3*sdfSigma (covering 99.7% of probability).
%
% See also
% K_PSTHcorr.plotSDF, conv, normpdf
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 10-Aug-2016 11:06:05

narginchk(1,inf)
p = inputParser;
p.addRequired('event',@(x) (iscolumn(x) && all(x == 0 | x == 1)) ...
    || isa(x,'MetaEventChan'));
p.addOptional('Fs',1);
p.addParameter('sdfSigma',0.015,@(x) isscalar(x) && x >= 0);
p.addParameter('shape','same',@(x) ismember(x,{'same','valid'}));
p.parse(event,varargin{:});


sdfSigma = p.Results.sdfSigma;
shape = p.Results.shape;

%%

if isa(event,'MetaEventChan')
    Is = event.SInterval;
    data = event.Data;
else
    Fs = p.Results.Fs;
    Is = 1/Fs;
    data = event;
end

kernel = prepGaussianKernel(sdfSigma, Is);

sdfdata = NaN(size(data));

gap = fix((length(kernel) - 1)/2); % points for one side where convolution is not valid
% if length(kernel) is odd, gap is equal for both sides
% if length(kernel) is even, gap of the lest is shorter by 1 than that of the right

convlen = size(data, 1) - length(kernel) + 1; % see help for 'conv' with 'valid' option

switch shape
    case 'valid'
        sdfdata(gap+1 :gap + convlen)  = conv(data, kernel, 'valid');
    case 'same'
        sdfdata = conv(data, kernel, 'same');
end

if isa(event,'MetaEventChan')
    sdf = WaveformChan;
    sdf.ChanTitle = event.ChanTitle;
    sdf.Start = event.Start;
    sdf.SRate = event.SRate;
    sdf.Data = sdfdata;
    sdf.DataUnit = '1/sec';
else
    sdf = sdfdata;
end

end
