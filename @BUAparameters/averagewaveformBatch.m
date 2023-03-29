function obj = averagewaveformBatch(obj,varargin)
% obj = averagewaveformBatch(obj)
% obj = averagewaveformBatch(obj,tf)
% obj = averagewaveformBatch(obj,'gui')
% obj = averagewaveformBatch(obj,_____,'Param',Value)
%
% out = averagewaveformBatch(obj,_____,'Interactive',false,'DoPlot',false)
%
% BUAparameters.averagewaveformBatch allows user to review and modify spike
% removal window parameters of two non-negative values [before_ms,
% after_ms] for multiple channels at one time while checking the
% event-triggered average waveforms of FWR BUA signals (spike-removed,
% rectified signal, yet to be low-pass filtered and downsampled).
%
% averagewaveformOne can only handle one channel, whereas
% averagewaveformMany goes through specified multiple channels in one-by-one
% manner. Only averagewaveformBatch can deal with multiple channels at one
% time.
% 
% All channels in obj.chanSpec or subset of channels in obj.chanSpec
% specified by logical column vector tf
%
% INPUT ARGUMENTS
% obj      a BUAparameters object
% 
% tf       (Optional) Column vector of logical or numeric values of 0 or 1.
%          The length of tf must be identical to sum(obj.chanSpec.ChanNum).
%          This tf vector is to be used to select subset of channels in
%          obj.chanSpec. Only channels whose corresponding value in tf is 1
%          will be considered for analysis.
%
% 'gui'    Allows you to use GUI channel selector from the first run.
%
%
% OPTIONAL PARAM/VALUE PAIRS
% 'meanadjustment'
%               'on' | 'off' (default)
%               'meanadjustment' option for getBUA()
%
% 'interactive' true (default) | false
%               false will not put buttons available. Just for plot
%               purpose. 
%
% 'doplot'      true (default) | false
%               false will not darw a plot. Instead it returns out. Ignored
%               if interactive is true.
%
% 'timerange'   [start end]
%               Time ragen to be analyzed in second. When data does not
%               exsit, they will be extended as NaNs.
%
% OUTPUT ARGUMENTS
% obj           a BUAparameters object
%
% out           Only when Intactive == false, DoPlot == fase, the function
%               returns structure
% 
%
% GUI BUTTONS
% Set values... Update spike removal window parameters for the currently
%               selected channels at once. This will update Ttemp in memory
%               and re-run the computations and plotting. However, the
%               changes in spike removal window size is only in a separate
%               variable in memory and not affect obj.Tparams or stored
%               .mat file. Note that, to accept the changes, you will need
%               to use Save button subsequently.
%
% Reselect..    Reselect subsest of obj.chanSpec with list GUI. This will
%               update obj.tf and re-run the computations and plotting.
%
% Save          This will update spike removal window parameters in
%               obj.Tparams with those values in a variable Ttemp. Then,
%               the content of obj.Tparams will be save into a *.mat file.
%
% Cancel        This will close the figure window and quit this method.
%               Before finishing the program will ask user whether to save
%               the current content of obj.Tparams into a *mat.file.
%
% Print         This will print the list of channels currently being
%               analyzed in the Command Window
%
% Debug         This will call keyboard function and MTALAB will enter
%               debug mode. To continue, use dbcont command.
%
% +/-5 ms, +/-10 ms
%               Button to change XLim property of axes.
%
% INTERNAL VARIABLE (cannot access)
% status
%          0 cancelled
%          1 continue
%
% See also
% BUAparameters.averagewaveformOne, BUAparameters.averagewaveformRest
% BUAparameters.inspectThresholdMany

p = inputParser;
p.addRequired('obj',@(x) isscalar(x));
p.addOptional('tf',[],@(x) (ischar(x) && isrow(x) && strcmpi(x,'gui')) ...
    || isvector(x) && all(x == 0 | x == 1));
p.addParameter('meanadjustment','off',@(x) ismember(x,{'on','off'}));
p.addParameter('interactive',true,@(x) isscalar(x) && x == 0 || x == 1);
p.addParameter('doplot',true,@(x) isscalar(x) && x == 0 || x == 1);
p.addParameter('timerange',[],@(x) isrow(x) && numel(x) ==2 && isreal(x));

