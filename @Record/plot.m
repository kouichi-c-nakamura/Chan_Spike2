function h = plot(this, varargin)
% Record.plot
%
% SYNTAX
% h = plot(rec)
% h = plot(rec, 'ChanTitle1', 'ChanTitle2', ....)
%
%
% INPUT ARGUMENTS
% rec         Record object
%
% 'ChanTitle1', 'ChanTitle2',...
%             character row vectors
%             (Optional) ChanTitles for each channel.
%
%
% OUTPUT ARGUMENTS
% h           structure
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 23-Oct-2018 23:49:26
%
% See also
% Record.Record
%
%
%TODO
% When rec has many data points, the drawing takes up large memory and very
% slow. It's possible to think about dynamic downsampling depending on XLim
% propeties using callback function.


height_interval = 0.025;
margin_bottom = 0.12;
margin_left = 0.10;
margin_top = 0.05;
margin_right = 0.02;

fig = figure('Color', 'w');

plot_icons = load(fullfile(fileparts(which('Record.m')),'plot_icons.mat')); % for uipushtool

if nargin == 1
    channels = this.Chans;
    chaninfo = this.summaryTable;
    
elseif nargin > 1
    
    allnames = this.ChanTitles; % TODO

    isallchar = @(x) all(cellfun(@(x) ischar(x) && isrow(x), x));
    if ~isallchar(varargin)
        error('K:Record:plot:chantitles:invalid',...
            'In input arguments, Chan objects'' ChanTitle properties must be char type.')
    end
    
    isunique = @(x) length(unique(x)) == length(x); 
    if ~isunique(varargin)
        error('K:Record:plot:chantitles:invalid',...
            'In input arguments, Chan objects'' ChanTitle properties must be unique.')
    end
    

    [~,selected] = ismember(varargin, allnames);
    isallmember = @(x) all(ismember(x, allnames));
    if ~isallmember(varargin)
        error('K:Record:plot:chantitles:invalid',...
            'In input arguments, Chan objects'' ChanTitle properties must match those stored in Record.')
    end

    channels = this.Chans(selected);
    summaryds = this.summaryDataset;  % TODO
    chaninfo = summaryds(selected, :);  % TODO
%     chaninfo = this.Summary(selected, :); % TODO
    
end

%% set axes

if verLessThan('matlab','8.4.0')
    ax = zeros(size(channels));
else
    ax = gobjects(size(channels));
end

lineh = cell(size(channels));
ylabelPos = zeros(length(channels), 3);


nwf = nnz(strcmp('WaveformChan', chaninfo.Classname));
nev = nnz(strcmp('EventChan', chaninfo.Classname));
nmk = nnz(strcmp('MarkerChan', chaninfo.Classname));
nwm = nnz(strcmp('WaveMarkChan', chaninfo.Classname));

if nwf + nmk + nev + nwm ~=  length(channels)
    error('');
    
end

x = (1 - margin_top - margin_bottom - height_interval ...
    *( length(channels) -1))/((nev + nmk + (nwf + nwm) *10)); 

height_event = x;
height_waveform = x *10;

if x <= 0
    
    height_interval = 0;
    x = (1 - margin_top - margin_bottom - height_interval ...
        *( length(channels) -1))/((nev + nmk + nwf *10));
    
    height_event = x;
    height_waveform = x *10;
end

y = margin_bottom; 
height = 0;

if verLessThan('matlab','8.4.0')
    cmenu = zeros(1,length(channels));
else
    cmenu = gobjects(1,length(channels));
end

