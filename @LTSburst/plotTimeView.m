function h = plotTimeView(obj, varargin)
%
% h = plotTimeView(obj)
% h = plotTimeView(obj, k)
%
% k      process k th data (record). A vector of indices that
%        specifies record.
%        By default plot all the data.
%
% %TODO maybe it's better to create a rew Record object and plot it
% Only exception is "LTS" channel that is in Level channel type and not
% supported by Chan class
%

p = inputParser;
p.addRequired('obj');
p.addOptional('k', [], @(x) isvector(x) && all(x <= length(obj.SpikeInfo)) && ...
    all(x >= 0) );

p.parse(obj, varargin{:});

k = p.Results.k;

[burstMax, ~, onsetLTS_i_spikes] = pvt_getBurstmax(obj);

if isempty(k)
    
    k = 1:length(obj.SpikeInfo);
    
end



varnames = {'fig','axh','spikeInfo','LTS','onset','onsetNspikes'};
h = cell2table(cell(length(k),length(varnames)),'VariableNames',varnames);
h.fig = gobjects(length(k),1);
h.axh = gobjects(length(k),1);


for K = 1:length(k)
    
    spikeInfo = obj.SpikeInfo{k(K)};
    starttime = obj.StartTime(k(K));
    maxtime = obj.MaxTime(k(K));
    onsetInfo = obj.OnsetInfo{k(K)}; % indices for spikeInfo?
    offsetInfo = obj.OffsetInfo{k(K)};
    burstmax = burstMax(k(K));
        
    h.fig(K) = figure;
    h.axh(K) = axes;
    set(h.axh(K), 'TickDir', 'out');
    zoom xon
    pan xon
    xlabel('Time (sec)');
    yticklabel = cell(1, 10);
    
    
    %% unite

    len = size(spikeInfo,1);
    t = spikeInfo.time';
    h.spikeInfo{K} = line([t;t],repmat([0;1],1,len),'Color','k');
    h.spikeInfo{K}(len+1) = line([starttime,maxtime], [0.5 0.5], 'Color','k');
    clear len t
    
    yticklabel{1} = 'Spike';
    
    %% LTS
    hold on
    
    len = size(onsetInfo,1);
    ton = onsetInfo.time';
    toff = offsetInfo.time';

    h.LTS{K}=fill([ton;toff;toff;ton],repmat([2;2;3;3],1,len),'k');
    
    hold off
    zoom xon
    pan xon
    yticklabel{2} = 'LTS';
    clear len t

    
    %% onset
    
    len = size(onsetInfo,1);
    t = onsetInfo.time';
    h.onset{K} = line([t;t],repmat([4;5],1,len),'Color','k');

    h.LTS{K}(len+1) = line([starttime maxtime], [4.5 4.5], 'Color','k');
    yticklabel{3} = 'Onset';
    clear len t

    
    %% onset of bursts with n spikes
    
    c = 0;
    if isnan(burstmax)
        h.onsetNspikes{K} = [];

    else

        h.onsetNspikes{K} = cell(burstmax+1, 1);
        for i = 2:burstmax % burst size
            
            if ~isempty(onsetLTS_i_spikes{k(K)}{i})
                c = c+1;
                
                for j = 1:length(onsetLTS_i_spikes{k(K)}{i})
                    
                    thistime = spikeInfo.time(onsetLTS_i_spikes{k(K)}{i}(j));
                    
                    h.onsetNspikes{K}{i} = line(...
                        [thistime, thistime],...
                        [4+2*c, 5+2*c], 'Color','k');
                    
                end
                h.onsetNspikes{K}{burstmax +1, 1} = line([starttime maxtime], ...
                    [(4.5 +2*c), (4.5 +2*c)], 'Color','k');
                yticklabel{3+c} = ['Onset ', num2str(i), ' spikes'];
                
            end
        end
 
    end
    top = (4.5 +2*c);

    ylim([-0.5 top+1]);
    set(h.axh(K), 'YTick',0.5:2:top+1);
    set(h.axh(K), 'YTickLabel', yticklabel);
    xlim([starttime maxtime]);
    title(obj.Names{k(K)},'Interpreter', 'none');
    
end

end



