function kernel = prepGaussianKernel(sdfSigma, binsize)
% prepGaussianKernel returns a Gaussian kernel based on sdfSigma and
% binsize for creation of spike density function (SDF).
%
% SYNTAX
% kernel = prepGaussianKernel(sdfSigma, binsize)
%
% INPUT ARGUMENTS
% sdfSigma    scalar number 
%             sigma (standard deviation) for the Gaussian kernel in second.
%
%             if sdfSigma is too small, i.e. 
%
%               3* sdfSigma + sampling_interval < min(ISI)
%
%             where ISI stands for interspike interval, then there won't be
%             any overlap between adjacent bell shapes. So the sdfSigma
%             needs to be bigger than this. For examle, if you want 90% of
%             spike bell shapes overlapped, then you can use the following
%
%               sdfSigma =  (prctile(ISI,90) - sampling_interval)/3
%
%             to figure out what sdfSigma value you need. ISI here
%             represents a vector of inter spike intervals.
%
% binsize     bin width in second
%
% OUTPUT ARGUMENTS
% kernel      column vector
%             A Gaussian kernal to be used for creation of SDF. Ranging
%             from -3 * sdfSigma to 3 * sdfSigma (coverling 99.7%).
%
%             kernel satisfies sum(kernel*binsize) == 1 (approximately)
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
%
%             For more details about SDF, see Szucs A (1998) Applications
%             of the spike density function in analysis of neuronal firing
%             patterns. J Neurosci Methods 81:159-167.
%             http://www.ncbi.nlm.nih.gov/pubmed/9696321
%
%             Wallisch P, Lusignan ME, Benayoun MD, Baker TI, Dickey AS,
%             Hatsopoulos NG (2013) MATLAB for Neuroscientists: An
%             Introduction to Scientific Computing in MATLAB, 2nd ed.
%             Academic Press. pp. 319-320
%
%             Note that they did
%               
%               kernel = kernel*binsize; 
%
%             before convolution. But this does not satisfy
%             sum(kernel*binsize) == 1 anymore. Ther original kernel
%             represents probabilty distributions of a spike for bins, and
%             the value is dependent on bin size. and kernel*binsize
%             represents probability of a spike at a given time?
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 07-Nov-2019 15:54:55%
%
% See also
%
% See also
% getSDF, K_PSTHcorr

edges = (-3*sdfSigma : binsize : 3*sdfSigma)';
kernel = normpdf(edges, 0, sdfSigma);
% kernel = kernel / (sum(kernel_) * binsize); %NOTE a small (0.3%) adjustment (not essential)

% to set SDF [1/sec] as probability of spike events for a given period. The
% definite integral of an SDF gives you an estimate of the number of spike
% events during that period.

if isnan(kernel)
    kernel = []; % to avoid confusion related to NaN, such as length(NaN) == 1
end

end