for i = 1:length(channels) % from bottom to top
    switch chaninfo.Classname{i}
        case {'WaveformChan','WaveMarkChan'}
            height = height_waveform;
        case {'EventChan', 'MarkerChan'}
            height = height_event; 
    end        
        
    ax(i) = axes('Position',...
        [margin_left, y, 1 - margin_right - margin_left, height]);% set subplots
    
    switch chaninfo.Classname{i}
        case 'WaveformChan'
            set(ax(i),'Tag',sprintf('%d Waveform %s',i,channels{i}.ChanTitle));
        case 'EventChan'
            set(ax(i),'Tag',sprintf('%d Event %s',i,channels{i}.ChanTitle));
        case 'MarkerChan'
            set(ax(i),'Tag',sprintf('%d Marker %s',i,channels{i}.ChanTitle));
    end
    
    switch chaninfo.Classname{i}
        case 'EventChan'
            set(ax(i),'YLim', [-1.2, 1.2]);
        case 'MarkerChan'
            set(ax(i),'YLim', [-1.2, 1.6]);
    end
    
    if i > 1
        set(ax(i),'XTick', [], 'XColor', 'w');
    end
    
    %% Change margin_left values
    
    cmenu(i) = uicontextmenu(fig,'Tag','Y axis scale');
    set(ax(i),'UIContextMenu',cmenu(i));
    set(cmenu(i),'UserData',ax(i));
    
    
    switch chaninfo.Classname{i}
        case {'WaveformChan','WaveMarkChan'}
            switch chaninfo.Classname{i}
                case 'WaveformChan'
                    lineh{i} = channels{i}.plot(ax(i), 'Color', [0, 0.5, 0]); %the main job
                    
                case 'WaveMarkChan'
                    L = channels{i}.plot(ax(i)); %the main job

                    lineh{i} = hggroup;
                    for j = 1:length(L)
                        
                        L(j).Parent = lineh{j};
                        
                    end
                    
            end
            set(get(ax(i), 'YLabel'), 'Units', 'normalized'); % important for alignment of ylabels
            ylabelPos(i, :) = get(get(ax(i), 'YLabel'), 'Position');
            
            %% Y Axis Scale for Waveform
            cmenu(i) = uicontextmenu(fig,'Tag','Y axis scale');
            set(ax(i),'UIContextMenu',cmenu(i));
            set(cmenu(i),'UserData',ax(i));
            
            m1 =  uimenu(cmenu(i),'Label','Show Whole Y Axis','Callback',@changeylim);
            m2 =  uimenu(cmenu(i),'Label','Zoom In Y Axis','Callback',   @changeylim);
            m3 =  uimenu(cmenu(i),'Label','Zoom Out Y Axis','Callback',  @changeylim);
            m4 =  uimenu(cmenu(i),'Label','Toggle Angle of Y Axis Labels','Callback',@toggleYLabelAngle);
            
            mL1 = uimenu(cmenu(i),'Label','Increase left margin','Callback',@changeLmargin);
            mL2 = uimenu(cmenu(i),'Label','Decrease left margin','Callback',@changeLmargin);
            mL3 = uimenu(cmenu(i),'Label','Default left margin','Callback', @changeLmargin);
            
        case {'EventChan', 'MarkerChan'}
            lineh{i} = channels{i}.plot(ax(i)); %the main job
            
            mL1 = uimenu(cmenu(i),'Label','Increase left margin','Callback',@changeLmargin);
            mL2 = uimenu(cmenu(i),'Label','Decrease left margin','Callback',@changeLmargin);
            mL3 = uimenu(cmenu(i),'Label','Default left margin','Callback', @changeLmargin);
    end
    
    if i > 1
        delete(get(ax(i), 'XLabel'));
    end
    set(ax(i),'TickLabelInterpreter','none'); 
    %NOTE in many cases Chan Titles do not need to use 'tex'
    
    h.chantitles{i, 1} = channels{i}.ChanTitle;

    y = y + height + height_interval;
    

end

title(ax(end),this.RecordTitle,'Interpreter','none');

linkaxes(ax, 'x');
% set(fig, 'SizeChangedFcn', @local_changeYLabelSize);

%% uipushtool
t = uitoolbar(fig);

hbtns(1) = uipushtool('Parent', t, ...
    'CData',           plot_icons.leftleft, ...
    'ClickedCallback', @(h, ev) moveStart(), ...
    'Tag',             'btnStart', ...
    'TooltipString',   'Move to start');

hbtns(2) = uipushtool('Parent', t, ...
    'CData',           plot_icons.left, ...
    'ClickedCallback', @(h, ev) moveL(), ...
    'Tag',             'btnL', ...
    'TooltipString',   'Move left');

hbtns(3) = uipushtool('Parent', t, ...
    'CData',           plot_icons.right, ...
    'ClickedCallback', @(h, ev) moveR(), ...
    'Tag',             'btnR', ...
    'TooltipString',   'Move right');