p.parse(obj,varargin{:});

tf          = p.Results.tf;
interactive = p.Results.interactive;
doplot      = p.Results.doplot;
timerange   = p.Results.timerange;

status = 1;

if ischar(tf)
    tf = obj.chanSpec.ischanvalid('gui');
    
    if isempty(tf)
        status = 0;
    end
end

meanadj = p.Results.meanadjustment;

%% Job

chSp = obj.chanSpec;
n = sum(chSp.ChanNum);

if isempty(tf)
    
    tf = true(n,1);
    
end

assert(length(tf) == n)
obj.tf =tf; % store tf

clear tf % make sure to use obj.tf instead


d = NaN(n,1);
c = cell(n,1);
Ttemp = table(d,d,c,c,c,c,c,d,d,'VariableNames',...
    {'m','ch','parentdir','matname','chantitle','XData','YData',...
    'SpikeWin1','SpikeWin2'});

while status > 0
    if chSp.MatNum > 0
           
        [Ttemp,obj] = local_updateTtemp(obj,Ttemp,meanadj,timerange);

        if interactive
            [objout,Ttemp,status] = local_draw(obj,Ttemp,status);
        else
            if doplot
                [objout,Ttemp,status] = local_draw_non_interactive(obj,...
                    Ttemp,status);
            else

                objout = Ttemp(obj.tf,:);
                status = 0;
                
            end
        end
        
        obj = objout;
        
    else
        disp('There is no data to show.')
        
        break
    end
end

% Always ask

if interactive 
    obj.saveTparams;
end

end

%% LOCAL FUNCTIONS  -------------------------------------------------------

function [Ttemp,obj] = local_updateTtemp(obj,Ttemp,meanadj,timerange)
% local_updateTtemp checks if spikeWin values are already in Ttemp (in case
% updating) if not, fill Ttemp with values in obj.Tparams
%
% [Ttemp,obj] = local_updateTtemp(obj,Ttemp)
%

ALLIND = find(obj.tf)'; % row vector of index
fprintf('%d channels to analize\n',nnz(obj.tf));

chSp = obj.chanSpec;
S = preallocatestruct(Ttemp.Properties.VariableNames,[length(ALLIND),1]);

parfor i = 1:length(ALLIND)
    
    allind = ALLIND(i);
    [m,ch] = chSp.allind2matindchanind(allind);
    
    rowTtemp = Ttemp.m == m & Ttemp.ch == ch;
    
    S(i).m  = m;
    S(i).ch = ch;
    S(i).parentdir = chSp.getchanprop('parentdir',m,ch);
    S(i).matname   = chSp.MatNames(m);
    S(i).chantitle = chSp.ChanTitles{m}(ch);
    
    if any(rowTtemp)
        % get spikeWin from Ttemp
        
        spikeWin = Ttemp{rowTtemp,{'SpikeWin1','SpikeWin2'}};
        
        [S(i).XData{1},S(i).YData{1}] = local_getXDataYData(...
            obj,m,ch,spikeWin,'meanadjustment',meanadj,'timerange',timerange); % nargin 4
        
        S(i).SpikeWin1 = spikeWin(1);
        S(i).SpikeWin2 = spikeWin(2);
        
    else
        % fill Ttemp with values in obj.Tparams
                
        [S(i).XData{1},S(i).YData{1},spikeWin] = local_getXDataYData(...
            obj,m,ch,'meanadjustment',meanadj,'timerange',timerange); %nargin 3
        
        S(i).SpikeWin1 = spikeWin(1);
        S(i).SpikeWin2 = spikeWin(2);
        
    end
    
    fprintf('*');
end
fprintf('\n');


for i = 1:length(ALLIND)

    Ttemp(ALLIND(i),:) = struct2table(S(i));

end



