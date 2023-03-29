function [yy, eventtime]= K_t2yy(t, start, stop, srate, varargin)
% K_t2yy converts timestamps of events to a logical vector if possible
%
%[yy, eventtime]= K_t2yy(t, start, stop, srate)
%[yy, eventtime]= K_t2yy(t, start, stop, srate, modestr)
%
%
% INPUT ARGUMENTS
% t              timestamps vector
% stard, stop    in sec
% srate          Hz
%
% modestr         'normal' (default) | 'ignore'
%                 (Optional) 'ignore' option will ignore warnings when
%                 sampling rate is too low and multiple events fall into
%                 single bin and put that bin 1 event (thus loses some very
%                 close events)
%
% OUTPUT ARGUMENTS
% yy             logical binary vector indicating events
%                (NOTE: when srate is too low, and modestr is 'normal', yy
%                is not logical or binary)
%
% eventtime      timesstamps resampled at srate
%
%TODO consider rename K_t2yy to K_timestamps2binned or K_bintimestamps
% 'yy' can be 'binned'
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 21-Jun-2016 11:14:27

warning('K_t2yy is not recommended. use timestamps2binned instead.')


%% parsing
narginchk(4, 5);

p = inputParser;

vf1 = @(x) isvector(x) &&...
    isnumeric(x) &&...
    issorted(x) && ...
    all (x >= 0);

vf2 = @(x) isscalar(x) &&...
    (x >= 0);

vf3 = @(x) isscalar(x) &&...
    (x > 0);

vf4 = @(x) isscalar(x) && ...
    (x > 0);

addRequired(p, 't', vf1);
addRequired(p, 'start', vf2);
addRequired(p, 'stop', vf3);
addRequired(p, 'srate', vf4);
addOptional(p,'modestr', 'normal', @(x) ismember(lower(x), {'normal','ignore'}));
parse(p, t, start, stop, srate, varargin{:});

modestr = lower(p.Results.modestr);


%% job
xx = (start:1/srate:stop + 1/srate)'; % one bin added at the end to cover the last t
yy = histc(t, xx); % binning

% get back to the right length
if length(xx) > 2
    xx(end) = [];
    yy(end - 1) = yy(end - 1) + yy(end);
    yy(end) = [];
end

%Note: The length of output of resample(x, p, q) is ceil(length(x)*p/q)

if all(yy(yy ~=0) == 1)  % if the vector is binary    
    yy = sparse(logical(yy)); % to save disk space
    eventtime = xx(logical(yy));
else
    switch modestr
        case 'normal'
    
            warning('K:timestamp2vec:yyNotBinary',...
                ['Sampling rate seems too low to accomodate single events into ',...
                'separate bins. Some elements of yy cotaining values more than 1.',...
                'Thus yy cannot be used as logical']);
            indyy = find(yy);
            j = 1; % the cumulative number of events
            eventtime = zeros(sum(yy),1); % still event time is useful
            for i=1:length(indyy) % for each bin containing events
                for j = j:j+yy(indyy(i))-1
                    eventtime(j) = xx(indyy(i));
                end
                j = j+1;
            end
        case 'ignore'
            TFmulti = yy > 1;
            
            yy(TFmulti) = 1;
            yy = sparse(logical(yy)); % to save disk space
            eventtime = xx(logical(yy));
    end
    
end

if iscolumn(t) && isrow(yy) || isrow(t) && iscolumn(yy)
   yy = yy'; 
end

if iscolumn(t) && isrow(eventtime) || isrow(t) && iscolumn(eventtime)
   eventtime = eventtime'; 
end

end