function [yy, eventtime]= timestamps2binnedN(t, start, N, srate, modestr)
% timestamps2binned converts timestamps of events to a logical vector if possible
%
%[yy, eventtime]= timestamps2binnedN(t, start, N, srate)
%[yy, eventtime]= timestamps2binnedN(t, start, N, srate, modestr)
%
%
% INPUT ARGUMENTS
% t              timestamps vector | []
%                In seconds.
%
% start          in seconds.
% 
% N              integer
%                Length of the vector yy.
%
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
%                is not logical or binary, but instead double.)
%                If t is empty, yy is a vector of false.
%
% eventtime      timesstamps resampled at srate | []
%                If t is empty, eventtime is empty
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 21-Jun-2016 11:14:27
%
% See also
% timestamps2binned



arguments
    
    t {vf_t(t)}
    start (1,1) double {mustBeNonnegative}
    N (1,1) double {mustBePositive, mustBeInteger}
    srate (1,1) double {mustBePositive}
    modestr (1,:) char {mustBeMember(modestr,{'normal','ignore'})} = 'normal'
    
end


modestr = lower(modestr);


%% job

xx = progression(start,1/srate,N)';


% yy = histc(t, xx); % binning
yy = [histcounts(t, xx) , 0]'; % binning, %NOTE Last bin added for back compatibility with histc 


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


function vf_t(x)

assert(isempty(x) ||...
    isvector(x) &&...
    isnumeric(x) &&...
    issorted(x) && ...
    all (x >= 0));


end