function T = getNperBurstSize(obj,varargin)
% T = getNperBurstSize(obj)
% T = getNperBurstSize(obj,per)
%
% getNperBurstSize returns n numbers for different size of spikes
%
% OPTION
% per      'burst' (default) | 'record'


p = inputParser;
p.addRequired('obj');
p.addOptional('per','burst',@(x) ismember(x,{'burst','record'}));
p.parse(obj,varargin{:});
per = p.Results.per;

if ~isempty(obj.ISIordinalmeta)

    switch per
        case 'burst'
            col = obj.ISIordinalmeta(:,1);
        case 'record'
            col = obj.ISIordinalmeta_perRecord(:,1);
    end
    
    T = rowfun(@(x) cellfun(@(y) length(y),x),col,'OutputVariableNames','n');
    spk = cellfun(@(x)  x{1}, regexp(T.Properties.RowNames,'\d+','match'),'UniformOutput',false);
    T.spikes = str2double(spk);

else
    T = table(zeros(0,1),zeros(0,1),'VariableNames',{'n','spikes'});

end


end