%% Chan object methods

pathstr1 = fileparts(which('WaveformChan.m'));

S = load(fullfile(pathstr1,'kjx127a01@0-20_double.mat'));

finames = fieldnames(S);

S1 = S.(finames{1});

obj1 = Chan.constructChan(S1);
class(obj1)

%%
% Let's have a look at properties of EventChan
properties(obj1)

%%
% Let's have a look at methods of EventChan
methods(obj1)

%% |plot|

%  h = plot(obj)
%  h = plot(obj, 'Param', Value)
%  h = plot(obj, axh, 'Param', Value, ...)

obj1.plot


