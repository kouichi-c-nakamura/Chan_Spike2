
%% |ChanSpecifier| construction
%
%   chanSpec = ChanSpecifier(thisdir)
%
% To construct |ChanSpecifier| object |chanSpec|, use a valid folder path
% as an input argument. The constructor will look for |*.mat| files in that
% folder and store the metadata into |chanSSpec|.

dirpath = fileparts(which('WaveformChan.m'));

chanSpec = ChanSpecifier(dirpath)


%% List
% |List| property contains non-scalar (|nx1|) structure whose each element
% is similar to the output of the builtin |dir| function, but with
% additional fields |channels| and |parentdir|.

chanSpec.List

chanSpec.List(1)
chanSpec.List(2)


%% List.channels
%  |channels| field of the |List| property contains the list of channels.
%  Each channel is also in structure and this is a copy of structures
%  stored in a |.mat| file.

chanSpec.List(1).channels
chanSpec.List(1).channels.EEG



%% MatNames
% |MatNames| property contains the list of |.mat| file names in the folder
% |dir1|

chanSpec.MatNames


%% MatNamesFull
% |MatNamesFull| property contains the list of full path of |.mat| file
% names in the folder |dir1|

chanSpec.MatNamesFull

%% ParentDir
% |ParentDir| property contains the list of full path the folder |dir1|

chanSpec.ParentDir

%% ChanTitles
% |ChanTitles| property contains an column cell array and each cell
% contains the list of chantitles contained in a |.mat| file in the order
% that corresponds to |MatNames|

T = chanSpec.ChanTitles
T{1}

%% |ChanTitlesAll|
% The property |ChanTitlesAll| holds cell array of all chantitles
% included in |chanSpec|

chanSpec.ChanTitlesAll


%% |ChanTitlesMatNamesAll|
% The property |ChanTitlesMatNamesAll| holds cell array of all chantitles
% included in |chanSpec| together with the names of their parental |.mat| files

chanSpec.ChanTitlesMatNamesAll


%% MatNum
% |MatNum| property contains the number of |.mat| files that are listed in
% |List|

chanSpec.MatNum

%% ChanNum
% |ChanNum| property contains a column vector of the number of channels that are listed in
% |List| in the order of |MatNames|

chanSpec.ChanNum


%% ChanSpecifer object without content
%
% You can construct sort of 'empty' ChanSpecifier by calling the constructor without
% an input argument.
%
%   chanSpec0 = ChanSpecifier
%
% This is useful in case where you want to construct a non-empty object by
% assigning values to properties one by one.

chanSpec0 = ChanSpecifier

%%
% Note that it is *NOT* defined to be empty for you cannot access to
% properties of an empty object. An empty object cannot be used as a seed
% to construct non-empty object.

isempty(chanSpec0) % false