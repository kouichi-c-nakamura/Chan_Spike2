function [objout,spikeWin,status,figh] = averagewaveformOne(obj,m,ch,varargin)
%
%
% status       -1 cancelled
%              0 no change
%              1 changed
%              2 pending change (before acception) only internally used
%              3 initial state only internally used

p = inputParser;

vfintpos = @(x) isscalar(x) && fix(x) == x && x > 0;
p.addRequired('obj');
p.addRequired('m', vfintpos);
p.addRequired('ch',vfintpos);
p.addParameter('call','one',@(x) ismember(x,{'one','batch'}));

p.parse(obj,m,ch,varargin{:});

call = p.Results.call;

%% Job


chSp = obj.chanSpec;
W = chSp.constructChan(m,ch);

vfval = @(x) isscalar(x) && isreal(x) && x >= 0 && x < 100;

if isa(W,'WaveformChan')
    
    Whigh = obj.highpass(W);
    spkthre = std(Whigh)*obj.SDx;
    

    %% Read the table
    spikeWin = getSpikeWin(obj,m,ch); %NOTE important
    
    if isempty(spikeWin)
        spikeWin = obj.SpikeWindefault;
    end
    
    WhighFWR = Whigh;
    WhighFWR.Data = abs(Whigh.Data) - mean(Whigh.Data); % signal just before spike removal
    %NOTE technically getBUA does rectification after spike removal, so the
    % mean subtraction will result in slightly different value. So Y value
    % might be slightly different, although waveform itself is identical.
    
    figh = figure;

    status = 3;
    while status >= 2
        
        %% plots
        clf
        axh = plotyygeneral;
        set(axh,'Position',[0.13 0.11 0.74 0.815]);
        axh(1).XTick = [-10:10];
        axh(1).XGrid = 'on';

        % recompute
        [~,~,fwrbua,~,~,spiketimes,~,~] = W.getBUA(...
            'wideband thresholding',obj.order,spkthre,'spikewindow',spikeWin);

        [~,h_meanbua,h_errbua] = fwrbua.plotTriggered(axh(1),spiketimes,0.02,0.01,...
            'OverDraw','off','ErrorBar','std');
        h_meanbua.Tag = 'FWR BUA average';
        xlim(axh(1),[-5,5])
        ylabel(axh(1),'Amplitude of FWR BUA (mV)')
        axh(1).YColor = 'r';
        
        
        [~,h_meanfwr] = WhighFWR.plotTriggered(axh(2),spiketimes,0.02,0.01,...
            'OverDraw','off','ErrorBar','off','AverageColor',defaultPlotColors(1));
        h_meanfwr.Tag = 'FWR average';
        
        [~,h_meanorig] = W.plotTriggered(axh(2),spiketimes,0.02,0.01,...
            'OverDraw','off','ErrorBar','off','AverageColor',defaultPlotColors(5));
        h_meanorig.LineStyle = '-.';
        h_meanfwr.Tag = 'original average';
        
        axh(2).YColor = axh(2).XColor;
        

        legend([h_meanbua,h_meanorig,h_meanfwr],{'FWR BUA','Original','FWR'});
        
        
        title(axh(1),sprintf('%s in %s',W.ChanTitle,chSp.MatNames{m}),'Interpreter','none');
        title(axh(2),'');
        
        ylimval = ylim(axh(2));
        
        bar1 = line(axh(2),[-spikeWin(1),-spikeWin(1)],ylimval,...
            'Color',h_meanbua.Color,'LineStyle','-','Tag','before');
        
        bar2 = line(axh(2),[spikeWin(2),spikeWin(2)],ylimval,...
            'Color',h_meanbua.Color,'LineStyle','-','Tag','after');

        ylim(axh(2),ylimval)
        
        
        hbar = line(axh(2),[-10,10],[spkthre,spkthre],'Color',defaultPlotColors(5),...
            'Tag','threshold');
        hbar.LineStyle = '-';
        
        % show number of spiketimes
        htxt = text(axh(2),0.95,0.05,sprintf('%d spikes to be removed',length(spiketimes)),...
            'Unit','normalized','HorizontalAlignment','right','Color',h_meanbua.Color);
        
        
        btnDebug = uicontrol('style','pushbutton','position',[0,0,50,20],...
            'string','Debug','Callback',@runkeyboard);
        
        btnXlim10 = uicontrol('style','pushbutton','position',[50,0,50,20],...
            'string','[-10 10]','Callback','xlim([-10 10])');
        
        btnXlim5 = uicontrol('style','pushbutton','position',[100,0,50,20],...
            'string','[-5 5]','Callback','xlim([-5 5])');
        
        btnOpenT = uicontrol('style','pushbutton','position',[0,20,80,20],...
            'string','Open Table','Callback',@openT);

        
        switch status
            case 2 % update waiting for confrimation
                button = questdlg('Accept, retry or debug?','Confirmation','OK','Retry','Abort','OK');
                switch button
                    case 'OK'
                        status = 1;
                        break
                    case 'Retry'
                        status = 3;
                        continue
                    case 'Abort'
                        disp('Cancelled')
                        status = -1;
                        break
                end
                
            otherwise
                
                %% Dialog
                % NOTE break, continue etc do not allow refactoring into local function
                
                options.WindowStyle = 'normal';
                answer = inputdlg({'before (msec) [0-100]','after (msec) [0-100]'},...
                    'Set size',1,...
                    {num2str(spikeWin(1)),num2str(spikeWin(2))},options);
                
                if isempty(answer)
                    % cancelled
                    status = -1;
                    break % while
                else
                    [val1, str2num_status] = str2num(answer{1}); %#ok<ST2NM>
                    val1 = round(val1*10)/10; % to one place of decimal
                    if ~str2num_status
                        % Handle empty value returned
                        % for unsuccessful conversion
                        % ...
                        continue
                    end
                    
                    [val2, str2num_status] = str2num(answer{2}); %#ok<ST2NM>
                    val2 = round(val2*10)/10; % to one place of decimal
                    if ~str2num_status
                        % Handle empty value returned
                        % for unsuccessful conversion
                        % ...
                        continue
                    end
                    
                    if vfval(val1) && vfval(val2)
                        if spikeWin(1) == val1 && spikeWin(2) == val2
                            % unchanged
                            status = 0;
                            break
                        end
                        
                        spikeWin = [val1, val2];
                        status = 2;
                    end
                end
        end
        
    end
    
    if status == 1 || status == 0
        % updated or unchanged
        newT = prepareNewT(obj,spikeWin,m,ch);
        objout = updateT(obj,newT,m,ch);
        
        fprintf('set to [%.2f,%.2f] for %s of %s\n', ...
            spikeWin(1),spikeWin(2),...
            chSp.ChanTitles{m}{ch},chSp.MatNames{m});

        if strcmpi(call,'one')
            obj.saveTparams
        end
    else
        objout = obj;
    end
else
    objout = obj;
    spikeWin = [];
    status = 0;
    figh = [];
end

    function openT(~,~)
        openvar obj.Tparams;
        disp('type "dbcobt" to resume')
        keyboard;
    end

    function runkeyboard(~,~)
        disp('type "dbcobt" to resume')
        keyboard;
    end
end

