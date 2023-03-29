function [outdata, timev] = K_SONAlignAndBin(sRateNew, fid, chan, varargin)
% K_SONAlignAndBin imports and resamples Spike2 waveform or event data with
% aligning and binning
%
% [outdata, timev] = K_SONAlignAndBin(sRateNew, fid, chan)
%
% version 3    
% A more accurate way of getting MaxTime() (i.e., time at the end of the
% recording file)
%
% version 2
% fixed the most of compatibility issues related to header information
% the output is now in structure format
% output argument eventime is abandoned
%
% requires [data, header] = SONGetChannel(fid, chan, 'scale')
% http://sourceforge.net/projects/sigtool/files/
%
% supporting       1 Waveform, 2,3 Event, 4 Level, 5 Marker, 8 TextMark, 
%                  9  RealWave, 
% 
% not supporting   6 WaveMark, 7 RealMark,
%
% Note that 'text' String in TextMark is not imported!!!
%
%
% INPUT ARGUMENTS
% sRateNew     new sampling rate [Hz]
%
% fid          file handle for Spike2 .smr file created by fopen()
%
% chan         channel to be resampled (waveform or event)
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'ExtractTime' %TODO
%              [starttime endtime]
%              Subtract a subset of time as the output
%              %TODO to be implemented
%              This will accelrate the processing a lot, but implementation
%              is not simple.
%              At the moment you need to load the full length data before
%              extraction.
%
% OUTPUT ARGUMENTS
% outdata including following fields:
%
% .values      waveform data interpolated by cubic spline at the rate sRateNew
%              or histogram counts of events at bin size specified by sRateNew
%
% .header      (additional: not included in exports by Spike2 buitin)
%              header.start   replaced by a new value
%              header.stop    replaced by a new value
%              header.newsamplingrate = sNewRate
%              header.newsamplinginterval = 1/sNewRate
%
% .markers     (additional: not included in exports by Spike2 buitin))
%              marker codes for maker channel
%
% timev        timevector
%
%
% Note that ChanProcess in Spike2 doesn't affect the imported data,
% although it does affect when you export from Spike2.
%
%
%
%
%
% REF: Align and bin all data in [Spike2 help document "Time View Data"]
%
% "If you check this box, the field to the right of the text is enabled and
% you can set the frequency at which the output data is generated on all
% channels. Waveform data and RealMark data draw as a waveform are
% re-sampled to this frequency using cubic spline interpolation and all
% other event and marker data is converted to binned event counts using the
% specified frequency to set the bin width. The options for event and marker
% channels also change; this is described below."
%
%
% FOR TESTING
%
%     dirpath = 'D:\PERSONAL\Dropbox\Private_Dropbox\MATLAB\Sorting Merged spikes\';
%     filename = 'kjx021i01_demo.smr';
%     fid = fopen([dirpath filename],'r') ;
% 
%     [unite.time, unite.header] = SONGetChannel(fid, 25);
%     [ECoG.time, ECoG.header]   = SONGetChannel(fid, 2, 'scale');
%     [unit.time, unit.header]   = SONGetChannel(fid, 3, 'scale'); % scaling makes kind 9
%     [LFP.time, LFP.header]     = SONGetChannel(fid, 4, 'scale');
% 
%     chanlist = SONChanList(fid);
% 
%     chan = 3;
%     sRateNew = 30000;
% 
%     [outdata, timev] = K_SONAlignAndBin(sRateNew, fid, chan)
%
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% working well 17-12-2012
% 09-May-2017 05:29:25
%
%
% See also
% SONGetChannel (if you don't need binning for synchronized channels)
% SONTicksToSeconds
% SONChannelInfo
% SONGetSampleInterval
% timestamps2binned, spline, K_SONAlignAndBin_demo.mlx
% (if you don't need binning for synchronized channels, you can also use)
% CEDS64ReadEvents, CEDS64ReadWaveF, CEDS64ReadWaveS,
% CEDS64ReadMarkers, CEDS64ReadLevels



%% parse inputs
narginchk(3, 5);

p = inputParser;
p.addRequired('sRateNew');
p.addRequired('fid');
p.addRequired('chan');
p.addParameter('ExtractTime',[],@(x) numel(x) ==2 && isrow(x) && x(1) < x(2));
p.parse(sRateNew, fid, chan, varargin{:});

extractTime = p.Results.ExtractTime;


if ~isscalar(sRateNew) || sRateNew <= 0
    throw(MException('K_SONAlignAndBin:sRateNew:invalid',...
        'sRateNew must be a positive scalar'));
end

if ~isscalar(fid) || fid <= 0
    throw(MException('K_SONAlignAndBin:fid:invalid',...
        'fid must be a positive integer'));
end

if ~isscalar(chan) || chan <= 0
    throw(MException('K_SONAlignAndBin:chan:invalid',...
        'chan must be a positive scalar'));
end

if isempty(extractTime)
    doextracttime = false;
else
    doextracttime = true;
end
   



%% import data
try
    [data, header] = SONGetChannel(fid, chan, 'scale'); % takes 20% of time
        
         
catch exception
    if strcmp(exception.identifier, 'MATLAB:UndefinedFunction')
        msg =['Have you installed sigTOOL? SONGetChannel() is needed: ',...
            '<a href = "http://sourceforge.net/projects/sigtool/files/">click here to get sigTOOL</a>'];
        error(exception.identifier, msg);
        clear msg
    else
        error(exception.identifier, exception.message);
    end
end

if ~isstruct(header)
    error('K_SONAlignAndBin:header:invalid','~isstruct(header)');
end

if isempty(data)
    outdata.values = [];
else
    
    [m, n] = size(data);
    if isempty(m) 
        error('K_SONAlignAndBin:data:invalid','data is not a column vector');
    end
    
    if n ~= 1
        % this may be that columns represent epochs, so you need to
        % concatenate them
        C = cell(length(header.npoints),1);
        for i = 1:length(header.npoints)
           
           C{i} = data(1:header.npoints(i),i);
 
        end
        
        data = vertcat(C{:});
        
    end
    
    clear m n
    
    
    %% job starts here
    maxtime = local_SONMaxTimeSec(fid);  
    Info = SONChannelInfo(fid,chan(1));
    stop = SONTicksToSeconds(fid, Info.maxChanTime, 'seconds');
    
    sIntervalSecNew = 1/sRateNew;
    XX = (0:sIntervalSecNew:maxtime)'; %new time vector
    timev =XX;

    header.newsamplingrate   = sRateNew;
    header.newsampleinterval = sIntervalSecNew*1e6; % in microsecond
    
    if header.kind == 9 % waveform(scaled)
        % 'scale' option of SONGetChannel changes header.kind 1 to 9.
        
        if isinteger(data)
            error('K_SONAlignAndBin:notscaled',...
                'Waveform data must be scaled when SONGetChannel is used');
        end
        
        [si, start] = SONGetSampleInterval(fid, chan); % start [sec]
        sIntervalSec = si * 1e-6; % in second
        startSec = start * 1e-6; % in second
        
        if startSec >= sIntervalSec || ... % >= 09/05/2017
                startSec > sIntervalSecNew % start later than the first sampling inerval
            warning('K:K_SONAlignAndBin:start',...
                'start (%f sec) is siginificantly different from 0.',startSec);
        else
            startSec = 0; % approximation
        end
        
        X  = (startSec:sIntervalSec:stop)'; % only needed for waveform channel
        
        Y = data;
        if length(Y) ~= length(X)
            error('K_SONAlignAndBin:sizemismatch',...
                ['The length of time vector X and chan data points Y are not equal.\n',...
                'You should check if they are downsampled by ChanProcess']);
        end
        
        YY = spline(X, Y, XX); % cubic spline interpolation, takes ~70% of time
        %TODO If Y as matrix with each column representing each channel it
        %could be much faster. Accept comma separated list of chans?
        
        header.start = XX(1);
        header.stop = XX(end);
        
        % structure compatible with Spike2 export function
        outdata.title = header.title;
        outdata.comment = header.comment;
        outdata.interval = header.newsampleinterval/1000000; % in sec
        outdata.scale = []; % not compatible
        outdata.offset = header.offset;
        outdata.units = header.units;
        outdata.start = header.start;
        outdata.length = length(YY);
        outdata.values = YY;
        outdata.header = header; % additional
        
        %     plot(x, y, xx, yy, 'LineStyle', 'none', 'Marker', '.')
        
    elseif header.kind == 2 || header.kind == 3 || header.kind == 4
        
        %TODO Currently assuming you don't have an event at time 0.
        
        t = data;
        
        header.start = XX(1);
        header.stop = XX(end);
        
        % get logical vector of events from t
        [YY, eventtime]= timestamps2binned(t, XX(1), XX(end), sRateNew);
        %       markers =[];
        
        % structure compatible with Spike2 export function
        outdata.title     = header.title;
        outdata.comment   = header.comment;
        outdata.interval  = header.newsampleinterval/1000000; % in sec
        outdata.start     = header.start;
        outdata.length    = length(YY);
        outdata.values    = YY;
        outdata.header    = header; % additional
        outdata.eventtime = eventtime;
        
    elseif header.kind == 5 % marker channel
        
        %TODO Currently assuming you don't have an event at time 0.
        
        t = data.timings;
        markers = data.markers;
        
        header.start = XX(1);
        header.stop = XX(end);
        
        % get logical vector of events from t
        [YY, eventtime]= timestamps2binned(t, XX(1), XX(end), sRateNew);
        
        % structure compatible with Spike2 export function
        outdata.title     = header.title;
        outdata.comment   = header.comment;
        outdata.interval  = header.newsampleinterval/1000000; % in sec
        outdata.start     = header.start;
        outdata.length    = length(YY);
        outdata.values    = YY;
        outdata.header    = header; % additional
        outdata.eventtime = eventtime; % additional
        outdata.markers   = markers; % additional
        
    elseif header.kind ==8 % TextMark channel
        
        %TODO Currently assuming you don't have an event at time 0.
        
        t = data.timings;
        markers = data.markers;
        
        header.start = XX(1);
        header.stop = XX(end);

        % get logical vector of events from t
        [YY, eventtime]= timestamps2binned(t, XX(1), XX(end), sRateNew);
        
        % structure compatible with Spike2 export function
        outdata.title     = header.title;
        outdata.comment   = header.comment;
        outdata.interval  = header.newsampleinterval/1000000; % in sec
        outdata.start     = header.start;
        outdata.length    = length(YY);
        outdata.values    = YY;
        outdata.header    = header; % additional
        outdata.eventtime = eventtime;
        outdata.markers   = markers; % additional
        
    else % none of above type
        outdata.values = [];
        outdata.header = [];
        warning('K_SONAlignAndBin:ChanKind:invalid','ChanKind is invalid');
    end
end
end

%--------------------------------------------------------------------------

function maxtime = local_SONMaxTimeSec(fid)
% maxtime = local_SONMaxTimeSec(fid) returns MaxTime() for a Spike2 .smr
% file based on all the waveform channels and realwave channels in the
% file. The maximum value of clock ticks is conveted in seconds.
%
% fid       file handle prepared by fopen
%
% maxtime   maximum time in the file
%
% requires SigTool functions
% SONChanList
% SONChannelInfo
% SONTicksToSeconds


validateattributes(fid, {'double'}, {'scalar', 'positive', 'integer'});

list = SONChanList(fid);
ind = find([list.kind] == 1 | [list.kind] == 9);
n = length(ind); % number of waveform/realwave channels
wfchans = [list(ind).number];

info = cell(size(1, n));
maxChanTicks = zeros(1, n);

for i = 1:n
    info{i} = SONChannelInfo(fid, wfchans(i));
    maxChanTicks(i) = info{i}.maxChanTime;
end

maxtime= SONTicksToSeconds(fid, max(maxChanTicks), 'seconds');

end