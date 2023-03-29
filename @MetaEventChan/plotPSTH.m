function out = plotPSTH(obj, trigger, width, binsize, offset, varargin)
%  out = plotPSTH(obj, trigger, width, binsize, offset, varargin)
%
%% input arguments
% mode ....              must be 'psth', 'crosscorr', or 'autocorr'
% target ...             a logical or binary column vector for spikes
%                        NaN is not supported.
% trigger ...            a logical or binary column vector for trigger event (the same length as target)
%                        NaN is not supported.
% width ...              in sec
% binsize ...            in sec
% offset ...             in sec
%
%
%% OPTIONAL PARAMETER/VAlUE pairs (varargin)
% 'TargetTitle'         any string
% 'TtriggerTitle'       any string
% 'PlotType'                'line'   line drawing for PSTH/correlogram
%                       'hist'   histogram for PSTH/correlogram
% 'Yaxis'               'count'  counts as Y axis
%                       'rate'   firing rate as Y axis
% 'Unit'                's'      x axis in second (default)
%                       'ms'     x axis in msec
% 'ErrorBar'            'none'   (default)
%                       'std'    error bar as STD (ignored if Yaxis is 'count')
%                       'sem'    error bar as SEM (ignored if Yaxis is 'count')
% 'Raster'              'none'   (default)
%                       'dot'    raster plot with dots
%                       'line'   raster plot with vertical lines
% 'RasterY    '         'sweeps' sweeps as Y of raster (default)
%                       'time'   time as Y axis of raster
%
%% output arguments
% sweepn, fig1, ax1, l1, er1, ax2, rasterh
% handles for graphic objects

p = inputParser;
vf = @(x) isa(x, 'MetaEventChan');
addRequired(p, 'trigger', vf);
parse(p, trigger);

mode = 'psth';
out = K_PSTHcorr(mode, obj.Data, trigger.Data, obj.SInterval, width, binsize, offset, varargin{:});
end