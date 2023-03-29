function out = plotISIhist(obj, maxInterval, binsize, minInterval, varargin)
%out = plotISIhist(obj, maxInterval, binsize, minInterval, varargin)
%
%% input arguments
% target ...             a logical or binary column vector for spikes
%                        NaN is not supported.
% sInterval              the sampling interval [sec] for both target and trigger
% width ...              in sec
% binsize ...            in sec
% minISIshown ...        in sec (works as an offset to set the left end of the X axis)
%
%% OPTIONAL PARAMETER/VAlUE pairs (varargin)
% 'TargetTitle'         any string
% 'PlotType'            'line'   line drawing for PSTH/correlogram
%                       'hist'   histogram for PSTH/correlogram
% 'Unit'                's'      x axis in second (default)
%                       'ms'     x axis in msec

out = K_ISIhist(obj.Data, obj.SInterval, maxInterval, binsize, minInterval, varargin);
end