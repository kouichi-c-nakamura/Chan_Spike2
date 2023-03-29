% ChanSpecifier_methods_demo
%% |ChanSpecifier| object construction with a folder path
%%
clear;close all;clc;

dirpath = fileparts(which('WaveformChan.m'));

chanSpec = ChanSpecifier(dirpath)
%% Methods of |ChanSpecifier| object
%%
methods(chanSpec)
%% |ischanvalid|
% |ischanvalid| and |ismatvalid| serve for a similar purpose; selecting subset 
% of channels or mat files in a |ChanSpecifider| object. These two methods return 
% |TF| logical vector that represent all the channels in the object. 
% 
% Calling |choose| method with |TF| as the input argument will construct 
% a new ChanSpecifier object that contains only a subset of channels of your interest.
% 
% |[TF, names] = ischanvalid(chanSpec, chanpropname, func)|
% 
% |% chanpropname   filed name of channels|
% 
% |% func           function handle of a true-or-false function|
% 
% |% TF             logical vector for all the channels included in chanSpec|
% 
% |% names          the list of 'matfilename|chantitle' for all the channels|
% 
% You can see which channels are chosen in |TF| by executing: 
% 
% |names(TF)|
%%
% Find channels whose |meanfiringrate| is higher than 0.8
[TF, names] = chanSpec.ischanvalid('meanfiringrate', @(x) x > 0.8)
names(TF)
%% 
% In the following example, ismatched|any| returns true if |x| matches the 
% regular expression expr
% 
% |TF = ismatchedany(str, expression)|
%%
% Find channels whose |title| contains string |LTS|
[TF, names] = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'LTS'));
names(TF)
%% |ischantitlematched|
% A wrapper of |ischanvalid|. Useful when you want to choose channels based 
% on their chantitles with regular expression.
% 
% |[TF, names] = ischantitlematched(chanSpec, expr)|
% 
% |% expr        Regular expression in char type string or cell array of|
% 
% |%             strings.|
% 
% |%             String (char type). A field name of a channel structure|
% 
% |%             (chanSpec.List.channels.xxxxx) that is to be evaluated |
%%
[TF, names] = chanSpec.ischantitlematched('LTS');
%% 
% is equivalent to the following: 
%%
[TF2, names] = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'LTS'));

isequal(TF, TF2)
%% |ismatvalid|
% Similar to |ischanvalid|, but works with mat files. The out put is channel 
% basis+ the length of TF vector is equal to the sum of |chanSpec.ChanNum|
% 
% |[TF, names] = ismatvalid(chanSpec, matpropname, func)|
% 
% |% matpropname    a fieldname of chanSpec.List|
% 
% |% func           function handle of a true-or-false function|
% 
% |% TF             logical vector for all the channels included in chanSpec|
% 
% |% names          the list of 'matfilename|chantitle' for all the channels|
%%
% Find channels whose parental mat files contain string 'double' in their
% |name| field.
[TF, names] = chanSpec.ismatvalid('name', @(x) ismatchedany(x, 'double'))
names(TF)
%% 
% Without an input argument, all channels will be selected.
%%
TF  = chanSpec.ismatvalid;
all(TF)
%% 
% You can use the TF output of |ismatvalid| or |ischanvalid| as the input 
% argument of |ismatvalid| to select the parental |.mat| files.
%%
% Find channles whose parental mat file exceeds 4000000 bytes.
TF = chanSpec.ismatvalid('bytes', @(x) x > 4000000);

TF2 = chanSpec.ismatvalid(TF)
all(TF == TF2)
%% 
% 
%%
% Find channels whose |meanfiringrate| is higher than 0.8
[TF, names] = chanSpec.ischanvalid('meanfiringrate', @(x) x > 0.8);
names(TF)

% Select all the channels contained in the parental mat files.
% In this particualr example, because all the mat files contain the same data, all the mat
% files will be chosen.
TF2 = chanSpec.ismatvalid(TF);
names(TF2)
%% |ismatnamematched|
% A wrapper of ismatvalid specialized for matching 'name' field with regular 
% expression.
% 
% |[TF, names] = ismatnamematched(chanSpec, expr)|
%%
[TF, names] = ismatnamematched(chanSpec, 'double')
%% 
% is equivalent to the following:
%%
[TF2, names] = chanSpec.ismatvalid('name', @(x) ismatchedany(x, 'double'))

isequal(TF, TF2)
%% GUI option for |ismatvalid| and |ischanvalid|
% GUI is also available.
% 
% |TF = chanSpec.ismatvalid('gui')|
% 
% |TF = chanSpec.ischanvalid('gui')|
% 
% 
%% |choose|
% The mehtod |choose| is used in combination with |ismatvalid| and |ischanvalid|. 
% Use the output |TF| of |ismatvalid| or |ischanvalid| as the input argument.
% 
% |[chanSpecout] = chanSpec.choose(TF) |
% 
% |% TF            logical column vector that is output of ismatvalid |
% 
% |%               or ischanvalid |
% 
% |%|
% 
% |% chanSpecout  New ChanSpecfier object that contains only .mat files|
% 
% |               and channels that are specified by the input TF|
%%
% Find channels whose |meanfiringrate| is higher than 0.8
[TF, names] = chanSpec.ischanvalid('meanfiringrate', @(x) x > 0.8)

