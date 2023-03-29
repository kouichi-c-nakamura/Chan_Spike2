function [f,t,cl,sc] = neurospec_EveEve_sp2_m1(obj, eventchan, varargin)
%[f,t,cl,sc] = neurospec_WavEve_sp2a_m1(obj, waveform, varargin)
%requires Neurospec 2.0


narginchk(2, inf);

p = inputParser;
vf = @(x) isa(x, 'MetaEventChan');
addRequired(p, 'eventchan', vf);
parse(p, waveform);

try
    [f,t,cl,sc] = sp2_m1(0, obj.TimeStamps, eventchan.TimeStamps, varargin);
catch ME1
    disp('Have you installed Neurospec 2.0?');
    throw(ME1);
end

end