function S = getstructOne(chanSpec, m, ch)
% Returns the specified mat file structure or channel structure in
% chanSpec.
%
%   Smat = getstructOne(chanSpec, m)
%   Schan = getstructOne(chanSpec, m, ch)
%
% INPUT ARGUMENTS
% chanSpec     ChanSpecifier object
%
% m            An integer index for a *.mat file included in chanSpec.
%
% ch           An integer index for channels in the *.mat file specified by 
%              m in chanSpec.
%
% OUTPUT ARGUMENTS
% Smat         1x1 structure
%
%                   Smat = getstructOne(chanSpec, m)
% 
%                 is equivalent to
% 
%                   Smat = chanSpec.List(m);
%
% Schan        1x1 structure
%
%                   Schan = getstructOne(chanSpec, m, ch)
% 
%                 is equivalent to 
% 
%                   Schan = chanSpec.List(m).channels.(chanSpec.ChanTitles{m}{ch});
%
% See also
% ChanSpecifier.matindchanind2allind, ChanSpecifier.allind2matindchanind


narginchk(2,3);

% p = inputParser;
% p.addRequired('chanSpec');
% p.addRequired('m', @(x) isscalar(x) && fix(x) == x && x > 0 && x <= chanSpec.MatNum);
% p.addOptional('ch',  @(x) isscalar(x) && fix(x) == x && x > 0 && x <= chanSpec.ChanNum(m));
% p.parse(chanSpec, m, varargin{:});
% 
% ch = p.Results.ch;


switch nargin
    case 2
        S = chanSpec.List(m);
        
    case 3
        
        finames = fieldnames(chanSpec.List(m).channels);
        
        S = chanSpec.List(m).channels.(finames{ch});
        
end

end