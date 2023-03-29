function result = getEventStats(chanSpec, varargin)
% getEventStats goes through the files in chanSpec and save the Stats properties of Record objects
% into "results" folder underneath the chanSpec.ParentDir or at destdir, if specified, 
% with the name outname.
%
% result = getEventStats(chanSpec)
% result = getEventStats(chanSpec, outname)
% result = getEventStats(chanSpec, outname, destdir)
%
%
% INPUT ARGUMENTS
% chanSpec       a ChanSpecifier object. All the channels must be event or marker type.
%
% outname        (Optional) a string (char type) for the output file to be
%                saved in "results" folder underneath the
%                chanSpec.ParentDir if they are common. In canse they are
%                not common, you need to specify the destdir.
%                If empty or not provided, the result won't be saved. 
%
% destdir        (Optional) The folder path at which the output file is to be saved.
%                If provided and empty, i.e. '', the result won't be saved.
%
% OUTPUT ARGUMENTS
% result         non-scalar (N by 1) structure containing stats of recordings.
%                %TODO where N equals to sum(chanSpec.ChanNum)??
% 
%                The fields include:
%                   parnet, chantitle, duration, NSpikes, meanfiringrate, ISI,
%                   ISI_mean, ISI_STD, ISI_SEM, ISI_CV, ISI_CV2mean. ISI_CV2,
%                   parentdir
%
% See also
% chanSpec, chanSpec_getPhasehistAgainstEEG, Record, MetaEventChan.getstats



%% Parse

narginchk(1,3);

p = inputParser;
vfc = @(x) isa(x, 'ChanSpecifier') && isscalar(x);
p.addRequired('chanSpec', vfc);

vfo = @(x) ischar(x) && isrow(x) && ismatchedany(x, '.mat$');
p.addOptional('outname', '', vfo);

vfd = @(x) isdir(x) || isempty(x);
p.addOptional('destdir', '', vfd);

p.parse(chanSpec, varargin{:});

outname = p.Results.outname;
destdir = p.Results.destdir;


%% Job

outlist = chanSpec.List;

if ~isempty(outlist)
    for m = 1:chanSpec.MatNum
        rec =  chanSpec.constructRecord(m);  % requires Record class
        
        for ch = 1:chanSpec.ChanNum(m)
            this = rec.(chanSpec.ChanTitles{m}{ch});
            assert(isa(this, 'MetaEventChan'),...
                eid('notMetaEventChan'),...
                'All the channel in chanSpec must be event or marker type');
            
            outlist(m).stats(ch) = this.Stats;
        end
    end
    
    
    fields = fieldnames(outlist(1).stats(1)); 
    fields = [fields;{'parent';'parentdir'}]; %TODO
    fn = length(fields);
    
    fival= repmat({{}}, 1, fn*2);
    fival(1:2:(fn*2)) = fields'; %% Creation of this vector was the most tricky
    
    result = struct(fival{:}); % Empty structure with fields
    k =1;
    for m = 1:length(outlist)
        thisname = outlist(m).name;
        for ch = 1:length(outlist(m).stats)
            outlist(m).stats(ch).parent = thisname;
            outlist(m).stats(ch).parentdir = fileparts(chanSpec.MatNamesFull{m});
            
            result(k, 1) = outlist(m).stats(ch); %% assignment to non-scalar structure requires exact match of fieldnames
            k = k+1;
        end
        
    end
    
    
    % Change the orderfields
    result = local_reorderfields(result);
else
    
    result = [];
end


%% Save result
if ~isempty(outname) || ~isempty(destdir)
    pvt_chanSpec_save_result(chanSpec, result, destdir, outname, eid('ParentDir:notidentical')); %TODO make this private method?
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = local_reorderfields(result)

finames = fieldnames(result);
len = length(finames);

[~, a] = ismember('parent', finames);
[~, b] = ismember('chantitle', finames);

order = setdiff(1:len, [a, b]);

result = orderfields(result, finames([a,b,order]));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K:
%
%
% input argument
% str (Optional) string in char type (row vector)
%
% output argument
% eid an error id composed of 'K:(functionname):str'

narginchk(0, 1);
p = inputParser;
p.addOptional('str', '', @(x) isempty(x) || ischar(x) && isrow(x));
p.parse(varargin{:});
str = p.Results.str;

if isempty(str)
    str = '';
else
    str = [':', str];
end

[~,m,~] = fileparts(mfilename('fullpath'));

eid = ['K:', m, str];


end