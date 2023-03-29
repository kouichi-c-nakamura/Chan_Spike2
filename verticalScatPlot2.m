function  verticalScatPlot2(varargin)
% A wrapper of verticalScatPlot for two sets of data pairwise or not.
%
% verticalScatPlot2(A,B)
% verticalScatPlot2(____,'Param',value,...)
% verticalScatPlot2(axh,____)
%
%
% INPUT ARGUMENTS
% A,B         Numeric arrays of the same size.
%             They can contain NaN. If an element of A or B contains NaN,
%             then the corresponding paired elements in the othreB will be ignored from plotting.
%
% axh         (Optional) A scalar Axes handle
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'G'         char | cell array | numeric array | string array
%             Two elements row vectors holding grouping variables for A
%             (element 1) and B (element 2).
% 'Pairwise'  true (1) | false (0) (default)
%            If set to true, A and B are considered pairwise data.
%
% 'LineColor' colorspec
%             Color of joining lines.
%
% 'LineAlpha' 'off' (default) | 0 to 1
%             If you specify 'LineAlpha' value other than 'off', then the
%             connecting lines will be drawn with patch() rathar than
%             line() with 'EdgeAlpha' control for transparency
%
% 'Params'    cell array
%             Parameter and value pairs for verticalScatPlot
%
% See also
% verticalScatPlot, compare2
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 19-Nov-2016 21:13:33


narginchk(2,inf)

if isscalar(varargin{1}) && isgraphics(varargin{1},'axes')
    axh = varargin{1};
    
    narginchk(3,inf)

    varargin = varargin(2:end);

else
    axh = [];
end

p = inputParser;
p.addRequired('A',@(x) isreal(x));
p.addRequired('B',@(x) isreal(x));

p.addParameter('G', {'A','B'}, @(x) numel(x) ==2 && iscellstr(x) ||...
    ischar(x) || isreal(x) || isstring(x));

p.addParameter('Pairwise',false,@(x) isscalar(x) && x == 0 || x == 1);

p.addParameter('LineColor', defaultPlotColors(1), @(x) iscolorspec(x));

p.addParameter('LineAlpha', 'off', @(x) (ischar(x) && ismember(x,{'off'}))...
    || isreal(x) && isscalar(x) && x >=0 && x <= 1);

p.addParameter('Params',{},@(x) iscell(x) && isrow(x) && mod(numel(x),2) == 0);


p.parse(varargin{:});

A         = p.Results.A;
B         = p.Results.B;
G         = p.Results.G;
pairwise  = p.Results.Pairwise;
lineColor = p.Results.LineColor;
lineAlpha = p.Results.LineAlpha;
params    = p.Results.Params;



switch lower(class(G))
    case 'char'
        GA = {G(1)};
        GB = {G(2)};
    case 'cell'
        GA = G(1);
        GB = G(2);
    case 'string'
        GA = string(G(1));
        GB = string(G{2});
    otherwise
        error('unexpected data type for G')
end

if pairwise
    assert(isequal(size(A),size(B)))

    tfinclude = ~isnan(A) & ~isnan(B);

    A_ = A(tfinclude);
    B_ = B(tfinclude);

    g = [repmat(GA,numel(A_),1);...
        repmat(GB,numel(B_),1)];

    if isempty(axh)
        verticalScatPlot([A_(:);B_(:)],g,params{:});
        
        axh = gca;
        Aline = get(findobj(axh.Children,'Tag','Scattered Markers 1'),'Children');
        Bline = get(findobj(axh.Children,'Tag','Scattered Markers 2'),'Children');
    else
        
        child1 = axh.Children;
        
        verticalScatPlot(axh,[A_(:);B_(:)],g,params{:});
        
        child2 = axh.Children;
        
        setdiff(child2,child1);
        
        Aline = get(findobj(setdiff(child2,child1),'Tag','Scattered Markers 1'),'Children');
        Bline = get(findobj(setdiff(child2,child1),'Tag','Scattered Markers 2'),'Children');
        
    end
   
    [~,indA_] = sort(A_);
    [~,indB_] = sort(B_);
    
    [~,indA_rev] = sort(indA_);
    [~,indB_rev] = sort(indB_);
    
    
    hold on
    hg = hggroup;
    hg.Tag = 'Joining Lines';
    
    h = plot([Aline.XData(indA_rev); Bline.XData(indB_rev)],...
        [Aline.YData(indA_rev); Bline.YData(indB_rev)],...
        'Color',lineColor,'Parent',hg);
    
    for i = 1:length(h)
        h(i).Tag = 'connection line';
        h(i).DisplayName = sprintf('connection %d',i);
    end
    
    
    if ~isequal(lineAlpha,'off')
        set(h,'Color',[h(1).Color,lineAlpha]);
    end
    

else

    A_ = A(:);
    B_ = B(:);

    g = [repmat(GA,numel(A_),1);...
        repmat(GB,numel(B_),1)];
    
    if isempty(axh)
        verticalScatPlot([A_(:);B_(:)],g,params{:});
    else
        verticalScatPlot(axh,[A_(:);B_(:)],g,params{:});
        
    end

end


end
