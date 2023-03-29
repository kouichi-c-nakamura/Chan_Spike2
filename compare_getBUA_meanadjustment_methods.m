function [h,spikewindow,width_ms,spiketimes,name,Tbandpass] = ...
    compare_getBUA_meanadjustment_methods(chanSpec,m,ch,varargin)
% compare_getBUA_mean adjustment_methods is a utility function that helps
% you confirm the effect of meanadjustment method in getBUA function.
% By specifying a data file, you get a time view and triggered-average
% waveforms for four different mean adjustment methods as well as standarad
% FWR BUA signal without mean adjustment.
%
% [h,spikewindow,width_ms,spiketimes,name,Tbandpass] = ...
%     compare_getBUA_meanadjustment_methods(chanSpec,m,ch)
%
%
% INPUT ARGUMENTS
% chanSpec    A ChanSpecifier object
%
% m           positive integer
%             Index number for a mat file in chanSpec
%
% ch          positive integer
%             Index number for a channel in matfile m in chanSpec
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'spikeWin'  [before_ms, after_ms]
%             (Optional) non-negative values in msec for spike removal
%             window. If not specified (default), stored values in the
%             BUAparameters.mat file will be used.
%
% OUTPUT ARGUMENTS
% h           structure of graphic handles
%
% spikewindow equals to pikeWin
%
% width_ms    Actual duration of spike removal window
%
% spiketimes  Time stamps for spikes
%
% name        Structure for name of data file analyzed
%             name.parentdir
%             name.matname
%             name.chantitle
%
% Tbandpass   Table for bandpass filter information
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 23-Jun-2016 11:56:15
%
% See also
% getBUA_meanadjustment_comparisons_script,
% WaveformChan.getBUA, getBUAparams,


p = inputParser;
p.addRequired('chanSpec',@(x) isa(x,'ChanSpecifier'));
p.addRequired('m', @(x) isscalar(x) && fix(x) ==x && x > 0);
p.addRequired('ch',@(x) isscalar(x) && fix(x) ==x && x > 0);
p.addParameter('spikeWin',[],@(x) isrow(x) && numel(2) && all(x >= 0));
p.addParameter('plotTime','on',@(x) ismember(x,{'on','off'}));
p.addParameter('plotTriggered','on',@(x) ismember(x,{'on','off'}));
p.addParameter('plotBandpass','on',@(x) ismember(x,{'on','off'}));
p.addParameter('plotWinOverlap','on',@(x) ismember(x,{'on','off'}));

p.parse(chanSpec,m,ch,varargin{:});

spikewindow    = p.Results.spikeWin;
plotTime       = p.Results.plotTime;
plotTriggered  = p.Results.plotTriggered;
plotBandpass   = p.Results.plotBandpass;
plotWinOverlap = p.Results.plotWinOverlap;



[basedir,~,~,~,resdir] = setup();


buaparams = BUAparameters(chanSpec,resdir,basedir);

W = chanSpec.constructChan(m,ch);

spkthre = buaparams.getThre(W);

if isempty(spikewindow)
    spikewindow = buaparams.getSpikeWin(m,ch);
end

[fwrbuaLD,~,fwrbua,bua,fwrbuanan,spiketimes,~,width_ms,...
    spikewindow2,indRep,~] = getBUA(W,'wideband thresholding',3,spkthre,...
    'meanadjustment','off','spikewindow',spikewindow);

assert(isequal(spikewindow,spikewindow2))

befp = round(W.SRate/1000*spikewindow(1));
aftp = round(W.SRate/1000*spikewindow(2));

[~,~,~,~,~,data] = fwrbua.plotTriggered(spiketimes,0.03,0.015,...
    'Average','off','Overdraw','off','ErrorBar','off');
xdata = data.t;
ydata = data.mean;

[~,~,~,~,~,datanan] = fwrbuanan.plotTriggered(spiketimes,0.2,0.1,...
    'Average','off','Overdraw','off','ErrorBar','off');



spikeEvent = timestamps2binned(spiketimes,W.Start,W.MaxTime,W.SRate,'ignore');

thisdir = pwd;

choice = {'global','local','localavoidneighbour'}; %NOTE this order is important
choicePlus = [choice,{'off'}];
J = length(choice);

fwrbuaadj = cell(J,1);
if 1 % To access private functions
    cd(fullfile(fileparts(which('WaveformChan')),'private'))
    
    % plotReplacementsVsSurrounds(fwrbua,indRep);
    
    fwrbuaadj{1} = getBUA_meanAdjustGlobal1(fwrbua,indRep,befp,aftp,xdata,ydata);
        
    fwrbuaadj{2} = getBUA_meanAdjustLocal(fwrbua,indRep);
        
    fwrbuaadj{3} = getBUA_meanAdjustLocal_avoidAdjacentSpikes(fwrbua,indRep);
    
    cd(thisdir)
end

matname   = chanSpec.MatNames{m};
chantitle = chanSpec.ChanTitles{m}{ch};
parentdir = chanSpec.ParentDir{m};