% ALLIND = find(obj.tf)'; % row vector of index
% fprintf('%d channels to analize\n',nnz(obj.tf));
% 
% chSp = obj.chanSpec;
% for allind = ALLIND
%     
%     [m,ch] = chSp.allind2matindchanind(allind);
%     
%     rowTtemp = Ttemp.m == m & Ttemp.ch == ch;
%     
%     if any(rowTtemp)
%         % get spikeWin from Ttemp
%         
%         spikeWin = Ttemp{rowTtemp,{'SpikeWin1','SpikeWin2'}};
%         
%         [Ttemp.XData{allind},Ttemp.YData{allind}] = local_getXDataYData(...
%             obj,m,ch,spikeWin,'meanadjustment',meanadj,'timerange',timerange); % nargin 4
%         
%     else
%         % fill Ttemp with values in obj.Tparams
%         
%         Ttemp.m(allind)  = m;
%         Ttemp.ch(allind) = ch;
%         Ttemp.parentdir(allind) = chSp.getchanprop('parentdir',m,ch);
%         Ttemp.matname(allind)   = chSp.MatNames(m);
%         Ttemp.chantitle(allind) = chSp.ChanTitles{m}(ch);
%         
%         [Ttemp.XData{allind},Ttemp.YData{allind},spikeWin] = local_getXDataYData(...
%             obj,m,ch,'meanadjustment',meanadj,'timerange',timerange); %nargin 3
%         
%         Ttemp.SpikeWin1(allind) = spikeWin(1);
%         Ttemp.SpikeWin2(allind) = spikeWin(2);
%         
%     end
%     
%     clear spikeWin
%     fprintf('*');
% end
% fprintf('\n');

end

%--------------------------------------------------------------------------

function [obj,Ttemp,status] = local_draw(obj,Ttemp,status)

figh = figure;
axh = axes;
axh.Position = [0.15 0.2 0.775 0.7];

linh = gobjects(nnz(obj.tf),1);
k = 0;
for allind = find(obj.tf)'
    k = k + 1;
    tagstr = sprintf('(%d,%d) %s | %s',Ttemp.m(allind),Ttemp.ch(allind),...
        Ttemp.matname{allind},Ttemp.chantitle{allind});
    
    linh(k) = line(Ttemp.XData{allind},Ttemp.YData{allind},...
        'Color',pickColor(k,nnz(obj.tf)),'DisplayName',tagstr,'Tag',tagstr);
end
clear allind k

xlim([-5 5]); %OK

xlabel('Time relative to event (ms)')
ylabel('Amplitude (mV)')
set(gca,'Box','off','TickDir','out')

%Note vertical bars appear when spiekWin is shared by all visible channels
first = find(obj.tf,1,'first');
if isempty(Ttemp.SpikeWin1(obj.tf))
    
    spikeWin = [];
    bar1 = []; %#ok<NASGU>
    bar2 = []; %#ok<NASGU>
    
elseif all(Ttemp.SpikeWin1(first) == Ttemp.SpikeWin1(obj.tf)) ...
        && all(Ttemp.SpikeWin2(first) == Ttemp.SpikeWin2(obj.tf))
    
    spikeWin = [Ttemp.SpikeWin1(first), Ttemp.SpikeWin2(first)];
    
    ylimval = ylim(axh);
    
    bar1 = line(axh,[-spikeWin(1),-spikeWin(1)],ylimval,...
        'Color','k','LineStyle','--','Tag','before'); %#ok<NASGU>
    
    bar2 = line(axh,[spikeWin(2),spikeWin(2)],ylimval,...
        'Color','k','LineStyle','--','Tag','after'); %#ok<NASGU>
    
    ylim(axh,ylimval)
    
else
    
    spikeWin = [];
    bar1 = []; %#ok<NASGU>
    bar2 = []; %#ok<NASGU>
    
end


%% uicontrol objects

btnreselect = uicontrol('Style', 'pushbutton','String', 'Reselect...',...
    'Position', [0 0 80 30],...
    'Callback', @reselectList); %#ok<NASGU>

btnSetVal = uicontrol('Style', 'pushbutton', 'String', 'Set Values...',...
    'Position', [80 0 80 30],...
    'Callback', @changeVal); %#ok<NASGU>

btn5 = uicontrol('Style', 'pushbutton', 'String', '+/-5 ms',...
    'Position', [180 0 80 30],...
    'Callback', 'xlim([-5 5])');%#ok<NASGU>

btn10 = uicontrol('Style', 'pushbutton', 'String', '+/-10 ms',...
    'Position', [260 0 80 30],...
    'Callback', 'xlim([-10 10])');%#ok<NASGU>

