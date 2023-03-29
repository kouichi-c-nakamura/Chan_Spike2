function [XG] = getXG(chanSpec, TFarray, labels, func, fields)
% getXG returns column vector of numeric values X and column vector of grouping cell string G
% each element of which holds relevant string label in labels, according to TFarray
% that specifies channels in ChanSpecifier object chanSpec and function handle func
% that takes values from fields fields of channels in the specified channels in chanSpec.
%
% [XG] = getXG(chanSpec, TFarray, labels, func, fields)
%
% INPUT ARGUMENTS
%
% TFarray, labels
%
% 		TFarray (logical array M by N) and labels (cell row vector of strings 1 by N)
% 		are paired keys that are used for categorization. The number of columns in TFarray
% 		and that of labels must be equal.
% 		Columns of TFarray are logical vectors used for ChanSpecifier.choose
% 		in order to select specific channels out of chanSpec (for example, from the
% 		substantia nigra of control animal recorded during slow wave activity with
% 		juxtacellular recording). Matching columns of lables are cell array of strings
% 		that are to be used for category labels.
%
% func
% 		func is funciton handle that takes one or more fields of channel
% 		(specified by the fields argument) as input argument
%
% fields
% 		field1, field2, ... is field names of channels in chanSpec
%
% Before running this function you need to add relevant new fields to channels in chanSpec
% chanSpec.List(x).(chantitle) in order to hold values obtained from computation on the
% corresponding Chan object etc.
%
% If channels specified by TFarray do not contain any of the fields referred to by fields
% then the function will issue an error.
%
% OUTPUT
% XG      A table including columns X, G, allind, matind, chanind, matname,
%         chantitle.
%         X and G are to be used for boxplot or verticalScatPlot, or a
%         column vector of cell array containing values at least some of
%         which is non-scalar.
%
% EXAMPLE
%
% TF1 = chanSpec.ischanvalid('location', @(x) isregespmatched(x, 'BZ'));
% TF2 = chanSpec.ischanvalid('location', @(x) isregespmatched(x, 'CZ'));
%
% label1 = 'BZ';
% label2 = 'CZ';
%
% func = @(x, y) x/y;
% fields = {'ratioSlow', 'ratioBeta'};
%
% [XG] = getXG(chanSpec, [TF1, TF2], {label1, label2}, func, fields);
%
%
%
%
% See also
% boxplot, verticalScatPlot, ChanSpecifier


dbstop if error

p = inputParser;
p.addRequired('chanSpec', @(x) isa(x, 'ChanSpecifier'));
p.addRequired('TFarray', @(x) all(all(x == 1 | x == 0)));
p.addRequired('labels', @(x) iscellstr(x));
p.addRequired('func', @(x) isa(x, 'function_handle'));
p.addRequired('fields', @(x) ischar(x) && isrow(x) || iscellstr(x) && isvector(x));
p.parse(chanSpec, TFarray, labels, func, fields);


assert(size(TFarray, 2) == size(labels, 2),'K:getXG:TFarray_lables:size:invalid',...
    'The number of columns (%d) of TFarray "%s" (%dx%d)  does not match the number of columns (%d) in labels "%s"(%dx%d)',...
    size(TFarray, 2), inputname(2), size(TFarray,1),size(TFarray,2), size(labels, 2),...
    inputname(3), size(labels,1),size(labels,2));

%%
if ischar(fields)
    fields = {fields};
end

n = length(fields);


assert(nargin(func) == n);

if chanSpec.MatNum == 0
    
    XG = table;
    XG.X = {};
    XG.G = {};
    
    XG.matname = {};
    XG.chantitle = {};
    
    XG.allind = {};
    XG.matind = {};
    XG.chanind = {};
    
    return
end

N = size(TFarray, 2);
x = cell(1, N);
g = x;
M = x;
CH = x;
AllIndex = x;
MatIndex = x;
ChanIndex = x;
ParentDir = x;
Location = x;
IsIdentified = x;

for i = 1:N % for each column of TFarray
    %     cSpc = chanSpec.choose(TFarray(:, i)); %TODO
    TF = TFarray(:, i);
    
    if nnz(TF) == 0
        x{1,i} = {};
        g{1,i} = {};
        continue;
    end
    
    k = 0;
    
    xcol = cell(nnz(TF), 1);
    gcol = xcol;
    matname = xcol;
    chantitle = xcol;
    parentdir = xcol;
    location = xcol;
    isidentified = false(nnz(TF), 1);
    allindex = zeros(nnz(TF), 1);
    matindex = zeros(nnz(TF), 1);
    chanindex = zeros(nnz(TF), 1);
    
    for m = 1:chanSpec.MatNum
        
        if ~isempty(TF) && ~any(TF(chanSpec.matind2allind(m)))
            continue
        end
        
        for ch = 1:chanSpec.ChanNum(m)
            
            if isempty(TF) || TF(chanSpec.matindchanind2allind(m,ch))

                k = k + 1;
                
                vals = cell(1, n);

                clear this
                this = chanSpec.getstructOne(m,ch);
                
                for fi = 1:n

                    vals{fi} = this.(fields{fi});
                    % 'MATLAB:nonExistentField'
                end
                clear fi
                
                Val = func(vals{:});
                
                xcol{k, 1} = Val;
                gcol(k, 1) = labels(i);
            
                matname{k} = this.parent;
                parentdir{k} = this.parentdir;
                chantitle{k} = this.title;
                try
                    location{k} = this.location;
                catch
                    location{k} = '';
                end
                try
                    isidentified(k) = this.isidentified;
                catch
                    isidentified(k) = false;
                end              

                allindex(k) = chanSpec.matindchanind2allind(m,ch);
                matindex(k) = m;
                chanindex(k) = ch;
            end
        end
        
    end
    
    x{1, i} = xcol;
    g{1, i} = gcol(:);
    
    M{1, i} = matname;
    CH{1, i} = chantitle;
    
    AllIndex{1,i} = allindex;
    MatIndex{1,i} = matindex;
    ChanIndex{1,i} = chanindex;
    ParentDir{1,i} = parentdir;
    Location{1,i}= location;
    IsIdentified{1,i}= isidentified;

end



if cellfun(@(i) all(cellfun(@(j) isscalar(j) && isnumeric(j), i)), x)
    % concatenate each column to make a numeric column vector
    X = (cellfun(@(i) vertcat(i{:}),x,'UniformOutput',false))';
    X = vertcat(X{:});
else
    % cell array column
    X = vertcat(x{:});
end

G = vertcat(g{:});

XG = table;

XG.X = X;
XG.G = G;

XG.matname = vertcat(M{:});
XG.chantitle = vertcat(CH{:});
XG.parentdir = vertcat(ParentDir{:});

XG.allind = vertcat(AllIndex{:});
XG.matind = vertcat(MatIndex{:});
XG.chanind = vertcat(ChanIndex{:});

XG.location = vertcat(Location{:});
XG.isidentified = vertcat(IsIdentified{:});


end