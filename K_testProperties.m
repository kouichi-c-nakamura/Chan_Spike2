function tf = K_testProperties(obj)
% obj.testProperties;
% testProperties(obj);
%
% If a problem is found in properties, you'll get error message
% for debugging.
%
% See also
% checkproperties

propnames = properties(class(obj));
err = cell(length(propnames), 1);

for i = 1:length(propnames)
    try
        obj.(propnames{i});
    catch err1
        err{i} = err1;
    end
end
clear err1

disp(obj);

errLi = ~cellfun(@isempty, err);

if all(~errLi)
    disp('Properties appear to be OK');
    tf = true;
else
    tf = false;
    
    str = repmat('%s, ', [1, nnz(errLi)]);
    
    warning(['Problem(s) found in %d properties: ', str], sum(errLi), propnames{errLi});
    
    errfound = err(errLi);
    clear err
    openvar('errfound');
    
    name = cell(1, length(errfound));
    line = cell(1, length(errfound));
    
    for i = 1:length(errfound)
        name{i} = errfound{i}.stack(1).name;
        line{i} = errfound{i}.stack(1).line;
        fprintf('Error in %s at line %d\n', name{i}, line{i})
        
    end
    keyboard
    
    classname = class(obj);
    errid = sprintf('K:classname:testProperties',classname);
    dbstop
    error(errid,'Errors found');
    
end


end