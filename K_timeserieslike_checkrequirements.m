% test requirements for Chan class
% Shows warnings if any of requirements could not be found.
%
% 12/12/2013
% K.C.Nakamura, Ph.D
% kouichi.c.nakamura@gmail.com




%Chan requirements

clear;close all;clc;

%% MATLAB2013a or later

info.MATLAB = ver('MATLAB');
ver MATLAB

%% Signal Processing Toolbox

% n = 'pwelch';
% pat = '(?<=^.+[\\/]toolbox[\\/])[^\\/]+';
% regexp(which(n), pat, 'match', 'once')

info.signal = ver('signal');
ver signal

%% Statistics Toolbox
info.stats = ver('stats');
ver stats

%% Image processing toolbox

info.images = ver('images');
ver images

%% Wavelet Toolbox only for methods
info.wavelet = ver('wavelet');
ver wavelet

%% CircStat Toolbox

n ='circ_mean'; 
pat = '[\\/]CircStat\w*[\\/]';
info.circstats = regexp(which(n), pat, 'match', 'once');
fprintf('\nCircStat version:  %s\n', info.circstats);


%% Neurospec Toolbox

n ='sp2a_m1'; 
pat = '[\\/]neurospec\w*[\\/]';
info.neurospec = regexp(which(n), pat, 'match', 'once');
fprintf('\nneurospec version:  %s\n', info.neurospec);

%% sigTOOL

n ='sigTOOL'; 
pat = '\w*sigTOOL\w*[\\/]';
info.sigtool = regexp(which(n), pat, 'match', 'once');
fprintf('\nsigtool location:  %s\n', info.sigtool);

clear n pat

%% validate

if str2double(info.MATLAB.Version) < 8.1
   warning('Bad'); 
end

if isempty(info.signal) || str2double(info.signal.Version) < 6.19
   warning('Bad'); 
end

if isempty(info.stats) || str2double(info.stats.Version) < 8.2
   warning('Bad'); 
end

if isempty(info.images) || str2double(info.images.Version) < 8.2
   warning('Bad'); 
end

if isempty(info.wavelet) || str2double(info.wavelet.Version) < 4.11
   warning('Bad'); 
end

if ~isempty(info.circstats)
    %2011f
    
    [~, e] = regexp(info.circstats, '[\\/]CircStat');
    v = info.circstats(e+1:end-1);
    vnum = str2double(regexp(v, '\d{4}', 'match', 'once'));
    valf = regexp(v, '\D?', 'match', 'once');
    
    if vnum < 2011 || valf < 'f'
        warning('Bad');
    end
else
    warning('Bad');
end
clear e vnum valf;


if ~isempty(info.neurospec)
    %neurospec20
    
    [s, e] = regexp(info.neurospec, '[\\/]neurospec');
    vnum = str2double(info.neurospec(e+1:end-1));

    if vnum < 20 
        warning('Bad');
    end
else
    warning('Bad');
end


if ~isempty(info.sigtool)
    %cannot identify the version
else
    warning('Bad');
end


        
