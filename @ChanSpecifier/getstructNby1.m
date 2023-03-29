function S = getstructNby1(chanSpec, varargin)
% When called without "chanpropname", getstructNby1 returns N by 1
% non-scalar strucure of channels with unshared field left empty (== []),
% where N is the number of all the channels included. You can also retrieve
% sttucture for N channels that has the field "chanpropname".
%
%   S = getstructNby1(chanSpec)
%   S = getstructNby1(chanSpec, chanpropname);
%   S = getstructNby1(chanSpec, TF);
% 
% INPUT ARGUMENTS
% chanSpec       a ChanSpecifier object 
%
% chanpropname   string (char type)
%                When "chanpropname" is given, looks for the specified
%                field of each channel and return it in a N by 1 non-scalar
%                structure, where N is the number of relavant channels.
%
% TF             Logical vector with the length that is euqal to the sum of
%                chanSpec.ChanNum
%
% OUTPUT ARGUMENTS
% S       N by 1 structure with the common fileds in all the channels.
%         The uncommon fields are left empty [] for channels that don't
%         have those fields. The order of fields are kept unchanged as much
%         as possible. N equals to sum(chanSpec.ChanNum) or the number of
%         relavant channels with field 'chanpropname'.
%
% See also
% ChanSpecifier.gettable, ChanSpecifier.getstructOne, 

%% Parse

narginchk(1,2);

p = inputParser;
p.addRequired('chanSpec');

vf2 = @(x) ischar(x) && isrow(x) || iscolumn(x) && all(x==0|x==1);
p.addOptional('chanpropname', '', vf2);

p.parse(chanSpec, varargin{:});

chanpropname = p.Results.chanpropname;


%% Job

M = chanSpec.MatNum;
CH = chanSpec.ChanNum;
chantitles = chanSpec.ChanTitles;

chanfinames = cell(M, 1);


if ~isempty(chanpropname)
    if ischar(chanpropname)
        % chan  selection
        % mat selection for
        TF = false(sum(CH), 1);
        k = 0;
        for m = 1:M
            for ch = 1:CH(m)
                k  = k + 1;
                
                thischan = chanSpec.List(m).channels.(chantitles{m}{ch});
                if ismember(chanpropname , fieldnames(thischan))
                    TF(k) = true;
                end
            end
        end
    elseif isnumeric(chanpropname) || islogical(chanpropname)
        assert(length(chanpropname) == sum(CH));
        TF = logical(chanpropname);
    end
else
    
    TF = true(sum(CH),1);
    
end


% get filednames of channels
for m = 1:M
    
    buffer = cell(CH(m), 1);
    for ch = 1:CH(m)
        if TF(chanSpec.matindchanind2allind(m,ch)) %SLOW
            buffer{ch} = fieldnames(chanSpec.List(m).channels.(chantitles{m}{ch}));
        end
    end
    
    chanfinames{m} = buffer;
    
end


chanfinamesflat = vertcat(chanfinames{:});

unionfinames = local_getunionfinames(CH, chanfinamesflat);

newfinames = [{'allindex';'matindex';'chanindex'};unionfinames];

%% Preallocation
k = length(newfinames);
fieldvalue = cell(1, 2*k);

for i = 1:k
    fieldvalue([i*2-1, i*2]) = [newfinames(i), {cell(nnz(TF), 1)}];
end
clear k

S = struct(fieldvalue{:});
clear fieldvalue

k = 1;
for m = 1:M
    for ch = 1:CH(m)
        if TF(chanSpec.matindchanind2allind(m,ch)) %SLOW
            
            thischan = chanSpec.List(m).channels.(chantitles{m}{ch});
            
            thisfinames = fieldnames(thischan);
            
            S(k).allindex = chanSpec.matindchanind2allind(m,ch);
            S(k).matindex = m;
            S(k).chanindex = ch;
            
            for f = 1:length(thisfinames)
                S(k).(thisfinames{f}) =thischan.(thisfinames{f});
            end
            
            k = k +1;
        end
    end
end

end




%--------------------------------------------------------------------------

function unionfinames = local_getunionfinames(CH, chanfinamesflat)
if sum(CH) > 1
    notempty = find(cellfun(@(x) ~isempty(x),chanfinamesflat));
    
    if length(notempty) > 1
        
        [unionfinames, Lia] = union(chanfinamesflat{notempty(1)}, chanfinamesflat{notempty(2)});

        %keep the order of field names
        [~, ind]=sort(Lia);
        unionfinames = unionfinames(ind);

        if sum(CH) >= 3
            for i = 3:length(notempty)
                [unionfinames, Lia] = union(unionfinames, chanfinamesflat{notempty(i)});

                %keep the order of field names

                [~, ind]=sort(Lia);
                unionfinames = unionfinames(ind);

            end
        end
    
    else
        if ~isempty(notempty)
        
            unionfinames = chanfinamesflat{notempty(1)};
        else
            % chanfinamesflat is all empty
            unionfinames = {};
        end
    end
    
elseif sum(CH) == 1
    unionfinames = chanfinamesflat{1};
else
    unionfinames = {};
end


end