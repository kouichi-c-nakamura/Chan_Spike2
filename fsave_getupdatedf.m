function fsave_getupdatedf(names, parentdir, targetdir, thetxtfile, msg)
% fsave_getupdatedf add string information to the text file thetxtfile to
% specify the .smr that we need to export from. The string information is
% then to be used by ExportAsMat.s2s.
%
% fsave_getupdatedf(names, parentdir, targetdir, thetxtfile, msg)
%
% INPUT ARGUMENTS
% names      a field of the structure S, which is also a structure.
%
% parentdir   Parent directory path
%
% targetdir   the directory path in which a text file will be saved.
%
% thetxtfile  the name of the textfile including the file extension (.txt).
%
% msg         a string that clarify the content of the file.
%
% See also
% K_getupdatedf, ExportAsMat.s2s

if isempty(names)
    names = {};
else
    names_full  = strcat(parentdir, filesep, names);
    [~, names_, ext]= cellfun(@(x) fileparts(x), names_full, ...
        'UniformOutput', false);
    
    names = strcat(names_, ext);
end

names = [msg; names];

fid = fopen(fullfile(targetdir, thetxtfile), 'w');
fprintf(fid, '%s\n', names{:});
fclose(fid);

end