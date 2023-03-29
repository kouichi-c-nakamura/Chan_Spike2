function out = K_savevar(outnamestem, resdir, varargin)
% **IMPORTANT** K_savevar is not recommended. Use savevar instead.
%
% K_savevar saves varibales assigned to varargin into two .mat files with file
% names composed of [outnamestem, '.mat'] and [outnamestem, datetimestr,
% '.mat'] for back up in a folder resdir.
% If a file with the same file name already exist and its content is
% identical to what you are saving, it won't update the file but just leave
% a warning message.
%
%    out = K_savevar(outnamestem, resdir, var1, var2, var3, ...)
%
% In order to load the saved data, execute the following code outside this
% function (typically at the Base workspace).
%
%    load(fullfile(resdir, [outnamestem, '.mat']));
%
%
% INPUT ARGUMENTS
% outnamestem        The stem string of output .mat file name.
%
% resdir             A full folder path for the resultant .mat file to be
%                    saved in.
%
% var1, var2, ...    Your variables to be saved. Unlike the built-in save
%                    function, you need to pass variables themselves,
%                    rather than variable names. Note that, in order to
%                    maintain the variable names, you need to pass
%                    variables themselves, rather than direcly passing
%                    fields of structure, content of cell or table etc.
%
% OUTPUT ARGUMENTS
% out                true (1) | false (0)
%                    Returns true when K_savevar saved data or updated
%                    data. Returns false if nothing has been changed.
%
% See also
% save, eval, datestr, savevar
%
% Written by 
% Kouichi C. Nakamura, Ph.D.
% Kyoto University
% kouichi.c.nakamura@gmail.com
% 25 Nov 2015

warning('K_savevar() is not recommended, Use savevar() instead.')

narginchk(2, inf);

p = inputParser;
p.addRequired('outnamestem', @(x) ischar(x) && isrow(x));
p.addRequired('resdir', @(x) ischar(x) && isrow(x) && isdir(x));
p.parse(outnamestem, resdir);
clear p

K_savevar_out = false;

K_savevar_outnamestem = outnamestem;
K_savevar_resdir = resdir;
clear outnamestem datetimestr resdir

K_savevar_datetimestr = datestr(now, '_yyyy-mm-dd_HHMMSS');

if ~isdir(K_savevar_resdir)
   mkdir(K_savevar_resdir);     
end

K_savevar_outname1 = [K_savevar_outnamestem, K_savevar_datetimestr, '.mat'];
K_savevar_outname2 = [K_savevar_outnamestem, '.mat'];


if nargin > 2
    
    K_savevar_inputnames = cell(1, nargin-2);
    for K_savevar_i = 1:nargin-2
        K_savevar_inputnames{K_savevar_i} = inputname(K_savevar_i+2);
        if exist(K_savevar_inputnames{K_savevar_i}, 'var')
			error('K:K_savevar:inputname:overlap:with:internalvariables', ...
				'The name of input argument %s is identical to one of K_savevar''s internal variables.',...
				K_savevar_inputnames{K_savevar_i});
        end
        
        try
            eval(sprintf('%s = varargin{%d};', inputname(K_savevar_i+2), K_savevar_i)); % maintain the input variable names
        catch mexc1
            if strcmp(mexc1.identifier,'MATLAB:m_invalid_lhs_of_assignment')
               warning(['K_savevar uses inputname() to get the original variable names when called. ',...
                   'Avoid using dot notations or subscript indexing. ' ,...
                   'Consider using single variables to pass data to K_savevar. ']) 
               throw(mexc1) 
            end
        end
        
    end

    if exist(fullfile(K_savevar_resdir, [K_savevar_outnamestem, '.mat']), 'file')
        
        K_savevar_S = load(fullfile(K_savevar_resdir, [K_savevar_outnamestem, '.mat']));
        
        K_savevar_fin = fieldnames(K_savevar_S); % used in eval
        
        if length(K_savevar_fin) < length(K_savevar_inputnames)
            % not all of variables had ben saved before.
            K_savevar_TF = false;
        else
            K_savevar_TF = false(nargin-2, 1);
            for K_savevar_i = 1:nargin-2
                eval(sprintf('K_savevar_TF(K_savevar_i) = isequaln(%s, K_savevar_S.(K_savevar_fin{K_savevar_i}));', ...
                    K_savevar_inputnames{K_savevar_i}));
            end
            
        end
     
        
        
        if all(K_savevar_TF)
            fprintf('No need to update (%s)\n', fullfile(K_savevar_resdir, [K_savevar_outnamestem, '.mat']));
        else
            
            save(fullfile(K_savevar_resdir, K_savevar_outname1), K_savevar_inputnames{:}); % for back up
            disp(fullfile(K_savevar_resdir, K_savevar_outname1));
            
            save(fullfile(K_savevar_resdir, K_savevar_outname2), K_savevar_inputnames{:}); % the latest
            disp(fullfile(K_savevar_resdir, K_savevar_outname2));

            K_savevar_out = true;
        end
    else
        
        save(fullfile(K_savevar_resdir, K_savevar_outname1), K_savevar_inputnames{:}); % for back up
        disp(fullfile(K_savevar_resdir, K_savevar_outname1));
        
        save(fullfile(K_savevar_resdir, K_savevar_outname2), K_savevar_inputnames{:}); % the latest
        disp(fullfile(K_savevar_resdir, K_savevar_outname2));
        
        K_savevar_out = true;

    end

else
    warning off backtrace
    warning('Nothing has been saved by K_savevar.');
    warning on backtrace
    
end

out = K_savevar_out;

end