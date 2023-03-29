%% Record_demo
%
%% Construction of |Record| objects
%
% The simplest way is to specify the file path of a |.mat| file as the single
% input argument.
%
%   obj = Record(matfilepath)
%   % matfilename    Char type single input. Accepts a valid file path 
%   %                 (char type) of a .mat file that contains Spike2
%   %                generated structures of electrophysiological 
%   %                recordings
%
%   

dirpath1 = fileparts(which('WaveformChan.m'));

matname1 = 'kjx127a01@0-20_double.mat';

matfilepath = fullfile(dirpath1, matname1);

rec1 = Record(matfilepath);
disp(rec1)

rec1.chantitles

rec1.Chans

rec1.plot

%%
% You can delete a Chan object or more from a Record

rec2 = rec1.removechan('LTSmk');
rec2.chantitles

rec3 = rec1.removechan({'LTSmk', 'onset'});
rec3.chantitles


