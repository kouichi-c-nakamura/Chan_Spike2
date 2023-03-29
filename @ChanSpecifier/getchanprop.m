function out = getchanprop(chanSpec, chanpropname,varargin)
% getchanprop is a wrapper of ChanSpecifier.getstructNby1. It returns a
% N by 1 column vector of values for a field of channels that is specified
% by "chanpropname". 
%
% In case only subset of channels contain that field "chanpropname",
% channels without that field will be ignored. %TODO to be tested
%
% out = getchanprop(chanSpec, chanpropname)
% out = getchanprop(chanSpec, chanpropname,TF)
% out = getchanprop(chanSpec, chanpropname,,m,ch)
%
%
% See also
% ChanSpecifier.getstructNby1

%% Parse

narginchk(1,4);

p = inputParser;
p.addRequired('chanSpec');

vf = @(x) ischar(x) && isrow(x);
p.addRequired('chanpropname', vf);

switch nargin 
    case 3
        p.addOptional('TF',[],@(x) iscolumn(x) && all(x == 0 | x == 1));
        
        p.parse(chanSpec, chanpropname,varargin{:});
        
        TF = p.Results.TF;

    case 4
        vfscposint = @(x) isscalar(x) && fix(x) == x && x > 0;
        p.addOptional('m', [],vfscposint);
        p.addOptional('ch',[],vfscposint);
        
        p.parse(chanSpec, chanpropname,varargin{:});
        
        m  = p.Results.m;
        ch = p.Results.ch;

        allind = chanSpec.matindchanind2allind(m,ch);
        
        TF = false(sum(chanSpec.ChanNum),1);
        TF(allind) = true;
    otherwise
        TF = [];
end


if isempty(TF)
   TF = true(sum(chanSpec.ChanNum),1); 
end
    

if ~all(TF)
   % narrow it down
    chanSpec = chanSpec.choose(TF);
    
end

S = getstructNby1(chanSpec, chanpropname);

out = {S(:).(chanpropname)}';

if ~iscellstr(out)
    if all(cellfun(@(x) isnumeric(x), out)) || all(cellfun(@(x) islogical(x), out))
        out = cell2mat(out);
    end
end

end