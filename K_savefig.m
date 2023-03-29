function K_savefig(outnamestem, resdir, figh)
% saves figure figh with the name outnamestem in resdir in .fig format
%
% K_savefig(outnamestem, resdir, figh)
%
% outnamestem     the stem of output file name in char string.
%
% resdir          A valid folder path for the destination.
%
% figh            Figure handle.
%
% NOTE: Won't work in the same way before and after R2014b
% NOTE: It seems it's quite hard to determine whether a figure has been updated from the saved version.
% 
% See also 
% savefigplus, K_savevar, printfig2EPSwithoutFaceAlpha

warning('K_savefig is not recommended. Use savefigplus instead')

narginchk(3, 3);

p = inputParser;
p.addRequired('outnamestem', @(x) ischar(x) && isrow(x));
p.addRequired('resdir', @(x) ischar(x) && isrow(x));

if verLessThan('matlab','8.4.0')
    p.addRequired('figh', @(x) isscalar(x) && isnumeric(x) && isreal(x) ...
        && strcmp(get(figh, 'Type'), 'figure'));
else
    p.addRequired('figh', @(x) isscalar(x) && isgraphics(x) ...
        && strcmp(get(figh, 'Type'), 'figure'));
end

p.parse(outnamestem, resdir, figh);
clear p


datetimestr = datestr(now, '_yyyy-mm-dd_HHMMSS');

if ~isdir(resdir)
   mkdir(resdir);     
end

outname1 = [outnamestem, datetimestr, '.fig'];
outname2 = [outnamestem, '.fig'];

if ~isempty(figh)
    %% To assess whether the fig has been updated
    % only when updated use savefig
    
    % it seems hard to examine the identity of figures
    % even when open the same .fig file twice, they are returned to be not
    % identical by isequal function.
    % Name, Position and Children properties are often differnet
    % XLabel, YLabel, ZLabel, Title and other properties of Children are often different
    
    % saveas(fig, filename) or savefig(H, filename)
    savefig(figh, fullfile(resdir, outname1));
    disp(fullfile(resdir, outname1));
    
    savefig(figh, fullfile(resdir, outname2)); % the latest
    disp(fullfile(resdir, outname2));


else
    warning off backtrace
    warning('Nothing has been saved by K_savefig.');
    warning on backtrace
    
end

end