function rec2 = extractTime(rec, startTime, endTime, mode)
% rec2 = extracttime(rec, startTime, endTime)
% rec2 = extracttime(rec, startTime, endTime, mode)
%
% startTime, endTime      in second
%
% mode                    'normal' (default) | 'extend'
%                         String (char row). 'extend' mode accepts
%                         startTime and endTime outside of the range of
%                         Time vector and fill the gap with NaN or zeros.
%
% See also:
% getsampleusingtime(tscollection)
% getsampleusingtime(timeseries)
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 24-Nov-2016 17:31:49


%
% TODO need a test 30/05/2014

%% parse

narginchk(3,4);

if exist('mode', 'var')
    if ischar(mode) && isrow(mode)
        mode = validatestring(mode, {'normal','extend'});
    else
        error('K:Chan:extractTime:mode:notchar',...
            'mode must be char class');
    end
else
    mode = 'normal';
end

if strcmpi(mode, 'normal')
    if rec.Start > startTime || rec.MaxTime < endTime
        error('K:Chan:extractTime:needToExtend',...
            'You need ''extend'' option to accept startTime or endTime outside of the Time.');
    end
end


p = inputParser;

switch mode
    case 'normal'
        
        vf_startTime = @(x) ~isempty(x) &&...
            isscalar(x) && ...
            isreal(x) && ...
            isfinite(x) && ...
            ~isnan(x) && ...
            x <= endTime && ...
            x >= rec.Start &&...
            x <= rec.MaxTime;
        addRequired(p, 'startTime', vf_startTime);
        
        vf_endTime = @(x) ~isempty(x) &&...
            isscalar(x) && ...
            isreal(x) && ...
            isfinite(x) && ...
            ~isnan(x) && ...           
            x >= rec.Start &&...
            x <= rec.MaxTime;
        addRequired(p, 'endTime', vf_endTime);
        
    case 'extend'
        vf_startTime = @(x) ~isempty(x) &&...
            isscalar(x) && ...
            isreal(x) && ...
            isfinite(x) && ...
            ~isnan(x) && ...
            x <= endTime;
        addRequired(p, 'startTime', vf_startTime);
        
        vf_endTime = @(x) ~isempty(x) &&...
            isscalar(x) && ...
            isreal(x) && ...
            isfinite(x) && ...
            ~isnan(x);
        addRequired(p, 'endTime', vf_endTime);
        
end

parse(p, startTime, endTime);

%% job

chans = cell(1, length(rec.Chans));
for i = 1:length(rec.Chans) %TODO parfor requires loadobj support
    chans{i} = rec.Chans{i};
    chans{i} = chans{i}.extractTime(startTime, endTime, mode, rec.Time);
    
end

if  ~isempty(rec.RecordTitle)
    rec2 = Record(chans, 'Name', rec.RecordTitle);
else
    rec2 = Record(chans);
end


end