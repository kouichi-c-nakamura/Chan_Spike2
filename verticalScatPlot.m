function verticalScatPlot(varargin)
% verticalScatPlot plots data points as a vertically oriented clouds.
%
% verticalScatPlot(X)
% verticalScatPlot(X, G)
% verticalScatPlot(axh, _____)
% verticalScatPlot(_____, 'Parameter', value)
%
% REQUIREMENTS
% Statistics Toolbox only when 'showboxplot' option is enabled.
% 
% INPUT ARGUMENTS
% X        A vector of real numbers
%
% G        A grouping vector with the same length as X. Containing category
%          labels. If G is not provdided, data X is treated as one group.
%          cell vector of strings | char vector | categorical vector
%
% axh      (Optional) axes handle
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'Width'       a horizontal wdith in which data points are plotted
%               default = 0.8
%
% 'BinSize'     20 (default) | scalar positive integer
%               Y axis bin size. This will be ignored for 'rand'
%               spreadmode. When markers look too obviously grid-aligned
%               due to small sample size, you may try smaller BinSize.
%               When sample size is large, consider using larger BinSize.
%
% 'SpreadMode'  'grid' (default) | 'rand'
%               if exist, must be eigther 'rand' or ' grid' (default)
%               'rand' spreadmode is more prone to overlapped markers.
%
% 'GroupOrder'  [] (default) | cell array of strings
%               Order of groups for plotting, specified as a cell array of
%               strings. With multiple grouping variables, separate values
%               within each string with a comma. 
%
%               The default is [], which does not reorder the boxes.
%
%               Using categorical arrays as grouping variables is an easier
%               way to control the order of the boxes. 
%
%               By default, character and string grouping variables are
%               sorted in the order they initially appear in the data. If G
%               is categolical, categories(G) is used for sorting (see also
%               catetories() and reordercats() for more details).
%
%               When GroupOrder is provided and G is categorical,
%               GroupOrder will overwride the order of categories %TODO
%
% 'Marker'      Markers for the scattered symbols. You can specify a single
%               marker throughout (such as 'o' and 'x') or multiple markers
%               (such as 'ox*'). The sequence is replicated or truncated as
%               required. For example 'ox'gives columns that alternate in
%               marker type. The default is 'o'.
%
%               Accepted letters: 'o+*.xsd^v><pn'
%
% 'MarkerEdgeColor' 
%               MarkerEdgeColor for scattered symbols, specified as a
%               single color (such as 'r' or [1 0 0]) or multiple colors
%               (such as 'rgbm' or a three-column matrix of RGB values
%               where each row represents a group). The sequence is
%               replicated or truncated as required, so for example 'rb'
%               gives boxes that alternate in color. 'x' is for 'none'. 'a'
%               is for 'auto';
%
%               The default is [0, 0.4470, 0.7410] (default of plot())
%
% 'MarkerFaceColor'   
%               MarkerFaceColor for scattered symbols, specified as a
%               single color (such as 'r' or [1 0 0]) or multiple colors
%               (such as 'rgbm' or a three-column matrix of RGB values
%               where each row represents a group). The sequence is
%               replicated or truncated as required, so for example 'rb'
%               gives boxes that alternate in color. 'x' is for 'none'. 'a'
%               is for 'auto';
%               
%               The default is 'x' (none).
%
% 'MarkerSize'      
%               MarkerSize for scattered symbols, specified as a
%               scalar positive number (such as 0.6) or horizontal vector of
%               scalar positive numbers.
%               The sequence is replicated or truncated as required, so for
%               example [0.5, 1] gives boxes that alternate in size. 
%
%               The default is 6.
%
% 'ShowMean'    true | false  (default)
%               true shows mean value as a horizontal bar. Mean is
%               computated with 'omitnan' flag of mean(), ignoring NaN
%               values in inputs
%
% 'ErrorBar'   'sem' | 'std' | 'none' (default) 
%               Ignored if 'ShowMean' is false.
%               'sem' shows error bar as standard error of means
%               'std' shows error bar as standard deviation. std is
%               computed with 'omitnan' flag, ignoring NaNs in input.
%
% 'ShowBoxPlot' true | false (default)
%               true overlays box plot on scattered markers. Requires Statistics
%               Toolbox.
%
% 'BoxplotParam'
%               cell array row vector
%               Parameter/Value pairs in the cell row array format.
%               For example,
%
%               'BoxplotParam', {'boxstyle', 'filled', 'notch', 'on',...
%               'colors', 'br' }
%
% 'Outliers'    'show' | 'hide' (default)
%               Option to show or hide outliers for boxplot.
%               You can also hide outliers by the following code:
%               set(findobj(axh,'Tag','Outliers'),'Visible','off')
%
% 'GG'          The secondary grouping labeles that further divides data
%               with labels G. Containing category labels. 
%               cell vector of strings | char vector | categorical vector
%
% 'GGparams'    This is used with the GG paramters to explicitly specify the
%               color and markers for each unique values of GG. The value
%               for GGparams must be (non-)scalar structure that can have the 
%               following fields:
%
%                  'label', 'marker', 'markeredgecolor', 'markerfacecolor', 
%                  'markersize', 'visible'
%
%               The length of the structure must be the same as the number
%               of unique values in GG. The values in 'label' field must be
%               identical to the unique values in GG.
%
%               'GGparams' overrides parameters including 'markeredgecolor', 
%               'markerfacecolor', 'markersize'
%
%               Example: Edit GGparams.makersize values at once
%
%                    C = repmat({3}, size(GGparams));
%                    [GGparams(:).markersize] = C{:};
%
% See also
% boxplot, verticalScatPlot_test, Primitive Line Properties, getNforG,
% numbersandnames2XG, gscatter, gplotmatrix, grpstats, barXG
% compareXG, compare2
% doc Grouping Variables
%
% written by Kouichi C. Nakamura, Ph.D.
% kouichi.c.nakamura@gmail.com
% Kyoto University, Kyoto, Japan


