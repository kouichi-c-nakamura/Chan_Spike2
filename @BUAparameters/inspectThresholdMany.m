function inspectThresholdMany(obj,varargin)
%
% inspectThresholdMany(obj)
% inspectThresholdMany(obj,tf)
%
%
% See also
% BUAparameters.inspectThresholdOne, BUAparameters.averagewaveformMany

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
            figh = figure;
            inspectThresholdOne(obj,m,ch);
            
       
            while 1
                commandwindow
                strResponse = input('Do you want to continue? Y/N:', 's');
                if strcmpi('Y', strResponse)
                    
                    status = 1;
                    close(figh)
                    break;
                elseif strcmpi('N', strResponse)
                    status = 0;
                    close(figh)
                    break;
                else
                    eval(strResponse)
                end
            end
            
            if status < 1
                break
            end
            
        end
        
        
        if status < 1
            break
        end
        
    end
    
else
    
    
end
end