function S = K_getupdatedf(varargin)
% S = K_getupdatedf(srcdir, srcaffix, destdir, destaffix)
% S = K_getupdatedf(src1dir, src1affix, src2dir, src2affix, destdir, destaffix)
%
%
% A wrapper of K_getupdated and K_getupdatedmerge. In addition to return a
% structure S, this will save text files that contains the name of files
% that need to be handled in a specified way (add, remove, or update). The
% text files can be used by the Spike2 script, ExportAsMat, via FileOpen()
% and Read() funcitons.
%
%
% WITH 4 INPUT ARGUMENTS
%
% srcdir    a valid folder path for the "source" files from which the "destination"
%           files are derived.
%
% srcaffix  a string (char tyipe) for file name prefix and/or suffix
%           and a wildcard(*) that are common to the "source" files.
%           Multiple wildcard characters are not accepted. The "source"
%           file anmes and "destination" file names must be identical
%           except those affixes. In other words, the wildcards represent
%           the identical part of the file names for the two folders.
%
% destdir   a valid folder path for the "destination" files that are derived
%           from the "source" files
%
% destaffix The same as src1affix but for destdir
%
% OUTPUT ARGUMENTS
% S          A structure.
%
% S.src_updateDest
%             This holds the names of the source files whose dependent
%             destination files need to be updated in the destination
%             folder destdir..
%
% S.src_addDest
%             This holds the names of the source files whose dependent
%             desination files need to be added in the destination folder
%             destdir.
%
% S.dest_rmDest
%             This holds the names of files that needs to be deleted in the
%             destination folder destdir..
%
% S.src       Equals to srcdir
% S.dest      Equals to destdir
%
% S.src_all
%             Names of all the relevent files in the Source directory.
%
% S.dest_all
%             Names of all the relevent files in the Destintion directory.%
%
%
% WITH 6 INPUT ARGUMENTS
%
% INPUT ARGUMENTS
% src1dir   a valid folder path for the "source" files from which the "destination"
%           files are derived. The files in this folder has more previledge
%           over other two folders: The existance of an extra file in this
%           folder means addition of the corresponding files are required
%           for the other tho folders. The absence of a file in this folder
%           compared to the other two folders means the corresponding files
%           need to be deleted from the other tho folders.
%
% src1affix a string (char tyipe) for file name prefix and/or suffix
%           and a wildcard(*) that are common to the "source" files.
%           Multiple wildcard characters are not accepted. The "source"
%           file anmes and "destination" file names must be identical
%           except those affixes. In other words, the wildcards represent
%           the identical part of the file names for the two folders.
%
% src2dir   a valid folder path for the "source" files from which the "destination"
%           files are derived.
%
% src2affix The same as src1affix but for destdir
%
% destdir   a valid folder path for the "destination" files that are derived
%           from the "source" files
%
% destaffix The same as src1affix but for destdir
%
%
%
% OUTPUT ARGUMENTS
% S         A structure.
%
% S.src1_updateDest
%             This holds the names of the "source1" files whose
%             corresponding "destination" files need to be updated in the
%             "destination" folder destdir.
%
% S.src1_addSrc2updateDest
%             This holds the names of the "source1" files whose
%             corresponding "source2" files need to be added in the
%             "source2"  folder src2dir, and then the corresponding files
%             need to be updated in the "destination" folder destdir.
%
% S.src1_addDest
%             This holds the names of files that needs to be added in the
%             "destination" folder destdir.
%
% S.src2_rmSrc2
%             This holds the names of files that needs to be deleted in the
%             "source2" folder src2dir.
%
% S.dest_rmDest
%             This holds the names of files that needs to be deleted in the
%             "destination" folder destdir.
%
% S.src1      Equals to src1dir
% S.src2      Equals to src2dir
% S.dest      Equals to destdir
%
%
% S.src1_all  Names of all the relevent files in the Source1 directory.
%
% S.src2_all  Names of all the relevent files in the Source2 directory.
%
% S.dest_all  Names of all the relevent files in the Destintion directory.
%
%
% 23 Feb 2015
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
%
%
% See also
% K_getupdated, K_getupdatedmerge,


