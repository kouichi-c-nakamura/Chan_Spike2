function indpeaks = K_search_findPeaks(data, amp, maxwidth, varargin)
% Find indices of peaks or troughs
%
% K_findPeaks(data, amp, maxwidth) % operate as 'peak' mode
% K_findPeaks(data, amp, maxwidth, mode)
%
% INPUT ARGUMENTS
%
% data       A vector of real values
%
% amp        The minimum amplitude for peaks/troughs to be detected.
%            This defines how much the data must rise before a peak and
%            fall after it (or fall before a trough and rise after it), to
%            detect a peak/trough.
%
% maxwidth   The Maximum width for peak field rejects peaks that are too
%             broad (set it 0 for no width restriction).
%
% OUTPUT ARGUMENT
% indpeaks   Indices of peaks/troughs for data.
%
%
% See also
% findpeaks
% Peak Find/Trough Find in "Active Mode" (Spike2 version 7 documentation)

%% Parse
narginchk(3,4)

p = inputParser;
vfd = @(x) isvector(x) && isreal(x);
p.addRequired('data', vfd);

vfa = @(x) isscalar(x) && isreal(x) && x >= 0;
p.addRequired('amp', vfa);

vfw = @(x) isscalar(x) && isreal(x) && x >= 0 && fix(x) == x;
p.addRequired('maxwidth', vfw);

vfm = @(x) ismember(x, {'peak', 'trough'});
p.addOptional('mode', 'peak', vfm);

p.parse(data, amp, maxwidth, varargin{:});

operationmode = p.Results.mode;

%% Job

indpeaks = [];

datadif = diff(data);

switch operationmode
    case 'peak'
        rise = find(datadif > 0);
        fall = find(datadif < 0);
        
        seeds = intersect( rise, fall-1) +1 ; %good
        
        flat = find(datadif == 0);
        flatconsec = find(diff(flat) == 1); %TODO how to find the both ends of plateau
        
        
        
    case 'trough'
        
end

for i = 2:length(data) -1
    crossing_l  = [];
    crossing_r  = [];

    if maxwidth == 0
        enditer1 = i-1;
    else
        enditer1 = maxwidth-1; % you cannot spend all data points for left side
    end
    
    for j = 1:enditer1
        %TODO need to handle both ends
        
        if i-j < 1 || i-j > length(data) 
           continue; 
        end
        
        switch operationmode
            case 'peak'
                if data(i) < data(i-1) || data(i) < data(i+1) 
                    continue
                end
                if data(i) - data(i-j) > amp
                    crossing_l = i-j;
                    break
                end
            case 'trough'
                if data(i) > data(i-1) || data(i) > data(i+1)
                    continue
                end
                if data(i) - data(i-j) < -amp
                    crossing_l = i-j;
                    break
                end
        end
        
    end
    
    if ~isempty(crossing_l)
        if maxwidth == 0
            enditer2 = length(data) - i;
        else
            enditer2 = maxwidth-j; 
        end

        for k = 1:enditer2  
            if i+k < 1 || i+k > length(data) 
                continue
            end
            
            switch operationmode
                case 'peak'
                    if data(i) - data(i+k) > amp
                        crossing_r = i+k;
                        break
                    end
                case 'trough'
                    if data(i) - data(i+k) < -amp
                        crossing_r = i+k;
                        break
                    end
            end
        end
    end
        
    if ~isempty(crossing_l) && ~isempty(crossing_r)
        indpeaks = [indpeaks; i];
    end
    

end


end