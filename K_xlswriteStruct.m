function [status,message] = K_xlswriteStruct(filename,S,sheet,xlRange)

%% parse
p = inputParser;

vf_filname = @(x) ischar(x) && isrow(x);

vf_S = @(x) isstruct(x);

vf_sheet = @(x) ischar(x) && isrow(x) && isempty(regexp(x, ':', 'ONCE')) ||...
    fix(x) == x && x > 0;

vf_xlRange = @(x) ischar(x) && isrow(x) && isempty(regexp(x, ':', 'ONCE')) ;

addRequired(p, 'filename', vf_filname);
addRequired(p, 'S', vf_S);
addRequired(p, 'sheet', vf_sheet);
addRequired(p, 'xlRange', vf_xlRange);

parse(p, filename,S,sheet,xlRange);



%% job

finames = fieldnames(S);

for i = 1:length(finames)
    
    if isstruct(S.(finames{i}))
        
        sheet1 = 'struct' + 1;
        
        K_xlswriteStruct(filename,S.(finames{i}),sheet,xlRange);

        
        
    end
    
    
    
end

















end