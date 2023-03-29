function obj = averagewaveformMany(obj,varargin)
% obj = averagewaveformMany(obj)
% obj = averagewaveformMany(obj,tf)
%
% BUAparameters.averagewaveformMany
%
% See also
% BUAparameters.averagewaveformOne, BUAparameters.averagewaveformRest
% BUAparameters.inspectThresholdMany

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
ALLIND = find(obj.tf)'; % row vector of index


counts = 0;
for allind = ALLIND
    
    [m,ch] = chSp.allind2matindchanind(allind);
    
    [objout,spikeWin,status,figh] = averagewaveformOne(obj,m,ch,'call','batch');
    obj = objout; % for debug
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


% if chSp.MatNum > 0
%     
%     if ~isempty(tf)
%         [~, ~, TFmat] = chSp.ismatvalid(tf);
%     else
%         TFmat = true(chSp.MatNum, 1);
%     end
%     
%     
%     status = true;
%     for m = 1:chSp.MatNum
%         
%         if ~TFmat(m)
%             continue
%         end
%         
%         for ch = 1:chSp.ChanNum(m)
%             
%             if ~tf(sum(chSp.ChanNum(1:m-1))+ch)
%                 
%                 continue;
%                 
%             end
% 
%             [objout,spikeWin,status,figh] = averagewaveformOne(obj,m,ch,'call','batch');
%             obj = objout; % for debug
%             close(figh)
%             
%             switch status 
%                 case -1
%                     % cancelled
%                     break
%                 case 0
%                     % unchanged (save it anyway)
%                     counts = counts + 1;
%                     continue
%                 case 1
%                     counts = counts + 1;
%                     continue
%             end
%         end
%         
%         if status == -1
%             break
%         end
%     end
%     
% else
% end

if counts > 0
   
    saveTparams(obj);
    
end


end