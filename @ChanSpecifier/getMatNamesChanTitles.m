function varargout = getMatNamesChanTitles(chanSpec,varargin)
% 
% getMatNamesChanTitles()
% getMatNamesChanTitles(chanSpec,m,ch)
% getMatNamesChanTitles(chanSpec,allind)
% getMatNamesChanTitles(chanSpec,tf)
% 
% c = getMatNamesChanTitles(_____)
%
% When no output argument, getMatNamesChanTitles will print 
% "(m,ch) matname | chantitle"
% in Command Window
% 

narginchk(0,3);

c = chanSpec.ChanTitlesMatNamesAll;

switch nargin
    case 1
        tf = true(sum(chanSpec.ChanNum),1);

        out = chanSpec.getMatNamesChanTitles(tf);
        
        
    case 2
        x = varargin{1};
        if iscolumn(x) && length(x) == sum(chanSpec.ChanNum) && all(x == 0 | x == 1)
            
            out = c(x,:);
            
            
        elseif isvector(x) && isreal(x) && all(x > 0) && all(fix(x) == x)
            out = c(x,:);
            
        else
            error('wrong format of input argument %s',inputname(2))
        end
 
    case 3
        
        ms = [c{:,1}];
        
        TFm = ms == m;
        
        chs = [c{:,3}];
        
        TFch = chs == ch;
        
        out = c(TFm & TFch,:);
        
        
    otherwise
        error('wrong number of input arguments')
end

if nargout > 0
    varargout{1} = out;
elseif nargout == 0
    
    for i = 1:size(out,1)
       fprintf('(%d,%d) %s | %s\n',out{i,1},out{i,3},out{i,2},out{i,4}); 
    end
    
else
    error('too many output arguments')
    
end


end