btnSave = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [480 0 80 30],...
    'Callback', @callSaveT); %#ok<NASGU>

btnCancel = uicontrol('Style', 'pushbutton', 'String', 'Cancel',...
    'Position', [480 390 80 30],...
    'Callback', @cancelThis); %#ok<NASGU>

btnDebug = uicontrol('Style', 'pushbutton', 'String', 'Debug',...
    'Position', [400 390 80 30],...
    'Callback', @enterdebug);%#ok<NASGU>

btnPrint = uicontrol('Style', 'pushbutton', 'String', 'Print',...
    'Position', [0 390 80 30],...
    'Callback', @printList);%#ok<NASGU>

btnKeep = uicontrol('Style', 'pushbutton', 'String', 'Keep Figure',...
    'Position', [80 390 80 30],...
    'Callback', @keepfig);

btnLineColor = uicontrol('Style', 'pushbutton', 'String', 'Change Color',...
    'Position', [160 390 80 30],...
    'Callback', @changecolor);

btnLeg = uicontrol('Style', 'pushbutton', 'String', 'Legend',...
    'Position', [240 390 80 30],...
    'Callback', @putlegend);

disp('uiwait(figh)')

tfchangecolor = false;
tfkeepfig = false;
legh = gobjects;
uiwait(figh)

if tfkeepfig == false
    close(figh)
end
    

%% local_draw/NESTED CALLBACK FUNCTIONS

    function changeVal(~,~)
        
        if isempty(spikeWin)
            
            spikeWin = obj.SpikeWindefault;
            
        end
        
        [spikeWin,status] = setSpikeWinDlg(spikeWin);

        % update SpikeWin values in Ttemp
        
        for ALLIND = find(obj.tf)'
            
            [m,ch] = obj.chanSpec.allind2matindchanind(ALLIND);
            
            assert(Ttemp{ALLIND,'m'} == m)
            assert(Ttemp{ALLIND,'ch'} == ch)
         
            Ttemp{ALLIND,{'SpikeWin1','SpikeWin2'}} = spikeWin;
            
            printSpikeWin(spikeWin,m,ch,obj);
             
        end
        
        uiresume(figh)
    end

%--------------------------------------------------------------------------

    function enterdebug(~,~)
        if btnDebug.BackgroundColor == [1 1 0]
            % being in debug mode
            disp('type "dbcont" to resume')
           
        else
            uiresume(figh)
            btnDebug.BackgroundColor = 'y';
            disp('Entering debug mode. Type "dbcont" to resume.')
            keyboard
            disp('Existing debug mode.')
            btnDebug.BackgroundColor = 'w';
            uiwait(figh)
        end
    end 
%--------------------------------------------------------------------------
    function callSaveT(~,~)
        
        for ALLIND = find(obj.tf)'
            %% updata obj.Tparams with the values in Ttemp
                        
            newT = Ttemp(ALLIND,{'parentdir','matname','chantitle','SpikeWin1','SpikeWin2'});
            
            [m,ch] = obj.chanSpec.allind2matindchanind(ALLIND);
            obj = updateT(obj,newT,m,ch);
            
            printSpikeWin(spikeWin,m,ch,obj);
            
        end
        
        obj.saveTparams; % save to .mat file
        
        status = 1;
        
    end

%--------------------------------------------------------------------------
    function cancelThis(~,~)
        status = 0;
        uiresume(figh); % must be in a nested function
    end

%--------------------------------------------------------------------------
    function printList(~,~)
        
        for ALLIND = find(obj.tf)'
            
            [m,ch] = obj.chanSpec.allind2matindchanind(ALLIND);
            
            assert(Ttemp{ALLIND,'m'} == m)
            assert(Ttemp{ALLIND,'ch'} == ch)

            fprintf('set to [%.2f,%.2f] for(%d,%d) %s | %s\n', ...
                Ttemp{ALLIND,'SpikeWin1'},...,
                Ttemp{ALLIND,'SpikeWin2'},...,
                m,ch,...
                obj.chanSpec.ChanTitles{m}{ch},...
                obj.chanSpec.MatNames{m});
        end 
    end