% Construct another ChanSpecifier object that contains only channels whose
% |meanfiringrate| is higher than 0.8
newChanSpec =chanSpec.choose(TF);
newChanSpec.ChanTitlesMatNamesAll
%% 
% 
%%
% Find channels whose |title| contains string |LTS|
[TF, names] = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'LTS'));
[newChanSpec] = chanSpec.choose(TF);
newChanSpec.ChanTitlesMatNamesAll
%% 
% Because |TF| vector is a logical vector, you can perform |AND| and |OR| 
% operations.
%%
% Find channels whose |meanfiringrate| is higher than 0.8
TF1 = chanSpec.ischanvalid('meanfiringrate', @(x) x > 0.8)

% Find channels whose |title| contains string |LTS|
TF2 = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'LTS'))
%% 
% *AND operation* : to select channels whose |meanfiringrate| is higher 
% than 0.8 AND |title| contains string |LTS|
%%
TF = TF1 & TF2
[newChanSpec1] = chanSpec.choose(TF);
newChanSpec1.ChanTitlesMatNamesAll
%% 
% *OR operation* : to select channels whose |meanfiringrate| is higher than 
% 0.8 OR |title| contains string |LTS|
%%
TF = TF1 | TF2
[newChanSpec2] = chanSpec.choose(TF);
newChanSpec2.ChanTitlesMatNamesAll
%% GUI for |choose|
% GUI is also available to construct subset of a ChanSpecifier object.
% 
% |[chanSpecout, TF, names] = chanSpec.choose('gui')|
% 
% Note that |TF| and |names| are for the sake of convinience. You can keep 
% record of what you have chosen in the dialog. They are about |chanSpec| rather 
% than |chanSpecout|.
% 
% 
%% |getstructNby1|
% This method allows you to create a N by 1 colum of structure array each element 
% of which represent a single channel and has fields that are common for all the 
% channels. For the fields that exist only for a subset of channels, they are 
% put in the |misc| field together. 
% 
% |list1 = chanSpec.getstructNby1;|
% 
% |list1 = chanSpec.getstructNby1();|
%%
list1 = chanSpec.getstructNby1()
%% 
% This method is powerful when you want to go through many channels across 
% many .mat files to compare certain values in the Variable Editor in a spreadsheet-like 
% look.
% 
% 
% 
% With an input argument |chanpropname| (string), you can subtract channels 
% that have the specified channels that contain |chanpropname| as a field name.
% 
% |list2 = chanSpec.getstructNby1(chanpropname) |
% 
% In the example below, the filed 'scale' only exist for waveform data. So 
% the output |list2| only contains waveform channels and thus it is a 3x1 structure 
% array.
%%
list2 = chanSpec.getstructNby1('scale') % exist only for some channels
%% |matnamesfull2matind|
% |matind = matnamesfull2matind(chanSpec, matnamesfull)|
% 
% With matnamesfull specified, this method will rertun matind, indices for 
% matfiles in cell columns.
%%
matind = chanSpec.matnamesfull2matind(chanSpec.MatNamesFull(1:2))
%% |chantitles2chanind|
% |chanind = chantitles2chanind(chanSpec, matnamesfull, chantitles)|
% 
% With matnamesfull and chantitles specified, this method will rertun chanind, 
% indices for channels, and matind, indices of matfiles, in cell columns.
%%
[chanind, matind] = chantitles2chanind(chanSpec, chanSpec.MatNamesFull([1,3]),...
    [{{'onset', 'EEG'}}, {{'onset', 'LTS'}}]);
%% 
% 
%%
chanind{:}
%% |constructFileList|
% FileList is a class that holds meta information about Record objects (RecordInfo 
% objects). In effect, FileList class is similar to ChanSpecifier class in many 
% ways. ChanSpecifier is designed to select specific subset of matfiles and channels 
% from a list of .mat files, whereas FileList is useful to create Excel spreadsheet 
% to store results of analyses (see saveSummaryXlsx).
% 
% |filelist = constructFileList(chanSpec, _____)|
% 
% is equivalent to the following
% 
% |filelist = FileList(chanSpec.MatNamesFull, _____);|
%%
filelist = chanSpec.constructFileList('Name', 'newfilelist')
filelist.List
%% |constructRecord|
% |rec = constructRecord(chanSpec, matindex)|
% 
% Constructs multiple Record onjects out of .mat files that are listed in 
% chanSpec and specified by matindex.
% 
% The example below is to construct Record objects out of the first and third 
% .mat files in |chanSpec.List|. The output is in cell array format in a cell 
% of which a |Record| object is stored.
%%
recs = chanSpec.constructRecord([1,3])

recs{1}

recs{1}.plot
%% 
% |rec = constructRecord(chanSpec, matnamesfull)|
% 
% You can also specify .mat files by their full names. Here full names must 
% be absolute paths.
%%
fullpaths = chanSpec.MatNamesFull;
recs = chanSpec.constructRecord(fullpaths([1,3]));

recs{1}

recs{1}.plot
%% 
% Many methods are available for Record objects and their content WaveformChan 
% objects and EventChan objects.
%%
methods(Record)
methods(WaveformChan)
methods(EventChan)
%% |eq|
% You can use |eq| or |==| operator for chanSpec objects.
%%
chanSpec == chanSpec % true

chanSpec2 = chanSpec;
chanSpec2.List(1).name = 'hoge';

chanSpec == chanSpec2 % false
%% |vertcat|, |horzcat|
% You can vertically concatenate chanSpec objects. Horizontal concatenaiton 
% is equivalent to vertical concatenation.
%%
chanSpec_cat = [chanSpec, chanSpec]

chanSpec_cat = [chanSpec; chanSpec]