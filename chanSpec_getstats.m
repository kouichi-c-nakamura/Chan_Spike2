function result = chanSpec_getstats(chanSpec, outname, varargin)
% chanSpec_getstats goes through the files in chanSpec and save the Stats properties of Record objects
% in "results" folder underneath the chanSpec.ParentDir or at destdir, if specified, 
% with the name outname.
%
% result = chanSpec_getstats(chanSpec, outname)
% result = chanSpec_getstats(chanSpec, outname, destdir)
%
%
% INPUT ARGUMENTS
% chanSpec       a ChanSpecifier obbject
%
% outname        a string (char type) for the output file to be
%                saved in "results" folder underneath the
%                chanSpec.ParentDir if they are common. In canse they are
%                not common, you need to specify the destdir.
%
% destdir        (Optional) The folder path at which the output file is to be saved.
%                If provided and empty, the result won't be saved.
%
% OUTPUT ARGUMENTS
% result         non-scalar structure containing stats of recordings
%
%
% See also
% chanSpec, chanSpec_getPhasehistAgainstEEG

% %TODO This could be a method of ChanSpecifier!



%% Parse

narginchk(2,3);

p = inputParser;
vfc = @(x) isa(x, 'ChanSpecifier') && isscalar(x);
p.addRequired('chanSpec', vfc);

vfo = @(x) ischar(x) && isrow(x) && ismatchedany(x, '.mat$');
p.addRequired('outname', vfo);

vfd = @(x) isdir(x) || isempty(x);
p.addOptional('destdir', '', vfd);

p.parse(chanSpec, outname, varargin{:});

destdir = p.Results.destdir;


%% Job

outlist = chanSpec.List;

if ~isempty(outlist)
    for i = 1:chanSpec.MatNum
        rec =  chanSpec.constructRecord(i);  % requires Record class
        
        for j = 1:chanSpec.ChanNum(i)
            this = rec.(chanSpec.ChanTitles{i}{j});
            assert(isa(this, 'MetaEventChan'),...
                eid('notMetaEventChan'),...
                'All the channel in chanSpec must be event or marker type');
            
            outlist(i).stats(j) = this.Stats;
        end
    end
    
    
    fields = fieldnames(outlist(1).stats(1)); %TODO
    fields = [fields;{'parent'}];
    fn = length(fields);
    
    fival= repmat({{}}, 1, fn*2);
    fival(1:2:(fn*2)) = fields'; %% Creation of this vector was the most tricky
    
    result = struct(fival{:}); % Empty structure with fields
    k =1;
    for i = 1:length(outlist)
        thisname = outlist(i).name;
        for j = 1:length(outlist(i).stats)
            outlist(i).stats(j).parent = thisname;
            
            result(k) = outlist(i).stats(j); %% assignment to non-scalar structure requires exact match of fieldnames
            k = k+1;
        end
        
    end
    
    
    % Change the orderfields
    result = local_reorderfields(result);
else
    
    result = [];
end


%% Save result
if ~isempty(destdir)
    pvt_chanSpec_save_result(chanSpec, result, destdir, outname, eid('ParentDir:notidentical'));
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