%--------------------------------------------------------------------------
    function keepfig(~,~)
        if tfkeepfig
            tfkeepfig = false;
            btnKeep.BackgroundColor = 'w';
        else
            tfkeepfig = true;
            btnKeep.BackgroundColor = 'y';
        end
    end
%--------------------------------------------------------------------------
    function changecolor(~,~)
        if tfchangecolor
            tfchangecolor = true;
            uiresume(figh)
            for j = 1:nnz(obj.tf)
                linh(j).Color = pickColor(j,nnz(obj.tf));
            end
            btbtnLineColornLeg.BackgroundColor = 'y';
            uiwait(figh)
        else
            tfchangecolor = false;
            uiresume(gcf)
            for j = 1:nnz(obj.tf)
                linh(j).Color = 'r';
            end
            btbtnLineColornLeg.BackgroundColor = 'w';
            uiwait(figh)
        end
    end
%--------------------------------------------------------------------------
    function putlegend(~,~)
        if ishandle(legh)
            delete(legh);
            btnLeg.BackgroundColor = 'w';
        else
            legh = legend(linh,{linh(:).Tag});
            legh.Interpreter = 'none';
            btnLeg.BackgroundColor = 'y';
        end
        
    end
%--------------------------------------------------------------------------
    function reselectList(~,~)
        
        [TF] = obj.chanSpec.ischanvalid('gui',obj.tf);
        if ~isempty(TF)
            
            confirmChansMats(TF);

        else
            disp('nothing chosen')
        end
    end
%% local_draw/NESTED FUNCTIONS
    function confirmChansMats(tf)

        if nnz(tf) > 0
            disp('You''ve chosen:')
            for ALLIND = find(tf)'
                
                [m,ch] = obj.chanSpec.allind2matindchanind(ALLIND);
                
                fprintf('(%d,%d) %s of %s\n',...
                    m,ch,...
                    obj.chanSpec.ChanTitles{m}{ch},...
                    obj.chanSpec.MatNames{m});
            end
        end
        
        btn = questdlg('Do you wish to proceed? Unsaved changes will be lost.',...
            'Confirm','OK','Cancel','OK');
        
        switch btn
            case 'OK' 
                obj.tf = tf;
                status = 1;
                uiresume(figh); % must be in a nested function
            case 'Cancel'
                disp('Cancelled')
                uiwait(figh)
        end

    end
%--------------------------------------------------------------------------
    function printSpikeWin(spikeWin,m,ch,obj)
        
        fprintf('set to [%.2f,%.2f] for (%d,%d) %s | %s\n', ...
            spikeWin(1),spikeWin(2),...
            m,ch,...
            obj.chanSpec.MatNames{m},...
            obj.chanSpec.ChanTitles{m}{ch});
    end
end
%--------------------------------------------------------------------------

function [obj,Ttemp,status] = local_draw_non_interactive(obj,Ttemp,~)

figh = figure;
axh = axes;
axh.Position = [0.15 0.2 0.775 0.7];

linh = gobjects(nnz(obj.tf),1);
k = 0;
for allind = find(obj.tf)'
    k = k + 1;
    tagstr = sprintf('(%d,%d) %s | %s',Ttemp.m(allind),Ttemp.ch(allind),...
        Ttemp.matname{allind},Ttemp.chantitle{allind});
    
    linh(k) = line(Ttemp.XData{allind},Ttemp.YData{allind},...
        'Color',pickColor(k,nnz(obj.tf)),'DisplayName',tagstr,'Tag',tagstr);
end
clear allind k

xlim([-5 5]); %OK

xlabel('Time relative to event (ms)')
ylabel('Amplitude (mV)')
set(gca,'Box','off','TickDir','out')

%Note vertical bars appear when spiekWin is shared by all visible channels
first = find(obj.tf,1,'first');
if isempty(Ttemp.SpikeWin1(obj.tf))
    
    spikeWin = [];
    bar1 = []; %#ok<NASGU>
    bar2 = []; %#ok<NASGU>
    
