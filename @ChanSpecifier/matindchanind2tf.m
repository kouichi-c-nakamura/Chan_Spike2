function TF = matindchanind2tf(chanSpec,m,ch)
%
% %TODO this can take mch (n x 2) array as input for group processing
%
% TF = matindchanind2tf(chanSpec,m,ch)
%
%TODO matind as (n x 1) column vector?
% TF = matindchanind2tf(chanSpec,matind)
%
% See also
% ChanSpecifier.matindchanind2allind

vfscposint = @(x) isscalar(x) && x > 0 && fix(x) == x;
p = inputParser;
p.addRequired('chanSpec',@(x) isscalar(x));
p.addRequired('m',vfscposint);
p.addRequired('ch',vfscposint);
p.parse(chanSpec,m,ch);

allind = chanSpec.matindchanind2allind(m,ch);
TF = false(sum(chanSpec.ChanNum),1);
TF(allind) = true;

end