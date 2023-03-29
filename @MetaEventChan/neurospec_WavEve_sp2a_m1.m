function [f,t,cl,sc] = neurospec_WavEve_sp2a_m1(obj, waveform, varargin)
%[f,t,cl,sc] = neurospec_WavEve_sp2a_m1(obj, waveform, varargin)
%requires Neurospec 2.0


narginchk(2, inf);


p = inputParser;
vf = @(x) isa(x, 'WaveformChan');
addRequired(p, 'waveform', vf);
parse(p, waveform);

try
    [f,t,cl,sc] = sp2a_m1(0,obj.TimeStamps,waveform.Data,varargin);
catch ME1
    disp('Have you installed Neurospec 2.0?');
    throw(ME1);
end

end