%% parse inputs

narginchk(1, inf);

[X, G, width, binsize, axh, spreadmode, grouporder, showmean, errorbarmode, marker, ...
    markeredgecolor, markerfacecolor, markersize, showboxplot, boxplotparam, ...
    outliers, GG, GGparams] = local_parse(varargin{:});

if isempty(X)
    h = cell(0, 0);
    axh = [];
    return;
end

    

%% group X according to G

if ischar(G)
    g = cell(size(G, 1), 1);
    for i = 1:size(G, 1)
        g{i} = strtrim(G(i,:)); % make it cell array
    end
    clear i
    G = g; clear g;
end


%% grouporder

[U, Uind] = local_grouporder(G, grouporder);


%% process
XX = cell(length(U), 1);
if ~isempty(GG)
    GG_ = cell(length(U), 1);
else
    GG_ = {};
end

for i = 1:length(U)
    XX{i} = X(Uind == i);
    
    if ~isempty(GG)
        GG_{i} = GG(Uind == i);        
    end
    
end


h = cell(1, length(U));

for i = 1:length(U)
    if isempty(GG)
        thismarker = local_getthismarker(marker, i);
        thismarkeredgecolor = local_getthiscolor(markeredgecolor, i);
        thismarkerfacecolor = local_getthiscolor(markerfacecolor, i);
        thismarkersize = local_getthissize(markersize, i);
        thisGG = GG_;

    else
        thismarker = []; 
        thismarkeredgecolor = [];
        thismarkerfacecolor = [];
        thismarkersize = [];
        thisGG = GG_{i};

    end
    
    
    %% plot each category
    hg = hggroup('Tag',sprintf('Scattered Markers %d',i));
    
    switch spreadmode
        case 'rand'
            h{i} = doOneColmunRand(XX{i}, width, i, axh, thismarker, ...
                thismarkeredgecolor, thismarkerfacecolor, thismarkersize,...
                thisGG, GGparams);
        case 'grid'
            h{i} = doOneColumnGrid(XX{i}, width, i, binsize, axh, thismarker, ...
                thismarkeredgecolor, thismarkerfacecolor, thismarkersize, ...
                thisGG, GGparams);
    end
    
    if any(isgraphics(h{i})) %TODO
        gind = isgraphics(h{i});
        set(h{i}(gind),'Parent',hg);
        
        if showmean
            meanWidth = (width *0.75)/2; % set the half-width so that the mean bar covers 75% of the data spread
            errWidth = meanWidth * 0.25; % set the width of the error bar caps as 25% of the mean bar
            
            
            hg = hggroup('Tag',sprintf('Mean and Error Bars %d',i));
            
            meanval = mean(XX{i},'omitnan');
            H.mean(i) = plot([i-meanWidth, i+meanWidth], [meanval, meanval], 'LineWidth', 2, ...
                'Color', 'k', 'LineStyle', '-','Tag','Mean');
            
            %NOTE better not to use errorbar function for control of
            % whisker width
            switch errorbarmode
                case 'sem'
                    err = std(XX{i},'omitnan')/sqrt(length(XX{i}));
                case 'std'
                    err = std(XX{i},'omitnan');
                case 'none'
                    continue
            end
            H.errorbarh(i) =         plot([i, i],         ...
                [meanval - err, meanval + err], 'k-','Tag','Error Bar');
            H.errorbartipLowerh(i) = plot([i-errWidth, i+errWidth], ...
                [meanval - err, meanval - err], 'k-','Tag','Lower Tip');
            H.errorbartipUpperh(i) = plot([i-errWidth, i+errWidth], ...
                [meanval + err, meanval + err], 'k-','Tag','Upper Tip');
            
            set([H.mean(i),H.errorbarh(i),H.errorbartipLowerh(i),...
                H.errorbartipUpperh(i)],'Parent',hg);
            
        end
    end
    
