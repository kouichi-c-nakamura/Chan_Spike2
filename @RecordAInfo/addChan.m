function obj = addChan(obj, newchan)
%  obj = addChan(obj, chan1)
%  obj = addChan(obj, chanInfo1)
%  obj = addChan(obj, {chan1; chan3; ...})
%  obj = addChan(obj, {chanInfo1; chanInfo2; ...})
%
% newchan    either a Chan or ChanInfo object, or
%            Chan objects or ChanInfo object in cell array of
%            column vector

narginchk(2,2);

assert(isempty(newchan) ||...
    isscalar(newchan)  && ( isa(newchan, 'Chan' )|| isa(newchan, 'ChanInfo')) ||...
    iscolumn(newchan) && ...
    iscell(newchan) && ...
    (   all(cellfun(@(x) isa(x, 'Chan'), newchan)) ||...
    all(cellfun(@(x) isa(x, 'ChanInfo'), newchan))   )   );

if isempty(newchan)
    return
elseif iscell(newchan)
    if all(cellfun(@(x) isa(x, 'Chan'), newchan))
        
        newchanInfos = cellfun(@(x) x.getChanInfo, newchan, 'UniformOutput', false);
        
    elseif all(cellfun(@(x) isa(x, 'ChanInfo'), newchan))
        newchanInfos = newchan;
    end
    
else % not cell
    if isa(newchan, 'Chan')
        newchanInfos = {newchan.getChanInfo};
        
    elseif isa(newchan, 'ChanInfo')
        newchanInfos = {newchan};
    end
    
end

% check the uniqueness of ChanTitle
newchanTitles = cellfun(@(x) x.ChanTitle,  newchanInfos, 'UniformOutput', false);

if isempty(obj.ChanInfos)
    currentChanTitles = {};
else
    currentChanTitles = cell(length(obj.ChanInfos), 1);
    for i = 1:length(obj.ChanInfos)
        currentChanTitles{i} = obj.ChanInfos{i}.ChanTitle;
    end
end
titles = [currentChanTitles; newchanTitles];

assert(numel(unique(titles)) == numel(titles),...
    'K:FileList:addChan:ChanTitle:notunique',...
    'ChanTitle must be unique.');

obj.ChanInfos = [obj.ChanInfos; newchanInfos];

%TODO test

end