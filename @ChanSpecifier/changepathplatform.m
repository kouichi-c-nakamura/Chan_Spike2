function chanSpecOut = changepathplatform(chanSpec,basedir)
% changepathplatform converts path strings stored in chanSpec to 
% platform-matched format with a reference to a direcory path basedir, allowing 
% you to use ChanSpecifier object in a platform-independent manner
%
%   chanSpecOut = changepathplatform(chanSpec,basedir)
%
% INPUT ARGUMENTS
% basedir       A folder full path that can be used as a reference point.
%               basedir must be a valid path on the current platform.
%               basedir must be located at a higher level of hierarchy than
%               any of *.mat files referred to in chanSpec. 
%               In the parentdir strings in chanSpec, strings that precede
%               basedir will be raplaced with basedir.
%
% See also
% unipath, load, save, ChanSpecifier, setup, findbasedir

narginchk(2,2)
p = inputParser;
p.addRequired('chanSpec');
p.addRequired('basedir',@(x) ischar(x) && isrow(x) && isdir(x));
p.parse(chanSpec,basedir);

%%
list = chanSpec.List;

basedirsp = strsplit(basedir,filesep);

parentdir = {chanSpec.List(:).parentdir}';

loc = regexp(parentdir,basedirsp(end),'end');
assert(all(cellfun(@(x) isscalar(x) && isnumeric(x) && x > 0 && x == loc{1}, loc)));

oldbasedir = parentdir{1}(1:loc{1});

esc = @(x) regexptranslate('escape',x);

newparentdir = unipath(regexprep(parentdir,...
    ['^',esc(oldbasedir)],esc(basedir)));

[list(:).parentdir] = newparentdir{:};

for m = 1:length(chanSpec.List)

    chantitles = fieldnames(chanSpec.List(m).channels);
    for ch = 1:length(chantitles) 
            
		list(m).channels.(chantitles{ch}).parentdir = ...
            unipath(regexprep(chanSpec.List(m).channels.(chantitles{ch}).parentdir,...
            ['^',esc(oldbasedir)],esc(basedir)));
       
    end
end

chanSpecOut = chanSpec; % keep the class/subclass
chanSpecOut.List = list;

end