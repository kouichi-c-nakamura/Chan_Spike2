function [ax, res] = plotTriggered(rec,trigger,width_sec,offset_sec,histbin_sec,args)
%
% Record.plotTriggered is a method of Record class to plot event-triggered
% averages of channels of a Record object.
%
% SYNTAX
% [ax, res] = plotTriggered(rec,trigger,width_sec,offset_sec)
% [ax, res] = plotTriggered(rec,trigger,width_sec,offset_sec,histbin_sec)
%
% INPUT ARGUMENTS
% rec         a Record object
%
% trigger     A MetaEventChan object with the matching Start, Srate and
%             Length with obj, or a column vector of 0 and 1 for
%             trigger events, or a column vector of event time stamps
%
% window_sec  Window in seconds. Must be 0 or positive.
%
% offset_sec  Offset in seconds. Must be 0 or postive.
%
%
% OPTION
%
% histbin_sec Histgram bin in seconds. Default is 0.001 sec (1 msec)
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'WParams'   cell vector of char
%             (Optional) parameter/value pairs for WaveformChan.plotTriggered
%
% 'EParams'   cell vector of char
%             (Optional) parameter/value pairs for MetaEventChan.plotTriggered
%
% OUTPUT ARGUMENTS
% ax          axes objects
%
% res         cell
%             Column vector holding the computational results of each
%             channel.
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 01-Jun-2017 17:16:14
%
% See also
% WaveformChan.plotTriggered, EventChan.plotTriggered,
% MarkerChan.plotTriggered

arguments
    
    rec Record
    trigger {vf_trigger(trigger)}
    width_sec  (1,1) {mustBeReal}
    offset_sec (1,1) {mustBeReal}
    histbin_sec (1,1) {mustBeReal} = 0.001
    args.WParams (1, :) cell = {}
    args.EParams (1, :) cell = {}
    
end


n = length(rec.Chans);

fig = figure;
ax = gobjects(n,1);

for i = 1:n

    ax(i) = subplot(n,1,i);
end

res = cell(n,1);
for i = 1:n
    
    if isa(rec.Chans{i}, 'WaveformChan')
    
        res{i} = rec.Chans{i}.plotTriggered(ax(i),trigger,width_sec,offset_sec,args.WParams{:});
        
    elseif isa(rec.Chans{i}, 'MetaEventChan')
        
        res{i} = rec.Chans{i}.plotTriggered(ax(i),trigger,width_sec,offset_sec,histbin_sec,args.EParams{:});
        title(ax(i),rec.ChanTitles{i})
        
    else
        error('unexpected')

    end
    
    if i ~= n
        
        ax(i).XLabel.Visible = 'off';
        ax(i).XTickLabel = [];
        
    end

end

end


function vf_trigger(x)

% trigger     A MetaEventChan object with the matching Start, Srate and
%             Length with obj, or a column vector of 0 and 1 for
%             trigger events, or a column vector of event time stamps

assert((isa(x,'MetaEventChan') && isscalar(x)) ...
    || vf0or1(x) || vftimestamps(x));


end