end



if showboxplot
    
    if isempty(boxplotparam)
        boxplot(axh,X,G,'colors','k','grouporder',U,'widths',width);
    else
        boxplot(axh,X,G,'colors','k','grouporder',U,'widths',width,...
            boxplotparam{:});
    end
    
    boxploth.wU =      flipud(findobj(gca,'Tag','Upper Whisker'));
    boxploth.wL =      flipud(findobj(gca,'Tag','Lower Whisker'));
    boxploth.adU =     flipud(findobj(gca,'Tag','Upper Adjacent Value'));
    boxploth.adL =     flipud(findobj(gca,'Tag','Lower Adjacent Value'));
    boxploth.outl =    flipud(findobj(gca,'Tag','Outliers'));
    boxploth.boxes =   flipud(findobj(gca,'Tag','Box'));
    boxploth.medians = flipud(findobj(gca,'Tag','Median'));
        
    set(findobj('Type','hggroup','Tag',''),'Tag','Boxplot');%TODO
    
    set(boxploth.wU,'LineStyle', '-');
    set(boxploth.wL,'LineStyle', '-');
    
    set(boxploth.outl,'MarkerEdgeColor','k');
    
    if strcmp(outliers,'hide')
        set(findobj(axh,'Tag','Outliers'),'Visible','off');      
    end
end


set(axh,'Box','off','TickDir','out');
hold off

