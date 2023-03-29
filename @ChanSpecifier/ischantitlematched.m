function [TF, names] = ischantitlematched(chanSpec, expr)
% A wrapper of ischanvalid with @ismatchedany.
% [TF, names] = ischantitlematched(chanSpec, expr)
% 
%% INPUT ARGUMETS
% SYNTAX and OTHER INPUT ARGUMENTS
%
% [TF, names] = ischantitlematched(chanSpec, expr)
%
%    expr       Regular expression in char type string or cell array of
%               strings.
%               String (char type). A field name of a channel structure
%               (chanSpec.List.channels.xxxxx) that is to be evaluated
% 
%
%
%% OUTPUT ARGUMENTS
% TF            vertical vector of logical 
%               logical values for channels included in .mat files stored
%               in chanSpec object.
%               %TODO NOTE this format does not support an empty .mat file
%               that does not contain any channel in it. In other words,
%               you cannot select the empty .mat files with this method.
% 
% names         In order to tell which value is which, this cell array
%               column of strings has the same size as TF. It contains name
%               of each .mat files and title of each channel that
%               corresponds to the TF. Use names(TF) to get the names of
%               selected mat files and channels.
%
%% EXAMPLES
%
%      [TF, names] = ischantitlematched(chanSpec, 'probeA03e')
%      [TF, names] = chanSpec.ischantitlematched('probeA03e')
%
% Choose channel whose "location" is SNr or SNc
%      ischan_SNrOrSNc = chanSpec.ischanvalid('location', @(x) ismatchedany(x, 'SNr|SNc')');
%
% 'probeA03e" in files that contain SNr/SNc
%      ismat_SNrOrSNc = chanSpec.ismatvalid(TF & ischan_SNrOrSNc);
%
% Choose EEG chan
%      ischan_EEG = chanSpec.ischantitlematched('EEG|IpsiEEG');
%      is equivalent to:
%      ischan_EEG = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'EEG|IpsiEEG')');
%
%
% Choose event channels whose "title" end with "e"
%      ischan_probeA00e = chanSpec.ischantitlematched('probe[AB]\d\de');
%      is equivalent to:
%      ischan_probeA00e = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'probe[AB]\d\de')');
%
%
%
%% See also
% ChanSpecifier.ischanvalid, ChanSpecifier.ismatvalid, ChanSpecifier.choose, ismatchedany
%
% 19 Jun 2015
% Written by Dr Kouichi C. Nakamura
% kouichi.c.nakamura@gmail.com

%% parse
narginchk(2,2);


%% job
[TF, names] = ischanvalid(chanSpec, 'title', @(x) ismatchedany(x, expr));
    
end
