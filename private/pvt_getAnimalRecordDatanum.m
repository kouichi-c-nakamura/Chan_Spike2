function [xnames, xnamesfull, xdatenum] = pvt_getAnimalRecordDatanum(xdir, affix)
% [xnames, xnamesfull, xdatenum] = pvt_getAnimalRecordDatanum(xdir, affix)
%
% INPUT ARGUMENTS
% xdir      a valid directory path
%
% affix     a string (char tyipe) for file name prefix and/or suffix
%           and a wildcard(*) that are common to the "source" files.
%           Multiple wildcard characters are not accepted. The "source"
%           file anmes and "destination" file names must be identical
%           except those affixes. In other words, the wildcards represent
%           the identical part of the file names for the two folders.
%
%           srcaffix can also take negation in the format
%           '*.mat|*_info.mat|*_sp.mat', where | serve as a delimiter and
%           the expressions after the first demilimiter is for negation
%           (names of files to be ginored). Only one wild card is allowed
%           for each file name expression. In the following example
%
%               '*.mat|*_info.mat|*_sp.mat'
%
%           files that matches '*.mat' will be searched except those match
%           '*_info.mat' or '*_sp.mat'. The delimiter and negative
%           expressions are optional.
%
% OUTPUT ARGUMENTS
% xnames    File names (column of cell array) only containing Animal ID (kjx) and
%           Record ID (a01)
%
% xnamesfull
%           Full path file names in a column of cell array
%
% xdatenum  Datenum for each file's last modified date
%
%
% See also
% K_checkmerge, K_syncSmrXlsxMat

[xaffix, xnegaffixC] = pvt_parseaffix(affix);

[xnames, xnamesfull, xdatenum] = pvt_getfilenameswithoutaffix(xdir, xaffix);


if ~isempty(xnegaffixC)
    xnamesnegfull = {};
    for i = 1:length(xnegaffixC)
        [~, tempfull] = pvt_getfilenameswithoutaffix(xdir, xnegaffixC{i});
        xnamesnegfull = [xnamesnegfull; tempfull];
    end
    clear buffer
else
    xnamesnegfull = {};
end

% exclude those specified by affixes after the delimiter |
[xnamesfull, iax] = setdiff(xnamesfull, xnamesnegfull);

% return only animal ID and record ID + trailing identifiers (big,  small
% etc) for xnames

xnames = xnames(iax);

xnames = cellfun(@(x) char(regexp(x, ...
    '^[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}\d\d(\w*(?=@)|\S*(?=\.)|\S*$)', 'match')),xnames,...
    'UniformOutput',false);

xdatenum = xdatenum(iax);

end
