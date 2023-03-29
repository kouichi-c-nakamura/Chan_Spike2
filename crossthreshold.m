function [ind,time] = crossthreshold(direction,wave,threshold,varargin)
% crossthreshold returns indices for the points where a waveform crosses
% the threshold threshold. crossthreshold mimics the the behaviours of
% Spike2 active cursor's rising/falling threshold search.
%
% [ind,time] = crossthreshold(direction,wave,threshold)
% [ind,time] = crossthreshold(____,'Param',value)
%
% INPUT ARGUMENTS
% direction   'rising' | 'falling' | 'any'
%
% wave        column vector of waveform data | WaveformChan object
%
% threshold   scalar real
%             Threshold value
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'Fs'        (Default) 1
%             Sampling frequency. Ingored if wave is a WaveformChan object.
%
% 'minDelay'  Minimum duration of corrsing in seconds when Fs is provided,
%             or in data points when Fs is omitted.
%
% 'minCross'  Minimum amount of crossing in terms of amplitude
%
%
% OUTPUT ARGUMENTS
% ind         Indices of crossing points. Crossing points are the points
%             immediately after the ideal crossing points. 
%
% time        Time stamps for crossing points. Only meaningful when you set
%             Fs properly (without Fs, time is identical to ind).
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 15-Aug-2016 20:49:28
%
% See also
% crossthreshold_demo, findpeaks, findEpochsByEnvelope, bwconncomp
% WaveformChan.crossthreshold


p = inputParser;
p.addRequired('direction',@(x) ismember(x,{'rising','falling','any'}));
p.addRequired('wave',@(x) (iscolumn(x) && isnumeric(x)) || isa(x,'WaveformChan'));
p.addRequired('threshold',@(x) isscalar(x));

p.addParameter('Fs',1,@(x) isscalar(x) && x > 0);
p.addParameter('minDelay',0,@(x) isscalar(x));
p.addParameter('minCross',0,@(x) isscalar(x));

p.parse(direction,wave,threshold,varargin{:});

Fs = p.Results.Fs;
minDelay = p.Results.minDelay;
minCross = p.Results.minCross;

if minDelay ~= 0
    minDelayPt = minDelay*Fs;
else
    minDelayPt = 0;
end


if isa(wave,'WaveformChan')
    data = wave.Data;
    Fs = wave.SRate;
else
    data = wave;
end

L = length(data);
 


switch direction
    case 'rising'
        
        BW = local_getBW(data,threshold,minCross,minDelayPt,'rising');
        
        ind = BW.onset';
        
    case 'falling'
        
        BW = local_getBW(data,threshold,minCross,minDelayPt,'falling');
        
        ind = BW.onset';
        
    case 'any'
         BW1 = local_getBW(data,threshold,minCross,minDelayPt,'rising');
         ind1 = BW1.onset';

         BW2 = local_getBW(data,threshold,minCross,minDelayPt,'falling');
         ind2 = BW2.onset';
         

         ind = union(ind1,ind2);
        
        %TODO to be tested        
        
end

if ~isempty(ind)
    if ind(1) == 1
        ind(1) = []; % discard
    end
end

if ~isempty(ind)
    if ind(end) == length(data)
        ind(end) = []; % discard
    end
end


t = ((0:length(data)-1).*1/Fs)';

time = t(ind);

if isa(wave,'WaveformChan')
   time = time + wave.Start; 
end

end

%--------------------------------------------------------------------------

function BW = local_getBW(data,threshold,minCross,minDelayPt,direction)
%
% BW = local_getBW(data,threshold,minCross,minDelayPt,direction)
% 
%
%
% See also
%

narginchk(5,5)

%% Job

switch lower(direction)
    
    case 'rising'
        tf = data > threshold;

        tf2 = data > threshold + minCross;
    case 'falling'
        tf = data < threshold;

        tf2 = data < threshold - minCross;
end

BW = bwconncomp(tf);

BW2 = bwconncomp(tf2);
BW2.onset = cellfun(@(x) x(1),BW2.PixelIdxList);
BW2.offset = cellfun(@(x) x(end),BW2.PixelIdxList);


if minCross ~= 0

    %TODO
    % for each BW.PixelIdxList, BW2.PixelIdxList must be included.
    % Otherwise, that connection is disqualified.

    k = 1;
    N = length(BW.PixelIdxList);
    tobekept = false(N,1);
    for i = 1:N

        crossed = BW.PixelIdxList{i};

        for j = k:length(BW2.PixelIdxList)
            if any(ismember(crossed, BW2.PixelIdxList{j}))
                k = j;
                tobekept(i) = true;
                break;
            end
        end
    end
    BW.PixelIdxList(~tobekept) = []; % discard
end

if minDelayPt ~= 0
    % shorter epochs will be discarded
    
    tf_size = cellfun(@(x) numel(x) >= minDelayPt,BW.PixelIdxList);
    BW.PixelIdxList(~tf_size) = []; % discard
    
end

BW.onset = cellfun(@(x) x(1),BW.PixelIdxList);
BW.offset = cellfun(@(x) x(end),BW.PixelIdxList);


if any(isnan(data))
    %NOTE exclude the data points next to NaNs
   
    BW.onset(ismember(BW.onset, find(abs(diff(isnan(data)))) + 1)) = [];
    
end

end