elseif all(Ttemp.SpikeWin1(first) == Ttemp.SpikeWin1(obj.tf)) ...
        && all(Ttemp.SpikeWin2(first) == Ttemp.SpikeWin2(obj.tf))
    
    spikeWin = [Ttemp.SpikeWin1(first), Ttemp.SpikeWin2(first)];
    
    ylimval = ylim(axh);
    
    bar1 = line(axh,[-spikeWin(1),-spikeWin(1)],ylimval,...
        'Color','k','LineStyle','--','Tag','before'); %#ok<NASGU>
    
    bar2 = line(axh,[spikeWin(2),spikeWin(2)],ylimval,...
        'Color','k','LineStyle','--','Tag','after'); %#ok<NASGU>
    
    ylim(axh,ylimval)
    
else
    
    spikeWin = [];
    bar1 = []; %#ok<NASGU>
    bar2 = []; %#ok<NASGU>
    
end

a = gca;
a.Units = 'pixels';

pos = figh.Position;
figh.Position = [pos(1), pos(2)-400, pos(3), 800];


leg = legend(linh);
leg.Location = 'southoutside';
leg.Interpreter ='none';

a.Position = [70 350 460 400];

status = 0;

end

%--------------------------------------------------------------------------

function color = pickColor(k,n)

if n <= 7
    color = defaultPlotColors(k);
    
else
   p = parula(n);
   color = p(k,:);
end

end

%--------------------------------------------------------------------------

function [XData,YData,spikeWin] = local_getXDataYData(obj,m,ch,varargin)

p = inputParser;
p.addRequired('obj');
p.addRequired('m');
p.addRequired('ch');
p.addOptional('spikeWin',[]);
p.addParameter('meanadjustment','on');
p.addParameter('timerange',[]);
p.parse(obj,m,ch,varargin{:});

spikeWin  = p.Results.spikeWin;
meanadj   = p.Results.meanadjustment;
timerange = p.Results.timerange;

W = obj.chanSpec.constructChan(m,ch);
% Whigh = obj.highpass(W);
% spkthre = std(Whigh)*obj.SDx;

%TODO
if ~isempty(timerange)
    W = W.extractTime(timerange(1),timerange(2),'extend'); 
end


spkthre = obj.getThre(W);

if isempty(spikeWin)
    % Read the table
    spikeWin = getSpikeWin(obj,m,ch); %NOTE important
    
    if isempty(spikeWin)
        spikeWin = obj.SpikeWindefault;
    end
    
else
    % Use the spikeWin as input
    assert(numel(spikeWin) == 2 && isrow(spikeWin) && all(spikeWin >= 0))
end

[~,~,fwrbua,~,~,spiketimes,~,~,~] = W.getBUA(...
    'wideband thresholding',obj.order,spkthre,'spikewindow',spikeWin,...
    'meanadjustment',meanadj);

[~,~,~,~,~,data] = fwrbua.plotTriggered(spiketimes,0.02,0.01,...
    'Average','off','OverDraw','off','ErrorBar','off');

XData = data.t;
YData = data.mean;

end

%--------------------------------------------------------------------------

function [spikeWin,status] = setSpikeWinDlg(spikeWin)

%% Job
vfval = @(x) isscalar(x) && isreal(x) && x >= 0 && x < 100;


options.WindowStyle = 'normal';
answer = inputdlg({'before (msec) [0-100]','after (msec) [0-100]'},...
    'Set size',1,...
    {num2str(spikeWin(1)),num2str(spikeWin(2))},options);

if isempty(answer)
    % cancelled
    status = 1;

else
    [val1, str2num_status] = str2num(answer{1}); %#ok<ST2NM>
    val1 = round(val1*10)/10; % to one place of decimal
    if ~str2num_status
        % Handle empty value returned
        % for unsuccessful conversion
        disp('illegal value has been ignored.')
        status = 1;
    end
    
    [val2, str2num_status] = str2num(answer{2}); %#ok<ST2NM>
    val2 = round(val2*10)/10; % to one place of decimal
    if ~str2num_status
        % Handle empty value returned
        % for unsuccessful conversion
        disp('illegal value has been ignored.')
        status = 1;
    end
    
    if vfval(val1) && vfval(val2)
        if spikeWin(1) == val1 && spikeWin(2) == val2
            % unchanged
            status = 1;
        else
            spikeWin = [val1, val2];
            status = 1;
        end
    end
end


end


