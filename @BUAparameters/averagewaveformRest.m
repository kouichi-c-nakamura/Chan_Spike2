function obj = averagewaveformRest(obj,varargin)
% averagewaveformRest runs averagewaveformOne for each recording files that
% has not added to obj.Tparams yet.
%
% See also
% BUAparameters.averagewaveformOne, BUAparameters.averagewaveformMany,

p = inputParser;
p.addRequired('obj',@(x) isscalar(x));
p.addOptional('tf',[],@(x) isvector(x) && all(x == 0 | x == 1));

p.parse(obj,varargin{:});

tf = p.Results.tf;

chSp = obj.chanSpec;

if isempty(tf)
    
   tf = true(sum(chSp.ChanNum),1);
    
end

assert(length(tf) == sum(obj.chanSpec.ChanNum))

counts = 0;
if chSp.MatNum > 0
    
    if ~isempty(tf)
        [~, ~, TFmat] = chSp.ismatvalid(tf);
    else
        TFmat = true(chSp.MatNum, 1);
    end
    
    
    status = true;
    for m = 1:chSp.MatNum
        
        if ~TFmat(m)
            continue
        end
        
        for ch = 1:chSp.ChanNum(m)
            
            if ~tf(sum(chSp.ChanNum(1:m-1))+ch)
                
                continue;
                
            end
            
            %% Special part for averagewaveformRest
            row = obj.mch2row(m,ch);
            
            if ~isempty(row)
                % the file is already done, so skip it!
                continue
            end
            
            %%

            [obj,spikeWin,status,figh] = averagewaveformOne(obj,m,ch,'call','batch');
            close(figh)
            
            switch status 
                case -1
                    % cancelled
                    break
                case 0
                   % unchanged (save it anyway)
                    counts = counts + 1;
                    continue
                case 1
                    counts = counts + 1;
                    continue
            end
        end
        
        if status == -1
            break
        end
    end
    
else
end

if counts > 0
   
    saveTparams(obj);
    
end


end

