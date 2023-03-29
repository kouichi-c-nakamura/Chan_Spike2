function [chanind, matind] = chantitles2chanind(chanSpec, matnamesfull, chantitles)
% [chanind, matind]  = chantitles2chanind(chanSpec, matnamesfull, chantitles)
% [chanind, matind]  = chantitles2chanind(chanSpec, matindex, chantitles)
%
% INPUT ARGUMENTS
% matnamesfull   fullpath of a mat file in char or
%                cell vector of fullpaths of mat files
%
% matindex       A vector of positive integers that specify .mat files in 
%                chanSpec.List in order
%
% chantitles     Char of chantitles or Cell vector of
%                chantitles that are included in the single mat
%                file that is specified by matnamesfull.
%                Alternatively, a cell vecotr whose each cell
%                contains Cell vector of chantitles that are
%                included in the corresponding single mat file
%                that is specified by matnamesfull.
%
% OUTPUT ARGUMENTS
% chanind        Column cell vector with the length of matnamesfull
%                and each cell contains positive integers that
%                specifies the chantitles for a mat file.
%
% matind         Cell column vector with the length of matnamesfull
%                containing positive integers.
%
%
% Examples
% chanind = chantitles2chanind(chanSpec, 'folder\name1', {'chan1', chan2'})
% chanind = chantitles2chanind(chanSpec, {'folder\name1','folder\name2'} ,...
%                          [{{'chan1', chan2'}},{{'chan3','chan5'}}))
%
% See also
% ChanSpecifier.matnamesfull2matind


%% Parse

narginchk(3,3)

p = inputParser;
p.addRequired('chanSpec');


vfm = @(x) (ischar(x) && isrow(x)) ||...
    isvector(x) && (...
        iscellstr(x) ||...
        isnumeric(x) && all(x > 0) && all(fix(x) == x)...     
    );

p.addRequired('matnamesfull', vfm);

vfc = @(x) (ischar(x) && isrow(x)) ||...
    isvector(x) && iscellstr(x) ||...
    (iscell(x) && all(cellfun(@iscellstr, x)));
p.addRequired('chantitles', vfc);

p.parse(chanSpec, matnamesfull, chantitles);

if ischar(chantitles)
    chantitles = {{chantitles}};
elseif iscellstr(chantitles)
    chantitles = {chantitles};
end



%% Job

if iscellstr(matnamesfull) || ischar(matnamesfull)
    matind = chanSpec.matnamesfull2matind(matnamesfull);
else
    if iscell(matnamesfull)
        matind = matnamesfull{1};
    else
        matind = matnamesfull;
    end
    matind = num2cell(matind);
end

%TODO this does not support cases where values in matnamesfull are not
% unique

if isnumeric(matind)
    matind = {matind};
end

chanind = cell(length(matind), 1);
for i = 1:length(matind)
    ind_thismat = matind{i};
    targetchantitles_thismat = chantitles{i};
    
    if iscolumn(ind_thismat); 
        ind_thismat = ind_thismat'; 
    end
    
    for j = ind_thismat
        
        buffer = zeros(length(targetchantitles_thismat), 1);
        
        for k = 1:length(targetchantitles_thismat)
            
            assert(iscellstr(chanSpec.ChanTitles{j}),...
                'K:ChanSpecifier:chantitles2chanind:chantitles:notcellstr',...
                'ChanTitles')
            
            ind =  find(ismember(chanSpec.ChanTitles{j}, targetchantitles_thismat{k}));
            %TODO j is wrong
            
            assert(length(ind) == 1,...
                'K:ChanSpecifier:chantitles2chanind:chantitles:absent',...
                'Chantitles "%s" does not exist in %s''s No. %d mat file "%s"',...
                targetchantitles_thismat{k}, inputname(1), i, chanSpec.MatNames{i});
            
            buffer(k) = ind;
            
        end
        
    end
    
    chanind{i} = buffer;
    
end




end