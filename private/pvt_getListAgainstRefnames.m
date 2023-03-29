function names = pvt_getListAgainstRefnames(thisset, refnames, refnamesfull, names)
% names = pvt_getListAgainstRefnames(thisset, refnames, refnamesfull, names)
%
% INPUT ARGUMENTS
% thisset     The name set of interest. Made of names without affix.
%
% refnames    The setof file names (without affix) that
%
% refnamesfull
%             The full paths including affix of renames.
%
% indexstart
%             A positive integer that defines the start index of S for the
%             "for" loop inside the function
%
% names       Cell column vector of file names. Depending on results,
%             five different actions are required to sort the mismatch in the
%             file status. If names is not empty, the function appends the
%             names and sort them.
%
% OUTPUT ARGUMENTS
% names       Cell column vector of file names. Depending on results,
%             five different actions are required to sort the mismatch in the
%             file status.
%
% See also
% K_getupdated, K_getupdatedf, K_getupdatedmerge


[~, ind_thisset]= ismember(thisset, refnames);

if ~isempty(thisset)
    parentdir = fileparts(refnamesfull{ind_thisset(1)});
    
    newnames  = cellfun(@(x) strrep(x, [parentdir, filesep], ''), refnamesfull(ind_thisset), 'UniformOutput', false);
    
    names = [names; newnames];

    % Sort by name field
    if iscellstr(names)
        [~, ix]= sort(names);
        names = names(ix);
    end
    
end

end