function pvt_chanSpec_save_result(chanSpec, result, destdir, outname, errorid)
% pvt_chanSpec_save_result saves variable result into .mat file in destdir,
% if specified, or a subfolder 'results' of chanSpec.ParentDir.
%
% pvt_chanSpec_save_result(chanSpec, result, destdir, outname, errorid)
%
%
% INPUT ARGUMENTS
%
% chanSpec       A ChanSpecifier object. Only ParentDir property is needed.
%
% result         Variable of any type.
%
% destdir        Target directory. If empty '', then a subfolder 'results' of
%                chanSpec.ParentDir will be used.
%
% outname        A specified file name for saving.
%
% errorid        Error id string in the format 'blah:blah' or  'blah:blah:blah:....:blah'
%
% See also
% ChanSpecifier, chanSpec_getPowerSpectra, chanSpec_getPhasehistAgainstEEG, ChanSpecifer.getstats

if isempty(result)
    warning('K:pvt_chanSpec_save_result:result:empty',...
        'result %s is empty for %s.', inputname(1), outname);
    
    save(fullfile(destdir, outname), 'result');
    disp(fullfile(destdir, outname));
    return
end


if isempty(destdir) && all(strcmp(chanSpec.ParentDir{1}, chanSpec.ParentDir))
    
    matdir = chanSpec.ParentDir{1};
    destdir = fullfile(matdir, 'results');
    
    if ~isdir(destdir)
        mkdir(destdir);
    end
elseif isempty(destdir) && ~all(strcmp(chanSpec.ParentDir{1}, chanSpec.ParentDir))
    error(errorid, 'ParentDir values are not identical. You need to specify destdir input argument.');
end
save(fullfile(destdir, outname), 'result');
disp(fullfile(destdir, outname));

end