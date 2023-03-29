function obj = setTparamsValues(obj,tf,spikeWin,varargin)
%
% obj = setTparamsValues(obj,tf,spikeWin)
%

p = inputParser;
p.addRequired('obj');
p.addRequired('tf',@(x) iscolumn(x) && all(x == 0 | x == 1));
p.addRequired('spikeWin',@(x) numel(2) && isrow(x) && all(x >= 0));
p.addParameter('save',true,@(x) isscalar(x) && x == 1 || x == 0);

p.parse(obj,tf,spikeWin,varargin{:});

dosave = p.Results.save;

assert(length(tf) == sum(obj.chanSpec.ChanNum))
ALLIND = find(tf)'; % row vector of index

chSp = obj.chanSpec;

n = nnz(tf);
fprintf('%d channels to process\n',n);

counts = 0;
for allind = ALLIND
    counts = counts + 1;
    
    if round(counts/n*100) > round((counts-1)/n*100)
        fprintf('*')
    end
    
    [m,ch] = chSp.allind2matindchanind(allind);
    
    newT = prepareNewT(obj,spikeWin,m,ch);
        
    obj = updateT(obj,newT,m,ch); 
    
end

if dosave
    if counts > 0
        
        saveTparams(obj);
        
    end
else

end