name.parentdir = parentdir;
name.chantitle = chantitle;
name.matname   = matname;


SD = std(fwrbua);
titlestr = sprintf('%s\n[%.1f, %.1f], SD %.6f mV',[matname,' | ',chantitle],...
    spikewindow(1),spikewindow(2),SD);
h.figure_timeview = gobjects;
h.figure_triggered = gobjects;
h.figure_bandpass = gobjects;


root       = groot;
screensize = root.ScreenSize;
width      = 560;
height     = 600;

Tbandpass = [];

%%

if strcmpi(plotWinOverlap,'on')
    datananseg = squeeze(datanan.segment);
    repCounts = arrayfun(@(x) nnz(isnan(datananseg(x,:))), 1:size(datananseg,1));
    figure;
    plot(datanan.t,repCounts/length(spiketimes)*100,'DisplayName','Counts of replacements');
    a = gca;
    a.TickDir = 'out';
    a.Box = 'off';
    xlabel('Time relative to events (msec)')
    ylabel('% Overlapped windows')
    title(titlestr,'Interpreter','none');

end

%% Time View
if strcmpi(plotTime,'on')
        
    rec = Record({fwrbua});
    H = rec.plot;
    clear a
    linhA(J+1) = findobj(H.axh,'Type','line');
    linhA(J+1).Color = 'J';
    linhA(J+1).DisplayName = 'FWR BUA without adjustment';
    
    
    for j = 1:J
        tfRep = false(fwrbua.Length,1);
        tfRep(indRep) = true;
        
        w = fwrbuaadj{j};
        thisdata = w.Data;
        thisdata(~tfRep) = NaN; % mask
        w.Data = thisdata;
        clear thisdata
        
        h1 = w.plot(H.axh);
        linhA(j) = h1.l1;
        linhA(j).DisplayName = choice{j};
        linhA(j).Color = defaultPlotColors(j);
        clear w
    end
    linhA(2).LineStyle = '--';
      
%     linhA(7) = line([fwrbua.Start,fwrbua.MaxTime],[SD,SD],'Color',[0.5 0.5 0.5],...
%         'DisplayName','SD');
    
    leg = legend(linhA);
    leg.Box ='off';
    leg.Location = 'southoutside';
    
    h.figure_timeview = gcf;
    h.figure_timeview.Position = [screensize(3)/2-width/2,screensize(4)/2-height/2,width,height];
    
    h.axes_timeview = findobj(h.figure_timeview,'Type','axes');
    h.axes_timeview.Units = 'pixels';
    h.axes_timeview.Position = [57 234.48 492.8 300];
    
    h.figure_timeview.Name = ['time: ',matname,'|',chantitle];
    
    title(titlestr,'Interpreter','none');
    
end

%% Triggered average

if strcmpi(plotTriggered,'on')
    linhB = gobjects(J+1,1);
    
    h.axes_triggered = fwrbua.plotTriggered(spiketimes,0.03,0.015,...
        'overdraw','off');
    linhB(J+1) = findobj(h.axes_triggered,'Type','line');
    linhB(J+1).DisplayName = 'FWR BUA';
    linhB(J+1).Color ='k';
    
    for j = 1:J
        w = fwrbuaadj{j};
        [~,linhB(j)] = w.plotTriggered(h.axes_triggered,spiketimes,0.03,0.015,...
            'overdraw','off','AverageColor',defaultPlotColors(j));
        clear w
        linhB(j).DisplayName = choice{j};
    end
    linhB(2).LineStyle = '--';
    
%     linhB(7) = line([-15,15],[SD,SD],'Color',[0.5 0.5 0.5],...
%         'DisplayName','SD');
    
    % vertical bars
    ylim('auto')
    ylimvalB = ylim;
    bar1B = line([-spikewindow(1),-spikewindow(1)],ylimvalB,'Color',[0.5 0.5 0.5],...
        'LineStyle','--');
    bar2B = line([spikewindow(2),spikewindow(2)],ylimvalB,'Color',[0.5 0.5 0.5],...
        'LineStyle','--');
    ylim(ylimvalB)
    
    
    leg2 = legend(linhB);
    leg2.Box = 'off';
    leg2.Location = 'southoutside';
    
    
    h.figure_triggered = gcf;
    h.figure_triggered.Position = [screensize(3)/2-width/2,screensize(4)/2-height/2,width,height];
    h.axes_triggered.Units = 'pixels';
    h.axes_triggered.Position = [57 234.48 492.8 300];
    
    
    h.figure_triggered.Name = ['triggered: ',matname,'|',chantitle];
    title(titlestr,'Interpreter','none');
    h.figure_triggered = gcf;
end

%% Bandpass filter
% 
% 
% 
% See also
% Hirai_BUA_group_triggeredAverage