narginchk(4,6);

assert( nargin == 4 || nargin == 6,...
    eid('nargin:invalid'),...
    'Number of input variables must be 4 or 6');

datetime = datestr(now, '_yyyy-mm-dd_HHMMSS');

switch nargin
    case 4
        S = K_getupdated(varargin{:});

        srcdir = varargin{1};
        destdir  = varargin{3};

        dirstr =  ['srcdir=%s\n', 'destdir=%s'];


        % save S.src_updateDest in the srcdir
        msg = sprintf(['The files in the folder "srcdir" whose corresponding files in the folder "destdir" need to be updated.\n', ...
                    dirstr],srcdir, destdir);

        fsave_getupdatedf(S.src_updateDest, srcdir, srcdir, ['updateDest',datetime,'.txt'], msg);


        % save S.src_addDest in the srcdir
        msg = sprintf(['The files in the folder "srcdir" whose corresponding files in the folder "destdir" are missing and need to be added.\n', ...
                    dirstr],srcdir, destdir);
        fsave_getupdatedf(S.src_addDest, srcdir, srcdir, ['addDest',datetime,'.txt'], msg);


        % save S.dest_rmDest in the destdir
        msg = sprintf(['The surplus files in the folder "destdir" that need to be deleted.\n', ...
            dirstr],srcdir, destdir);
        fsave_getupdatedf(S.dest_rmDest, destdir, destdir, ['rmDest',datetime,'.txt'], msg);


    case 6
        S = K_getupdatedmerge(varargin{:});

        src1dir = varargin{1};
        src2dir = varargin{3};
        destdir  = varargin{5};

        dirstr =  ['src1dir=%s\n', 'src2dir=%s\n', 'destdir=%s'];


        % save S.src1_updateDest in the src1dir
        msg = sprintf(['The files in the folder "src1dir" whose corresponding files in the folder "destdir" need to be updated.\n', ...
            dirstr], src1dir, src2dir, destdir);
        fsave_getupdatedf(S.src1_updateDest, src1dir, src1dir, ['updateDest',datetime,'.txt'], msg);


        % save S.src1_addSrc2updateDest in the src2dir
        msg = sprintf(['The files in the folder "src1dir" whose corresponding files in the folder "src2dir" are missing and need to be added and then the files in "destdir" must be updated/added.\n',...
            dirstr], src1dir, src2dir, destdir);
        fsave_getupdatedf(S.src1_addSrc2updateDest, src1dir, src2dir, ['addSrc2updateDest',datetime,'.txt'], msg);


        % save S.src1_addDest in the src1dir
        msg = sprintf(['The files in the folder "src1dir" whose corresponding files in the folder "destdir" are missing and need to be added.\n',...
            dirstr], src1dir, src2dir, destdir);
        fsave_getupdatedf(S.src1_addDest, src1dir, src1dir, ['addDest',datetime,'.txt'], msg);


        % save S.src2_rmSrc2 in the src2dir
        msg = sprintf(['The surplus files in the folder "src2dir" that need to be deleted.\n',...
            dirstr], src1dir, src2dir, destdir);
        fsave_getupdatedf(S.src2_rmSrc2, src2dir, src2dir, ['rmSrc2',datetime,'.txt'], msg);


        % save S.dest_rmDest in the destdir
        msg = sprintf(['The surplus files in the folder "destdir" that need to be deleted.\n',...
            dirstr], src1dir, src2dir, destdir);
        fsave_getupdatedf(S.dest_rmDest, destdir, destdir, ['rmDest',datetime,'.txt'], msg);

end



end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K:
%
%
% input argument
% str (Optional) string in char type (row vector)
%
% output argument
% eid an error id composed of 'K:(functionname):str'

narginchk(0, 1);
p = inputParser;
p.addOptional('str', '', @(x) isempty(x) || ischar(x) && isrow(x));
p.parse(varargin{:});
str = p.Results.str;

if isempty(str)
    str = '';
else
    str = [':', str];
end

[~,m,~] = fileparts(mfilename('fullpath'));

eid = ['K:', m, str];


end