hbtns(4) = uipushtool('Parent', t, ...
    'CData',           plot_icons.rightright, ...
    'ClickedCallback', @(h, ev) moveEnd(), ...
    'Tag',             'btnEnd', ...
    'TooltipString',   'Move to end');


hbtns(5) = uipushtool('Parent', t, ...
    'CData',           plot_icons.home, ...
    'ClickedCallback', @(h, ev) showall(), ...
    'Tag',             'btnFull', ...
    'TooltipString',   'Show all X');

hbtns(6) = uipushtool('Parent', t, ...
    'CData',           plot_icons.minus, ...
    'ClickedCallback', @(h, ev) zoomout(), ...
    'Tag',             'btnMinus', ...
    'TooltipString',   'Zoom out');

hbtns(7) = uipushtool('Parent', t, ...
    'CData',           plot_icons.plus, ...
    'ClickedCallback', @(h, ev) zoomin(), ...
    'Tag',             'btnPlus', ...
    'TooltipString',   'Zoom in');

hbtns(8) = uipushtool('Parent', t, ...
    'CData',           plot_icons.updown, ...
    'ClickedCallback', @(h, ev) showallY(), ...
    'Tag',             'btnY', ...
    'TooltipString',   'Show all Y');


%% UI controls slider
sld = uicontrol('Style', 'slider',...
    'Units','normalized',... 
    'Min',this.Start,'Max',this.MaxTime,...
    'Value',sum(xlim)/2,...
    'Sliderstep',[0.01,1],...
    'Position', [margin_left, 0, 1 - margin_right - margin_left, 0.03],...
    'TooltipString','Move',...
    'Callback', @slidemove,'Tag','Slider');
set(sld,'Units','pixels');
sldpos = get(sld,'Position');
set(sld,'Position',[sldpos(1)-20,0,sldpos(3)+20*2,20]); % 20 for the left or right arrow
clear sldpos
set(sld,'Units','normalized');
    

ylabeltxtstr = cell(1,length(ax));
for i = 1:length(ax)
	ylabelobj = get(ax(i),'YLabel');
	ylabeltxtstr{i} = get(ylabelobj,'String');
end


%% align ylabels %TODO


% local_changeYLabelSize(ax);

wf = find(any(ylabelPos ~= 0, 2));
newx = min(ylabelPos(wf, 1)); 
ylabelPos(wf, 1) = repmat(newx, length(wf), 1);
for  i = 1:length(wf)
    set(get(ax(wf(i)), 'YLabel'), 'Position', ylabelPos(wf(i),:));
end

ylabelPosDefault = ylabelPos;

% local_breakLines(this, ylabeltxtstr); %TODO


fig.SizeChangedFcn = @uponfigsizechange;


%% handles
h.fig = fig;
h.ax =ax;
h.lineh = lineh;
zoom off; pan off;