set(axh, 'XTickLabel', U', 'XTick', 1:length(U));

end

%--------------------------------------------------------------------------

function [h, axh] = doOneColmunRand(X, ~, x, axh, thismarker, ...
    thismarkeredgecolor, thismarkerfacecolor, thismarkersize, GG, GGparams)
% argument 'X' must be a column vector

% quite good already

[s, ind] = sort(X);

% remove NaN from the vector s
y = s(~isnan(s));

if ~isempty(GG)
    GGs = GG(ind);
    gg = GGs(~isnan(s));
else
    gg = {};
end

if isempty(y)
   h = NaN; 
   return
end

%%

len = length(y);
edges = min(y):(max(y)-min(y))/ceil(log10(len)+9):max(y);
% hist(y,bin);
n = histc(y,edges);
% figure;stairs(bin,n); % looks good
% figure;bar(n); % looks good
nratio = n./max(n);
% figure;bar(nratio);
% figure;stairs(bin,nratio);

j =2; % this is the key
spreadx = zeros(len,1);
for i = 1:len
    if y(i) < edges(j)
        spreadx(i)=(rand(1)-0.5)*nratio(j-1); % j-1 us the key
    elseif y(i) == edges(j)
        spreadx(i)=(rand(1)-0.5)*nratio(j-1);
    elseif y(i) > edges(j)
        j = j+1;
        spreadx(i)=(rand(1)-0.5)*nratio(j-1);
    end
end

%% plot

[h, axh] = local_plot(axh,x,y,spreadx,gg,GG,GGparams,...
    thismarker,thismarkeredgecolor,thismarkerfacecolor,thismarkersize);

end

%--------------------------------------------------------------------------

function [h, axh] = doOneColumnGrid(X, width, x, binsize, axh,thismarker, ...
    thismarkeredgecolor, thismarkerfacecolor, thismarkersize, GG, GGparams)
% argument 'X' must be a column vector
% working well

[s, ind] = sort(X);

y = s(~isnan(s));

if ~isempty(GG)
    GGs = GG(ind);
    gg = GGs(~isnan(s));
else
    gg = {};
end

if isempty(y)
   h = NaN; 
   return
end

%%
edges = linspace(min(y), max(y), binsize); 
n = histc(y, edges); 

interval = width/max(n); % horizontal interval between dots


xgrid = zeros(max(n), 1);
for i = 1:max(n) % for each bin
    if rem(i, 2) % odd number
        xgrid(i) =  interval * floor(i/2);
    else % even number
        xgrid(i) = -1 * interval * floor(i/2);
    end
end
%xgrid = [0, interval, -interval, interval*2, -interval*2, ..];


%% assign x values for each element of s
% shuffle xgrid(1:n(i))

k = 0;
spreadx = zeros(length(y), 1);
for i = 1:length(edges) % for each bin
    xi = xgrid(1:n(i));
    ind = randperm(n(i));
    xi(ind);
    spreadx(k+1:k+n(i), 1) = xi(ind);
    k = k + n(i);
end



%% add a little noise in spreadx

spreadxx = zeros(size(spreadx));
for i = 1:length(spreadx)
    spreadxx(i) = spreadx(i) + (rand(1)-0.5)*interval*0.5 ;
end

%% plot
%TODO gg is not defined
[h, axh] = local_plot(axh,x,y,spreadxx,gg,GG,GGparams,...
    thismarker,thismarkeredgecolor,thismarkerfacecolor,thismarkersize);


end
%--------------------------------------------------------------------------
function [h, axh] = local_plot(axh,x,y,spreadx,gg,GG,GGparams,...
    thismarker,thismarkeredgecolor,thismarkerfacecolor,thismarkersize)

if ~exist('axh', 'var')
    axh = axes;
end

if isempty(GG)
    h = plot(axh, spreadx + x, y, 'Marker',thismarker, 'LineStyle', 'none', ...
        'MarkerEdgeColor', thismarkeredgecolor,...
        'MarkerFaceColor', thismarkerfacecolor,...
        'MarkerSize', thismarkersize,...
        'Tag','Marker');
else % subgrouping

    [UU, UUind] = local_grouporder(gg, []);
    if verLessThan('matlab','8.4.0')
        % execute code for R2014a or earlier
        h = zeros(length(UU), 1);
    else
        % execute code for R2014b or later
        h = gobjects(length(UU), 1);
    end
    for i = 1:length(UU)
    
        indGG = find(strcmp(UU{i}, {GGparams(:).label}'));

        if any(UUind == i)
            h(i) = plot(axh, spreadx(UUind == i) + x, y(UUind == i), ...
                'LineStyle', 'none', ...
                'Marker', GGparams(indGG).marker, ...
                'MarkerEdgeColor', GGparams(indGG).markeredgecolor,...
                'MarkerFaceColor', GGparams(indGG).markerfacecolor,...
                'MarkerSize', GGparams(indGG).markersize,...
                'Visible', GGparams(indGG).visible,...
                'Tag','Marker');
        end
        
    end    
    
end
end

%--------------------------------------------------------------------------

function [U, Uind] = local_grouporder(G, grouporder)
% local_grouporder reorders grouping variable G according to grouporder and
% returns the reordered categories U and reordering indices Uind
%
% INPUT ARGUMENTS
% G           Grouping variables
%
% grouporder  [] | cell array
%             a cell array containing the names of the grouping variables.
%             If you have multiple grouping variables, separate values with
%             a comma. You can also use categorical arrays as grouping
%             variables to control the order of the boxes.
%
%
% OUTPUT ARGUMENTS
% U           grouporder ready to be used for boxplot
%
% Uind        U(Uind) == G 
%
%

[U, Gind, Uind] = unique(G);

if ~iscategorical(G)
    if ~isempty(grouporder) % grouporder is specified
        
        assert( isequal(union(grouporder, U), intersect(grouporder, U)) && ...
            numel(grouporder) == numel(U), ...
            'K:verticalScatPlot:grouporder:invalid',...
            'grouporder is invalid. It must contain all the category names in G.');
        
    elseif iscellstr(G) ||  ischar(G) || isreal(G) || isstring(G)
        if isstring(G)
            G = cellstr(G);
        end
        
        % order as they appear
        grouporder = G(sort(Gind));
        
    else
        error('unexpected format of G or grouporder')
    end
    
    % change the order of categories according to grouporder

    [~, sort1] = sort(grouporder);
    Uind = arrayfun(@(x) sort1(x), Uind);
    
    U = grouporder;

elseif iscategorical(G)
    if isempty(grouporder)
    
        grouporder = categories(G);
        
        included = ismember(grouporder,U);
        U = grouporder(included);
        
        [~,Uind] = ismember(G,U);
    
    else % grouporder is specified
        % grouporder overrides the order of categories
        %TODO
        
        keyboard %TODO
        
        [~, sort1] = sort(grouporder);
        Uind = arrayfun(@(x) sort1(x), Uind);
        
        U = grouporder;
    end
    
    %     grouporder = cellstr(G(sort(Gind))); %TODO
    
end


end

%--------------------------------------------------------------------------

function thiscolor = local_getthiscolor(colors, i) 
if ischar(colors)
    if length(colors) == 1
        % such as 'b'
        thiscolor = colors;
    elseif length(colors) > 1
        % such as 'rgbm'
        
        switch rem(i, length(colors))
            case 0
                thiscolor = colors(end);
            otherwise
                thiscolor = colors(rem(i, length(colors)));
        end
    end
    
    switch thiscolor
        case 'x' 
            thiscolor = 'none';
        case 'a'
            thiscolor = 'auto';
    end    
    
elseif isnumeric(colors)
    assert(size(colors,2) == 3)
    switch rem(i, size(colors,1))
        case 0
            thiscolor = colors(end, :);
        otherwise
            thiscolor = colors(rem(i, length(colors)), :);
    end
end
end

%--------------------------------------------------------------------------

function thismarker = local_getthismarker(marker, i)
if ischar(marker)
    if length(marker) == 1
        % such as 'o'
        thismarker = marker;
    elseif length(marker) > 1
        % such as 'o+v'
        
        switch rem(i, length(marker))
            case 0
                thismarker = marker(end);
            otherwise
                thismarker = marker(rem(i, length(marker)));
        end
    end
elseif isnumeric(marker)
    error('K:verticalScatPlot:local_getthismarker', 'invalid marker');

end

end

%--------------------------------------------------------------------------

function thismarkersize = local_getthissize(markersize, i)


    switch rem(i, length(markersize))
        case 0
            thismarkersize = markersize(end);
        otherwise
            thismarkersize = markersize(rem(i, length(markersize)));
    end


end

%--------------------------------------------------------------------------

function TF = iscolorspecmarker(colorSpec)
% TF = iscolorspecmarker(colorSpec)

TF = false;

if ~isempty(colorSpec) && isrow(colorSpec)
    
    if isnumeric(colorSpec) ...
            && length(colorSpec) == 3 &&  all(colorSpec >= 0 & colorSpec <= 1)
        
        TF = true;
        
    elseif ischar(colorSpec)
        if  ismember(lower(colorSpec), {'y','m','c','r','g','b','w','k'})
            TF = true;
            
        elseif ismember(lower(colorSpec),...
                {'yellow','magenta','cyan','red','green','blue','white','black', 'none', 'auto'});
            TF = true;
        end
    end
end

end

%--------------------------------------------------------------------------

function TF = ismarkersingleletter(mark)
% TF = ismarkersingleletter(mark)
%

p = inputParser;
p.addRequired('mark', @(x) ischar(x) && isscalar(x));  

TF = false;

if ~isempty(mark) && isrow(mark)
    if ischar(mark)
        if ismember(lower(mark),...
                {'+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '<','>', 'p', 'h'})
            TF = true;
        end
    end
end

end

%--------------------------------------------------------------------------

function [X, G, width, binsize, axh, spreadmode, grouporder, showmean,...
    errorbarmode, marker, markeredgecolor, markerfacecolor, markersize, ...
    showboxplot, boxplotparam, outliers, GG, GGparams] = local_parse(varargin)

p = inputParser;

if isscalar(varargin{1}) && isgraphics(varargin{1},'axes')
    axh = varargin{1} ;
    X = varargin{2};
    paramvals = varargin(3:end);
else
   axh = [];
   X = varargin{1};
   paramvals = varargin(2:end);
end


vfx = @(x) isempty(x) || isvector(x) && isreal(x);
p.addRequired('X', vfx);

vfg = @(x) isempty(x) || ...
    (isvector(x) && length(x) == length(X) &&...
    (iscellstr(x) || isnumeric(x) || iscategorical(x) || isstring(x)))...
    || ismatrix(x) && ischar(x) && size(x,1) == length(X)  ;
p.addOptional('G',[], vfg);

vfw = @(x) isscalar(x) && isreal(x) && x >= 0;
p.addParameter('Width', 0.8, vfw);

vfb = @(x) isscalar(x) && isreal(x);
p.addParameter('BinSize', 20, vfb);

vfmode = @(x) isrow(x) && ischar(x) && ismember(lower(x), {'rand','grid'});
p.addParameter('SpreadMode', 'grid', vfmode);

vfgr = @(x) iscellstr(x) && isvector(x);
p.addParameter('GroupOrder', [], vfgr);

vfmean = @(x) isscalar(x) && x == 0 || x == 1;
p.addParameter('ShowMean', false, vfmean);

vferr = @(x) ischar(x) && isrow(x) && ismember(lower(x), {'sem','std','none'});
p.addParameter('ErrorBar', 'none', vferr);

vfmarker = @(x) ismarkersingleletter(x) || ...
    (ischar(x) && isrow(x) &&  all(arrayfun(@ismarkersingleletter, x)));

p.addParameter('Marker', 'o', vfmarker);

vfcolor = @(x) iscolorspecmarker(x) || ...
    (ischar(x) && isrow(x) &&  all(arrayfun(@iscolorspecmarker, x))) || ...
    (isnumeric(x) && size(x, 2) == 3 && all(all(x >= 0 | x <= 1)));
p.addParameter('MarkerEdgeColor', [0, 0.4470, 0.7410], vfcolor);
p.addParameter('MarkerFaceColor', 'x', vfcolor);

vfsize = @(x) isreal(x) && isrow(x) && all(x > 0);

p.addParameter('MarkerSize', 6, vfsize);

vfbxp = @(x) isscalar(x) && x == 0 || x == 1;
p.addParameter('ShowBoxPlot', false, vfbxp);

vfbxparam = @(x) iscell(x) && isrow(x) && rem(length(x), 2) == 0 ;
p.addParameter('BoxplotParam', [], vfbxparam);

p.addParameter('Outliers', 'hide', @(x) ischar(x) && isrow(x) &&...
    ismember(x,{'show','hide'}));

p.addParameter('gg', [], vfg);

forggstr = {'label', 'marker', 'markeredgecolor', 'markerfacecolor', ...
    'markersize', 'visible'};
vfGGparams = @(x) isstruct(x) && all(ismember(lower(fieldnames(x)), forggstr));
p.addParameter('GGparams', struct, vfGGparams);

p.parse(X, paramvals{:});

G               = p.Results.G;
width           = p.Results.Width;
binsize         = p.Results.BinSize;
spreadmode      = lower(p.Results.SpreadMode);
grouporder      = p.Results.GroupOrder;
showmean        = logical(p.Results.ShowMean);
errorbarmode    = lower(p.Results.ErrorBar);
marker          = p.Results.Marker;
markeredgecolor = p.Results.MarkerEdgeColor;
markerfacecolor = p.Results.MarkerFaceColor;
markersize      = p.Results.MarkerSize;
showboxplot     = logical(p.Results.ShowBoxPlot);
boxplotparam    = p.Results.BoxplotParam;
outliers        = lower(p.Results.Outliers);
GG              = p.Results.gg;
GGparams        = p.Results.GGparams;


if isvector(X) && isrow(X)
   X = X';
end

if isvector(G) && isrow(G)
    G = G';
end

if isempty(G) && ~isempty(X)
    G = num2str(ones(size(X)));    
end

assert(length(X) == length(G), 'verticalScatPlot:XG:lengthmismatch', ...
    'X and G must have the same length.');

if isnumeric(G)
    %TODO numeric G will cause problems because you can't define grouporder
    G = num2str(G); %workaround
end


if ~isempty(GG)
    assert(length(X) == size(GG, 1), 'verticalScatPlot:XGG:lengthmismatch', ...
    'X and GG must have the same number of rows');
end


if isempty(axh)
    figure;
    axh = axes;
    hold on;
else
    axes(axh);
    hold on;
end

% if showboxplot
%     showmean = false;
% end

if isrow(grouporder)
    grouporder = grouporder';
end

% if isempty(grouporder) && iscategorical(G) %TODO
%     grouporder = categories(G);
% end

if ischar(markeredgecolor) 
    switch lower(markeredgecolor)
        case 'none'
            markeredgecolor = 'x';
        case 'auto'
            markeredgecolor = 'a';
    end
end

if ischar(markerfacecolor)
    switch lower(markerfacecolor)
        case 'none'
            markerfacecolor = 'x';
        case 'auto'
            markerfacecolor = 'a';
    end
end

if ~isempty(GG)
    uniqueGG = unique(GG);
    
    assert(length(uniqueGG) <= length(GGparams),...
        'K:verticalScatPlot:local_parse:GGparams:invalid:length',...
        'The length of structure GGparams must be equal to or larger than the number of unique values in GG');
    
    assert(isequal(sort({GGparams(:).label}), unique({GGparams(:).label})), ...
        'K:verticalScatPlot:local_parse:GGparams:notunique',...
        'GGparams.label must contain unique values');
    
    assert(all(ismember(uniqueGG,{GGparams(:).label})), ...
        'K:verticalScatPlot:local_parse:GGparams:invalid:label',...
        'GGparams.label must contain all the unique values in GG');
end

if ~isequaln(GGparams, struct) && markersize ~= 6
    warning off backtrace
    warning('K:verticalScatPlot:local_parse:markersize:overridden',...
        '"markersize" option''s value %f is overridden by "GGparams"', ...
        markersize);
    warning on backtrace
end

GGparams = local_prep_forGG(GGparams);

end


%--------------------------------------------------------------------------

function GGparams = local_prep_forGG(GGparams)

p = inputParser;
p.addRequired('GGparams', @isstruct);
p.parse(GGparams);

forggstr = {'label', 'marker', 'markeredgecolor', 'markerfacecolor',...
    'markersize', 'visible'};

fin = fieldnames(GGparams);
missing = setdiff(forggstr, fin);

if ~isempty(fin)
    assert(~ismember('label', missing));
end

for i = 1:length(missing)
    
    switch missing{i}
        %if missing fill with default values
        case 'marker'
            R = repmat({'o'}, size(GGparams));
            [GGparams(:).marker] =  R{:};
            
        case 'markeredgecolor'
            R = repmat({'b'}, size(GGparams));
            [GGparams(:).markeredgecolor] = R{:};
            
        case 'markerfacecolor'
            R = repmat({'none'}, size(GGparams));
            [GGparams(:).markerfacecolor] = R{:};
            
        case 'markersize'
            R = repmat({6}, size(GGparams));
            [GGparams(:).markersize] = R{:};
            
        case 'visible'
            R = repmat({'on'}, size(GGparams));
            [GGparams(:).visible] =  R{:};
            
        case 'label'
            R = repmat({''}, size(GGparams));
            [GGparams(:).label] =  R{:};
            
        otherwise
            error('local_prep_forGG:missing:invalid',...
                'unexpected fieldname in GGparams');
    end
    
    
    
end





end
