function status = inspectThresholdOne(obj,m,ch)

chSp = obj.chanSpec;
W = chSp.constructChan(m,ch);
status = -1;

if isa(W,'WaveformChan')
    
    Whigh = obj.highpass(W);
    
    wh = which('findpeaks');
    if ~isempty(wh) && isempty(strfind(wh, fullfile('toolbox','signal','signal','findpeaks.m')))
        rmpath(fileparts(wh));
    end
    
    spkthre = std(Whigh)*obj.SDx;
    
    % warning off 'signal:findpeaks:largeMinPeakHeight'
    findpeaks(Whigh.Data,Whigh.SRate,'MinPeakHeight',spkthre);
    
    addpath(fileparts(wh));
    
    xlabel('Time (sec)')
    ylabel('Amplitude (mV)')
    zoom xon, pan xon;
    
    
    title(sprintf('Peaks: %s of %s',W.ChanTitle,chSp.MatNames{m}),...
        'interpreter','none')
    %warning on 'signal:findpeaks:largeMinPeakHeight'
    
    hold on
    plot(xlim,[spkthre spkthre],'Color',[0.5 0.5 0.5],'LineStyle','--',...
        'Tag','threshold')
    
    tickout = @(x) set(x,'TickDir','out','Box','off');
    tickout(gca)
    figh = gcf;
    status = 1;
    
else
    status = 1;
end
end