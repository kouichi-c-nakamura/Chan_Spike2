function [BUA sig spikeTrain indstart] = createBUA(rawsig,spikeTimes, rate, varargin)
% [BUA sig spikeTrain indstart] = createBUA(rawsig,spikeTrain, rate, varargin)
% This function take as input a continuous recorded signal and a spike
% train which was extracted from this signal and returen a "spike freee"
% signal representing the background unit activity. 
% Input parameters:
%   rawsig: The continuous recorded signal.
%   spikeTrain: timestamps of spiking activity extracted form rawsig, in
%               seconds.
%   rate: the rawsig sampling rate, in Hz.
%   optional parameters: 
%     vararging{1}: whether to trim the returned signal between the first
%                   and last  spikes, 0 for not (default), 1 to trim.
%     vararging{2}: A 2 element array defining how much to cut before and after each 
%                   spike, in msecs. defalt [0.5 2.5].
%
% Output parameters:  
%   BUA: The extracted background unit activity signal
%   sig: The returned raw signal that may be trimmed between the initial and last spikes
%   spikeTrain: the spike train, just for convinience.
%   indstart: The number of samples the returned signal had advanced compares to the given raw
%               signal. 0 if no change was made.

%% added by Kouichi 
p = inputParser;
p.addRequired('rawsig', @(x) isvector(x) && isreal(x));
p.addRequired('spikeTimes', @(x) isvector(x) && isreal(x));%accepts both column and row vectors
p.addRequired('rate', @(x) isscalar(x) && x > 0);
p.parse(rawsig, spikeTimes, rate);

if iscolumn(rawsig)
    rawsig = rawsig';
end


%%

    % whether trim the signals between the first and last spikes.
    if length(varargin)> 0 && ~isempty(varargin{1})
        trimTillSpike = varargin{1};
    else
        trimTillSpike = 0 ;
    end
    % define the windows before and after each of the spike times to remove
    % from the raw signal
    if length(varargin)> 1 && ~isempty(varargin{2})
        spikeLen = varargin{2};
        befp = round(rate/1000*spikeLen(1));
        aftp = round(rate/1000*spikeLen(2));
    else
        befp = round(rate/1000*0.5) ;
        aftp =  round(rate/1000*2.5);
    end
    % spike train in samples
    spikeTrain = round(spikeTimes*rate);
    
    len = befp + aftp + 1;
    if trimTillSpike
        indstart = round(spikeTrain(1)) ;
        indend = round(spikeTrain(end)) ;
    else
        indstart = 1 ;
        indend = length(rawsig);
    end
    rawsig = rawsig(indstart:indend) ;


    % pad with zeros to avoid problems with spikes at the start and end of
    % signal
    rawsig = [zeros(1,befp) rawsig zeros(1,aftp)];
    if spikeTrain
%     rawsig = rawsig(st(1):st(end)) ;
        spikeTrain = spikeTrain-indstart+1 + befp;
        [wins, inds] = amExtWin(rawsig, spikeTrain, befp,aftp, 0);
        multich = rawsig;
        BUA = rawsig;
        % limit is just a marker for spike areas.
        limit = min(rawsig)-100;
        multich(inds) = limit ;
        len = befp + aftp + 1; 

        % clean the areas of the spikes
        multich = multich(multich~=limit) ;

       % I'm filling the spikes areas random areas from the spikes-clean signal 
        lenmch = length(multich);
%         fillind_strt = randint(size(inds,1),1 ,[1,lenmch-len]);
        fillind_strt = randi([1,lenmch-len],size(inds,1),1); %Kouichi    
        fillind = repmat(0:len-1, size(inds,1),1) + repmat(fillind_strt,1,size(inds,2));
        replaced_frags = multich(fillind);
        BUA(inds) = replaced_frags ;
        BUA = BUA(befp+1:end-aftp);
    else
        BUA = rawsig;
    end
    sig = rawsig(befp+1:end-aftp);
    
    
    
    
    
function [wins inds] = amExtWin(arr, indx, beforelen, tilllen, pad)
% wins = amExtWin(arr, indx, before, till)
% extracts windows of arr around the indexes of indx. it extracts beforelen 
% samples before the index and tilllen after the index. each window is of
% length beforelen + tilllen +1

    winlen = beforelen + tilllen +1;
    
    arr = arr(:)';
    if pad
        arr = [zeros(1,beforelen) arr zeros(1, tilllen)];
    end
    indlen = length(indx);
    
    indx = indx(:);
    
    new_ind = repmat(indx, 1, winlen);
    
    addit = repmat([-beforelen:tilllen], size(new_ind, 1), 1);
    
    fin_ind = new_ind + addit ;
    
    if pad
        inds = fin_ind+beforelen;
    else
        inds = fin_ind;
    end
    [i j] = find(inds<1);
    inds(unique(i), :) = [];
    wins = arr(inds);