if strcmpi(plotBandpass,'on')

    fwrbuaLDadj = cell(J,1);
    
    for j = 1:J
        fwrbuaLDadj{j} = getBUA(W,'wideband thresholding',3,spkthre,...
            'spikewindow',spikewindow,...
            'meanadjustment',choice{j});
    end
    
    va = @(x)matlab.lang.makeValidName(x); %Note escape name 'global'
    varnames = [{'Hz','Wn','n','b','a'},va(choicePlus)];
    bands = {'slow','theta','alpha','beta','low_gamma','high_gamma','unfiltered_BUA'};
    
    I = length(bands);
    C = repmat({cell(I,1)},1,J+1);
    T = table(zeros(I,2),zeros(I,2),zeros(I,1),cell(I,1),cell(I,1),...
        C{:},...
        'VariableNames',varnames,'RowNames',bands);
    clear C
    
    T.n = [1;1;2;2;5;5;0];
    Hz = [0.4,1.6;...
        4,8;...
        8,12;...
        13,30;...
        30,80;...
        80,150;...
        NaN,NaN];
    T.Hz = Hz;
    Fs = fwrbuaLD.SRate;
    
    trig = timestamps2binned(spiketimes,fwrbuaLD.Start,fwrbuaLD.MaxTime,fwrbuaLD.SRate,'ignore');

    dbstop if warning
    for j = 1:J+1 % methods
        fmean = cell(J,1);
        for i = 1:I % bandpass
            
            if i < I
                Wn = normalizedfreq(T.Hz(i,1:2),Fs);
                T.Wn(i,:) = Wn;
                n = T.n(i);
                [b,a]= butter(n,Wn,'bandpass');
                
                assert(isstable(b,a),'unstable for i = %d, j = %d',i,j)
                T.b{i} = b;
                T.a{i} = a;
                if j <= J
                    filtered = filtfilt(b,a,fwrbuaLDadj{j}.Data);
                else
                    filtered = filtfilt(b,a,fwrbuaLD.Data);
                end
                
            else % unfiltered signal
                if j <= J
                    filtered = fwrbuaLDadj{j}.Data;
                else
                    filtered = fwrbuaLD.Data;
                end
            end
            
            [t,fmean{i}] = eventTriggeredAverage(filtered, trig, Fs, 0.2, 0.1);
        end
        T{:,j+5} = fmean;
        
    end
    dbclear if warning
    
    %% 6 figures to plot
    
    figh   = gobjects(J+1,1);
    axh    = gobjects(J+1,3);%TODO
    linh   = gobjects(J+1,I);
    leg3   = gobjects(J+1,1);
    ylims1 = zeros(J+1,2);
    ylims2 = zeros(J+1,2);
    
    
    for j = 1:J+1 % methods
        figh(j) = figure;
        
        axh(j,1:2) = plotyygeneral({},{'YColor','k'});
        
        for i = 1:I-1
            linh(j,i) = line(axh(j,1),t,T.(va(choicePlus{j})){i},...
                'Color',defaultPlotColors(i),'DisplayName',bands{i});
        end
        
        linh(j,I) = line(axh(j,2),t,T.(va(choicePlus{j})){I},'DisplayName',bands{I});
        linh(j,I).Color = 'k';
        
        title(sprintf('%s\n%s',[matname,'|',chantitle],choicePlus{j}),...
            'Interpreter','none')
        set(axh(j,1:2),'Position',[0.13 0.11 0.775 0.75])
        ylims1(j,:) = ylim(axh(j,1));
        ylims2(j,:) = ylim(axh(j,2));
        ylabel(axh(j,1),'Bandpass-filtered (mV)')
        ylabel(axh(j,2),'BUA signal (mV)')
        xlabel(axh(j,1),'Time relarive to events (sec)');
        
    end
    
    
    axh1ylim = [min(ylims1(:,1)), max(ylims1(:,2))];
    set(axh(:,1),'YLim',axh1ylim);
    
    axh2ylim = [min(ylims2(:,1)), max(ylims2(:,2))];
    set(axh(:,2),'YLim',axh2ylim);
    
    for j = 1:J+1
        figure(figh(j));
        leg3(j) = legend(linh(j,:));
        set(leg3(j),'Box','off','Location', 'southoutside','Interpreter','none');

        
        axh(j,3) = axes('Position',axh(j,2).Position,'Visible','off');
        linkaxes(axh(j,:),'x');
        xlim([-0.1  0.1])

        bar1C = line(axh(j,3),[-spikewindow(1),-spikewindow(1)]/1000,[0 1],...
            'Color',[0.5 0.5 0.5],...
            'LineStyle',':','Visible','on');
        bar2C = line(axh(j,3),[spikewindow(2),  spikewindow(2)]/1000,[0 1],...
            'Color',[0.5 0.5 0.5],...
            'LineStyle',':','Visible','on');
        
       
    end
        
    set(figh,'Position',[screensize(3)/2-width/2,screensize(4)/2-height/2,width,height]);
    
    
    h.figure_bandpass = figh;
    Tbandpass = T;
end


end

