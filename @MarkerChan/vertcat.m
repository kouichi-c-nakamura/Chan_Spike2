function chanout = vertcat(chan1,chan2,varargin)
%vertcat  Concatenation of time series objects in the time dimension.
%
%   The time vector overlap is accepted (Note this is different from
%   timeseries.append method). The SRate must be identical amoung
%   Chan objects. The start properties are ingnored except the
%   first Chan object. This allows you to concatenate any
%   Chan objects as long as SRate and class is identical.

%   Copyright 2009-2012 The MathWorks, Inc.


% All inputs must be timeseries objects
if nargin>=2
    if ~isa(chan2,'Chan')
        error(message('K:Chan:append:invts'));
    end
    chanArray = [chan1,chan2];
    if nargin>=3
        if ~all(cellfun(@(x) isa(x,'Chan'),varargin))
            error(message('K:Chan:append:invts'));
        end
        chanArray = [chanArray,[varargin{:}]];
    end
else
    chanArray = chan1;
end

% Return for empty timeseries
if length(chanArray)<=0
    chanout = chanArray;
    return
end

% Process arguments pairwise
chanout = chanArray(1);
for k=2:length(chanArray)
    chanout = localConcat(chanout,chanArray(k));
end

end

%--------------------------------------------------------------------------


function chanout = localConcat(chan1,chan2)

if chan1.Length==0
    chanout = chan2;
    return
elseif chan2.Length==0
    chanout = chan1;
    return
end


%% parse
% Merge time vectors onto a common basis

if chan1.SRate ~= chan2.SRate
    error('K:Chan:append:SRate:mismatch',...
        'SRate of 2 Chan objects must be the same.');
end

if ~strcmp(class(chan1), class(chan2))
    error('K:Chan:append:class:mismatch',...
        'Classnames of 2 Chan objects must be the same.');
end

if  ~strcmp(chan1.DataUnit, chan2.DataUnit)
    error('K:Chan:vertcat:DataUnit:mismatch',...
        'DataUnit of 2 Chan objects must be the same.');    
end

%% Concatenate time and data.
chanout = chan1; % copy parameters

data1_ = chan1.Data_;
len1 = chan1.Length;
data2_ = chan2.Data_;
len2 = chan2.Length;

% modify the indices in data2_
if ~isempty(data2_(:,1))
    data2_(:,1) = num2cell(cell2mat(data2_(:,1)) + len1);
end

chanout.Data = [chan1.Data; chan2.Data];
chanout.Data_ = [data1_; data2_]; 

chanout.DataUnit = chan1.DataUnit;
chanout.MarkerFilter = chan1.MarkerFilter;
chanout.Header = chan1.Header;


if isa(chan1,'WaveMarkChan')
    
    chanout.Traces = [chan1.Traces ; chan2.Traces];
    
end
    

end