%% Nested Callback Functions
    % for maintenance and development with debugger, comment out these nested functions

    function changeylim(source,~)
        thisAxis = source.Parent.UserData;
        center = mean(ylim);
        halfwidth = diff(ylim)/2;
        switch source.Label
            case 'Show Whole Y Axis'
                ylim(thisAxis,'auto')
            case 'Zoom In Y Axis'
                ylim(thisAxis,[center - halfwidth/2, center + halfwidth/2]);
            case 'Zoom Out Y Axis'
                ylim(thisAxis,[center - halfwidth*2, center + halfwidth*2]);    
        end
    end


    function changeLmargin(source,~)

        switch source.Label
            case 'Increase left margin'
                margin_left = margin_left + 0.05;
            case 'Decrease left margin'
                margin_left = margin_left -0.05;
            case 'Default left margin'
                margin_left = 0.10;
        end
        
        for k = 1:length(ax)
            pos = ax(k).Position;
            set(ax(k),'Position',...
                [margin_left, pos(2), 1 - margin_right - margin_left, pos(4)]);
        end
        
        set(sld,'Units','normalized');
        set(sld,'Position',[margin_left, 0.03, 1 - margin_right - margin_left, 0.03]); 
        
        set(sld,'Units','pixels');
        pos = get(sld,'Position');
        set(sld,'Position',[pos(1)-20,0,pos(3)+20*2,20]); % 20 for the left or right arrow
        clear sldpos
        set(sld,'Units','normalized');
 
    end

    function uponfigsizechange(~,~)
        
        set(sld,'Units','normalized');
        set(sld,'Position',[margin_left, 0.03, 1 - margin_right - margin_left, 0.03]);
        
        set(sld,'Units','pixels');
        pos = get(sld,'Position');
        set(sld,'Position',[pos(1)-20,0,pos(3)+20*2,20]); % 20 for the left or right arrow
        clear sldpos
        set(sld,'Units','normalized');
        
    end
        

    function showallY(~,~)
        
        %TODO get axf for waveform channels
        
        axhs = findobj(fig,'Type','axes');
        ind = ismatched({axhs(:).Tag}', 'Waveform');

        if any(ind)
            ylim(axhs(ind),'auto');
        end
           
    end

    function moveStart(~,~)

        currentxlim = xlim;
        
        width = diff(currentxlim);
        
        right = this.Start + width ;
        
        if right < this.MaxTime
            xlim([this.Start, right ]);
        else
            xlim([this.Start, this.MaxTime]);
        end
        
        set(sld,'Value',this.Start);

    end

    function moveEnd(~,~)

        currentxlim = xlim;
        
        width = diff(currentxlim);
        
        left = this.MaxTime - width ;
        
        if left > this.Start
            xlim([left, this.MaxTime]);
        else
            xlim([this.Start, this.MaxTime]);
        end
        
        set(sld,'Value',this.MaxTime);
 
    end

    function moveL(~,~)
        
        currentxlim = xlim;
        halfwidth = diff(currentxlim)/2;
        xlim(currentxlim - halfwidth);
        
        updateSlider();
        
    end

    function moveR(~,~)
        
        currentxlim = xlim;
        halfwidth = diff(currentxlim)/2;
        xlim(currentxlim + halfwidth);
        
        updateSlider();

    end

    function slidemove(src,~)
                
        val = src.Value;
        halfwidth = diff(xlim)/2;
        xlim([val-halfwidth,val+halfwidth]);
        
    end

    function showall(~,~)
        xlim('auto');
        
        updateSlider();
        
        set(sld,'Sliderstep',[0.01,1]);
        
    end

    function zoomout(~,~)
        
        center = mean(xlim);
        width = diff(xlim);
        xlim([center-width,center+width]);
        
        ratio = diff(xlim)/this.Duration;
        set(sld,'Sliderstep',[0.01*ratio,ratio]);
    end

    function zoomin(~,~)
        
        center = mean(xlim);
        width = diff(xlim);
        xlim([center-width/4,center+width/4]);
        
        ratio = diff(xlim)/this.Duration;
        set(sld,'Sliderstep',[0.01*ratio,ratio]);
    end

    function updateSlider()
       
        if mean(xlim) < this.Start
            set(sld,'Value',this.Start);
        elseif mean(xlim) > this.MaxTime
            set(sld,'Value',this.MaxTime);
        else
            set(sld,'Value',mean(xlim));
        end
        
    end

    %--------------------------------------------------------------------------

    function toggleYLabelAngle(source,~)
        
        [ax, ylabelPos, ~, ylabelTxt] =local_getylabelPos();

        if ~isempty(ylabelTxt)
            if ylabelTxt(1).Rotation == 90                
                newAng = 0;
            else
                newAng = 90;
            end
            
            for k = 1:length(ax)                

                if newAng == 0
                    set(ylabelTxt(k), 'Rotation', newAng,...
                        'HorizontalAlignment','right');
                    xpos = ylabelPosDefault(1,1);
                    
                    ylabelTxt(k).Position(1) = xpos;
                       
                else
                    set(ylabelTxt(k), 'Rotation', newAng,...
                        'HorizontalAlignment','center');
                    ylabelTxt(k).Position = ylabelPosDefault(k,:);


                end
                
            end
            
            if newAng == 0
                s.Label = 'Increase left margin';
                changeLmargin(s);
                changeLmargin(s);
            else
                s.Label = 'Decrease left margin';
                changeLmargin(s);
                changeLmargin(s);
            end
        
        end        
    end


end

%--------------------------------------------------------------------------

function align_ylabels()
%TODO need to consider Extent(3) = width, which is not reflected in
% Position values

[~, ylabelPos, ylabelExt, ylabelTxt] =local_getylabelPos();

ind = any(ylabelPos ~= 0, 2);
newx = max(ylabelPos(ind, 1)); 
ylabelPos(ind, 1) = repmat(newx, nnz(ind), 1);
for  i = 1:length(ind)
    
    if ind(i)
        set(ylabelTxt, 'Position', ylabelPos(i,:));
    end
    
    ylabelExt(i, :) =  get(ylabelTxt, 'Extent');
end


end

%--------------------------------------------------------------------------

function [ax, ylabelPos, ylabelExt, ylabelTxt] =local_getylabelPos()

ax = findobj(gcf, 'Type', 'Axes');

if ~verLessThan('matlab','8.4.0')
    ylabelTxt = gobjects(size(ax));
else
    ylabelTxt = zeros(size(ax));
end

for i = 1:length(ax)
    ylabelTxt(i) = get(ax(i), 'YLabel');    
end

ylabelPos = zeros(length(ylabelTxt),3);
ylabelExt = zeros(length(ylabelTxt),4);

for i = 1:length(ylabelTxt)
    ylabelPos(i,:)= get(ylabelTxt(i),'Position');
    ylabelExt(i,:)= get(ylabelTxt(i),'Extent');

end

end

%--------------------------------------------------------------------------

function local_accomodateYLabel()
%TODO because "normzlized" for Text is for axes.Position while "normalized" for axes is
% for figure.Extent, you cannot directly compute the ideal Postion for Axes
% and YLabel. 
%
% 1. h = [ax, ylabelh]
% 2. set(h, 'Units', 'centimeters') % temporally
% 3. compute the coordinate with the common Units
% 4. set(h, 'Units', 'normalized') % set back


[ax, ~, ~, ylabelTxt] =local_getylabelPos();


for i = 1:length(ax)
    set(ax(i), 'Units', 'centimeters');    
    set(ylabelTxt(i), 'Units', 'centimeters');
end


[ax, ylabelPos, ylabelExt, ylabelTxt] =local_getylabelPos();

outPos = zeros(length(ax),4);
Pos = zeros(length(ax),4);

for i = 1:length(ax)

    outPos(i,:) = get(ax(i), 'OuterPosition');
    Pos(i,:) = get(ax(i), 'Position');
    
end

ylabelExt_L = ylabelExt(:,1);
outPos_L = outPos(:,1);
Pos_L = Pos(:,1);

for i = 1:length(ax)
    set(ylabelTxt(i), 'Units', 'normalized');
    set(ax(i), 'Units', 'centimeters');
end


%TODO under construction
% conversion between centimeters and normalized based on the Position
% values obtained in two Units modes.
%
% Then specify the appropriate width value in normalized unit to the Axes.

[ax, ylabelPos, ylabelExt, ylabelTxt] =local_getylabelPos();

if min(ylabelExt_L) < 0
    
    newPos1 =  -min(ylabelExt_L)*1.1;
    
    
    for i = 1:length(ax)

    Pos(1,1);
    -min(ylabelExt_L);
    
    Pos(i,:) = set(ax(i), 'Position', [ -min(ylabelExt_L)*1.1, Pos(1,2), Pos(1,3), Pos(1,4)]);
    
end

%TODO set back to normalized
  
for i = 1:length(ax)
    set(ylabelTxt(i), 'Units', 'normalized');
    set(ax(i), 'Units', 'normalized');
end  

end
end

%--------------------------------------------------------------------------


function local_breakLines(this, ylabeltxtstr)
% hold ylabeltxt (original txt) in cell array in the main function

%for each YLabel
% 1. find positions of spaces, hyphens and underscores with regexp
%
% 2. judge if the current text height exceeds axes height and by what times
%
% 3. If the text is more than two fold but less than three fold longer in height than axes,
% then find appropriate break points to break the text into two lines etc


[ax, ylabelPos, ylabelExt, ylabelTxt] =local_getylabelPos();

for i = 1:length(ax)
	if ~isempty(ylabeltxtstr{i})

        % ' (mV)' is added at the end for WaveformChan by default
        
        ylabelstem = regexprep(ylabeltxtstr{i},'\s\(mV\)', '');
		ind = regexp(ylabelstem,'[\s_\-,]');
        
        ylabelPos(i,:)
        ylabelExt(i,:)
		

	end
end
end
